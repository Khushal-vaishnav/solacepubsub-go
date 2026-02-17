package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	"solace.dev/go/messaging"
	solace "solace.dev/go/messaging/pkg/solace"
	solacecfg "solace.dev/go/messaging/pkg/solace/config"
	"solace.dev/go/messaging/pkg/solace/message"
	"solace.dev/go/messaging/pkg/solace/resource"
)

/*
	METRICS
*/
var (
	consumedTotal = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "solace_messages_consumed_total",
			Help: "Total number of messages consumed",
		},
	)
	consumeErrors = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "solace_consume_errors_total",
			Help: "Total number of consumer errors",
		},
	)
)

type Config struct {
	Host     string
	VPN      string
	User     string
	Password string
	Queue    string
}

var logger *zap.Logger

func main() {
	initLogger()
	initMetrics()

	cfg := Config{
		Host:     getenv("SOLACE_HOST", "tcp://127.0.0.1:55555"),
		VPN:      getenv("SOLACE_VPN", "vpn1"),
		User:     getenv("SOLACE_USERNAME", "admin"),
		Password: getenv("SOLACE_PASSWORD", "admin"),
		Queue:    getenv("QUEUE", "q.tick.receiver"),
	}

	go startMetricsServer()

	service := connectSolace(cfg)
	defer service.Disconnect()

	receiver := startConsumer(service, cfg.Queue)
	defer receiver.Terminate(0 * time.Second)

	waitForShutdown()
}

/*
	METRICS SERVER
*/
func initMetrics() {
	prometheus.MustRegister(consumedTotal, consumeErrors)
}

func startMetricsServer() {
	http.Handle("/metrics", promhttp.Handler())
	logger.Info("metrics server started", zap.String("port", "8080"))
	log.Fatal(http.ListenAndServe(":8080", nil))
}

/*
	LOGGER
*/
func initLogger() {
	enc := zap.NewProductionEncoderConfig()
	enc.EncodeTime = zapcore.ISO8601TimeEncoder
	core := zapcore.NewCore(
		zapcore.NewJSONEncoder(enc),
		zapcore.AddSync(os.Stdout),
		zapcore.InfoLevel,
	)
	logger = zap.New(core)
}

/*
	SOLACE
*/
func connectSolace(cfg Config) solace.MessagingService {
	props := solacecfg.ServicePropertyMap{
		solacecfg.TransportLayerPropertyHost:                cfg.Host,
		solacecfg.ServicePropertyVPNName:                    cfg.VPN,
		solacecfg.AuthenticationPropertySchemeBasicUserName: cfg.User,
		solacecfg.AuthenticationPropertySchemeBasicPassword: cfg.Password,
	}

	service, err := messaging.NewMessagingServiceBuilder().
		FromConfigurationProvider(props).
		Build()
	if err != nil {
		log.Fatal(err)
	}

	if err := service.Connect(); err != nil {
		log.Fatal(err)
	}

	logger.Info("connected to solace broker")
	return service
}

func startConsumer(
	service solace.MessagingService,
	queueName string,
) solace.PersistentMessageReceiver {

	queue := resource.QueueDurableExclusive(queueName)

	receiver, err := service.
		CreatePersistentMessageReceiverBuilder().
		WithMessageAutoAcknowledgement().
		WithMissingResourcesCreationStrategy(
			solacecfg.MissingResourcesCreationStrategy("CREATE_ON_START"),
		).
		Build(queue)

	if err != nil {
		consumeErrors.Inc()
		log.Fatal(err)
	}

	if err := receiver.Start(); err != nil {
		consumeErrors.Inc()
		log.Fatal(err)
	}

	receiver.ReceiveAsync(func(msg message.InboundMessage) {
		time.Sleep(10 * time.Millisecond)
		consumedTotal.Inc()
	})

	logger.Info("consumer started", zap.String("queue", queueName))
	return receiver
}

/*
	SHUTDOWN
*/
func waitForShutdown() {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()
	<-ctx.Done()
}

/*
	ENV
*/
func getenv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}


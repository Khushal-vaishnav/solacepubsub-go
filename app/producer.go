package main

import (
	"context"
	"log"
	"math/rand"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	"solace.dev/go/messaging"
	solace "solace.dev/go/messaging/pkg/solace"
	solacecfg "solace.dev/go/messaging/pkg/solace/config"
	"solace.dev/go/messaging/pkg/solace/resource"
)

/*
	METRICS
*/
var (
	publishedTotal = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "solace_messages_published_total",
			Help: "Total messages published",
		},
	)
	publishErrors = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "solace_publish_errors_total",
			Help: "Total publish errors",
		},
	)
)

type Config struct {
	Host     string
	VPN      string
	User     string
	Password string
	Topic    string
}

var logger *zap.Logger

func main() {
	initLogger()
	initMetrics()

	cfg := Config{
		Host:     getenv("SOLACE_HOST", "tcp://127.0.0.1:55555"),
		VPN:      getenv("SOLACE_VPN", "vpn1"),
		User:     getenv("SOLACE_USERNAME", "tickpublisher"),
		Password: getenv("SOLACE_PASSWORD", "tickpublisher"),
		Topic:    getenv("TOPIC", "stock/tick/publisher"),
	}

		go startMetricsServer()

	service := connectSolace(cfg)
	defer service.Disconnect()

	publisher := startPublisher(service)
	runProducerLoop(service, publisher, cfg)

	waitForShutdown()
}

/*
	METRICS
*/
func initMetrics() {
	prometheus.MustRegister(publishedTotal, publishErrors)
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

func startPublisher(service solace.MessagingService) solace.PersistentMessagePublisher {
	pub, err := service.CreatePersistentMessagePublisherBuilder().Build()
	if err != nil {
		publishErrors.Inc()
		log.Fatal(err)
	}

	if err := pub.Start(); err != nil {
		publishErrors.Inc()
		log.Fatal(err)
	}

	return pub
}

func runProducerLoop(
	service solace.MessagingService,
	publisher solace.PersistentMessagePublisher,
	cfg Config,
) {
	topic := resource.TopicOf(cfg.Topic)
	rng := rand.New(rand.NewSource(time.Now().UnixNano()))

	go func() {
		for {
			payload := `{"price":` + strconv.Itoa(rng.Intn(1000)) + `}`
			msg, _ := service.MessageBuilder().BuildWithStringPayload(payload)

			if err := publisher.Publish(msg, topic, nil, nil); err != nil {
				publishErrors.Inc()
				continue
			}

			publishedTotal.Inc()
			time.Sleep(1 * time.Millisecond)
		}
	}()
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


🚀 Solace PubSub+ Event-Driven Platform (End-to-End DevOps Project)

This project demonstrates a production-style event-driven architecture using Solace PubSub+, Go microservices, Kubernetes, Prometheus/Grafana, HPA with external metrics, CI/CD to GHCR, GitOps with ArgoCD, and Infrastructure provisioning with Terraform (EKS).

The goal of this project is to showcase real-world platform engineering and DevOps practices, not toy examples.

🧠 What This Project Proves

Event-driven messaging with Solace PubSub+
Go-based producer / consumer microservices
Kubernetes-native deployment (kind + EKS)
Prometheus metrics instrumentation
Autoscaling using external metrics
CI/CD pipelines pushing images to GHCR
GitOps reconciliation with ArgoCD
Infrastructure as Code using Terraform
Cost-safe AWS usage (create → validate → destroy)

🏗️ Architecture Overview
High-level Flow
Producer (Go)
   │
   ▼
Solace PubSub+ Broker
   │
   ▼
Consumer (Go)
   │
   ▼
Prometheus → Grafana
   │
   ▼
HPA (External Metrics)

Control Plane
Kubernetes (kind locally / EKS on AWS)
ArgoCD for GitOps
Terraform for infra provisioning

📂 Repository Structure
.
├── run.go/                  # Go producer & consumer
│   ├── producer.go
│   ├── consumer.go
│   ├── Dockerfile.producer
│   └── Dockerfile.consumer
│
├── k8s/                     # Base Kubernetes manifests
│   ├── deployment-producer.yaml
│   ├── deployment-consumer.yaml
│   ├── service-producer.yaml
│   ├── service-consumer.yaml
│   ├── solace-app-config.yaml
│   ├── solace-app-secret.yaml
│   └── consumer-hpa.yaml
│
├── monitoring/              # Observability stack
│   ├── prometheus-config.yaml
│   ├── prometheus-deployment.yaml
│   ├── prometheus-service.yaml
│   ├── grafana-deployment.yaml
│   ├── grafana-service.yaml
│   ├── grafana-dashboard-provider.yaml
│   └── grafana-dashboard-solace.yaml
│
├── solace-gitops/            # GitOps source of truth
│   ├── argocd-solace-app.yaml
│   ├── solace/               # App manifests (deployments, hpa)
│   └── monitoring/           # Prometheus & Grafana manifests
│
├── .github/workflows/
│   └── ci-build-push.yaml    # CI → GHCR
│
├── terraform/                # Infrastructure as Code
│   ├── main.tf
│   └── modules/
│       ├── vpc/
│       └── eks/
│
└── README.md

⚙️ Phase 1: Local Setup (Docker + kind)
1️⃣ Run Solace PubSub+ Broker
docker run -d \
  -p 8080:8080 -p 1943:1943 -p 55555:55555 \
  --env username_admin_globalaccesslevel=admin \
  --env username_admin_password=admin \
  --shm-size=2g \
  --name=solace \
  solace/solace-pubsub-standard
Access UI:
👉 http://localhost:8080
Login: admin / admin

2️⃣ Build Producer & Consumer Images
docker build -t solace-producer:local -f Dockerfile.producer .
docker build -t solace-consumer:local -f Dockerfile.consumer .

3️⃣ Create Kubernetes Cluster
kind create cluster --name solace-lab
kind load docker-image solace-producer:local --name solace-lab
kind load docker-image solace-consumer:local --name solace-lab

4️⃣ Deploy Applications
kubectl create namespace solace
kubectl apply -f k8s/ -n solace

📊 Phase 2: Observability (Prometheus + Grafana)
Metrics Exposed
solace_messages_published_total
solace_messages_consumed_total
solace_publish_errors_total
solace_consume_errors_total
Deploy Monitoring Stack
kubectl create namespace monitoring
kubectl apply -f monitoring/ -n monitoring
Access
Prometheus: kubectl port-forward svc/prometheus 9090:9090 -n monitoring
Grafana: kubectl port-forward svc/grafana 3000:3000 -n monitoring
user/pass: admin / admin

📈 Phase 3: Autoscaling with External Metrics
Prometheus Adapter exposes custom metric:
solace_message_lag
HPA scales consumer pods based on lag
Scaling can be paused safely:
minReplicas: 1
maxReplicas: 1
This demonstrates GitOps-controlled autoscaling guardrails.

🔄 Phase 4: CI/CD → GHCR
GitHub Actions Workflow
Builds producer & consumer
Tags images with Git SHA
Pushes to GHCR
Example image:
ghcr.io/khushal-vaishnav/solace-consumer:<commit-sha>
This enables immutable deployments.

♻️ Phase 5: GitOps with ArgoCD
ArgoCD Application
source:
  repoURL: https://github.com/Khushal-vaishnav/solacepubsub-go.git
  path: solace-gitops/solace
Git is the Source of Truth
Any drift (kubectl scale/edit) is detected
ArgoCD reconciles automatically
Supports self-heal + prune

☁️ Phase 6: Infrastructure with Terraform (AWS EKS)
What Was Provisioned
VPC
2 subnets
EKS control plane (no nodes)
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy

🧹 Cleanup
kubectl delete ns solace monitoring argocd
kind delete cluster --name solace-lab
terraform destroy

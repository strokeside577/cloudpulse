# CloudPulse

Automated GKE Deployment & Monitoring Pipeline

## Overview

CloudPulse demonstrates a complete GitOps workflow for deploying microservices to Google Kubernetes Engine (GKE) with integrated observability.

## Architecture

- **App**: Flask REST API with Prometheus metrics
- **Infrastructure**: Terraform for GKE cluster and VPC
- **Deployment**: Helm charts for app and monitoring stack
- **CI/CD**: GitHub Actions for automated deployment
- **Observability**: Prometheus + Grafana for real-time metrics

## Prerequisites

- GCP Project with billing enabled
- Google Cloud SDK installed
- Terraform installed (v1.5.0+)
- Helm installed (v3.12.0+)
- Docker installed
- kubectl configured for your GKE cluster
- GitHub repository with Actions enabled

## Quick Start

### 1. Configure GCP Credentials

```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project
gcloud config set project your-project-id

# Create a service account for GitHub Actions
gcloud iam service-accounts create cloudpulse-ci-cd \
    --display-name="CloudPulse CI/CD Service Account"

# Grant required permissions
gcloud projects add-iam-policy-binding your-project-id \
    --member="serviceAccount:cloudpulse-ci-cd@your-project-id.iam.gserviceaccount.com" \
    --role="roles/owner"

# Create and download key
gcloud iam service-accounts keys create key.json \
    --iam-account=cloudpulse-ci-cd@your-project-id.iam.gserviceaccount.com

# Add secret to GitHub repository
# Settings > Secrets and variables > Actions > New repository secret
# Name: GCP_SA_KEY
# Value: (contents of key.json)
```

### 2. Initialize Terraform State

```bash
cd terraform

# Initialize with backend (requires GCS bucket)
terraform init

# If using local backend for testing
terraform init -backend=false
```

### 3. Deploy Infrastructure

```bash
# Plan the deployment
terraform plan -var-file=dev.tfvars

# Apply the infrastructure (dev)
terraform apply -var-file=dev.tfvars

# For production
terraform apply -var-file=prod.tfvars
```

### 4. Build and Push Docker Image

```bash
cd app

# Build the image
docker build -t cloudpulse:latest .

# Test locally
docker run -p 8080:8080 cloudpulse:latest

# Test health check
curl http://localhost:8080/health

# Push to Artifact Registry (if configured)
docker tag cloudpulse:latest us-central1-docker.pkg.dev/your-project-id/cloudpulse/cloudpulse:latest
docker push us-central1-docker.pkg.dev/your-project-id/cloudpulse/cloudpulse:latest
```

### 5. Deploy with Helm

```bash
# Add Helm repository (if needed)
helm repo add cloudpulse https://your-org.github.io/cloudpulse

# Deploy the application
helm upgrade --install cloudpulse ./helm/cloudpulse \
    --namespace default \
    --set image.repository=us-central1-docker.pkg.dev/your-project-id/cloudpulse/cloudpulse \
    --set image.tag=latest \
    --wait

# Verify deployment
kubectl rollout status deployment/cloudpulse
kubectl get pods -l app.kubernetes.io/name=cloudpulse
```

### 6. Access the Application

```bash
# Port-forward to test locally
kubectl port-forward svc/cloudpulse 8080:80

# Health check
curl http://localhost:8080/health

# Metrics endpoint
curl http://localhost:8080/metrics
```

## Project Structure

```
cloudpulse/
├── app/
│   ├── app.py                  # Flask application with /metrics endpoint
│   ├── requirements.txt        # Python dependencies
│   ├── Dockerfile              # Container definition
│   ├── .dockerignore           # Docker build exclusions
│   └── tests/
│       └── test_app.py         # Application tests
├── terraform/
│   ├── main.tf                 # Root module configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── backend.tf              # GCS remote state backend
│   ├── dev.tfvars              # Dev environment variables
│   ├── prod.tfvars             # Prod environment variables
│   └── modules/
│       ├── network/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── gke/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── helm/
│   └── cloudpulse/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── hpa.yaml
│           ├── configmap.yaml
│           ├── servicemonitor.yaml
│           └── tests/
│               └── test-connection.yaml
├── grafana/
│   └── dashboards/
│       └── cloudpulse-dashboard.json
├── .github/
│   └── workflows/
│       ├── ci-cd.yml
│       └── terraform.yml
├── .tflint.hcl                 # Terraform linting config
├── checkov.yaml                # Security scanning config
└── README.md                   # This file
```

## CI/CD Pipeline

The project uses GitHub Actions for automated CI/CD:

- **On PR**: Runs tests, lints Terraform, runs Checkov security scans, shows Terraform plan
- **On push to main**: Runs tests, builds Docker image, pushes to Artifact Registry, deploys to GKE

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `GCP_SA_KEY` | Service account JSON key for GKE deployment |

## Monitoring

- **Health Check**: `GET /health` returns `{"status": "healthy"}`
- **Metrics**: `GET /metrics` returns Prometheus metrics in text format
- **Grafana Dashboard**: Import `grafana/dashboards/cloudpulse-dashboard.json`

## Local Development

```bash
# Set up virtual environment
cd app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run tests
pytest tests/ -v

# Run locally
python app.py
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | /health | Health check endpoint |
| GET | /metrics | Prometheus metrics |
| GET | /api/todo | List todos |
| POST | /api/todo | Create a todo |

## Security

- Container runs as non-root user (UID 1000)
- Docker image includes security metadata labels
- Health checks for container monitoring
- Terraform security scanning with Checkov
- Network policies enabled on GKE

## Documentation

- For detailed setup instructions, see `docs/` directory
- Helm chart documentation: `helm/cloudpulse/values.yaml`
- Terraform documentation: `terraform/`
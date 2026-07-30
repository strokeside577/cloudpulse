# CloudPulse Deployment Guide

This document provides step-by-step instructions for deploying CloudPulse to Google Kubernetes Engine (GKE).

## Prerequisites

Before deploying, ensure you have:

1. **Google Cloud Account**
   - GCP project with billing enabled
   - Service account with appropriate permissions
   - Docker image repository in Artifact Registry

2. **Local Tools**
   - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (v400+)
   - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (v1.5.0+)
   - [Helm](https://helm.sh/docs/intro/install/) (v3.12.0+)
   - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
   - Docker or compatible container runtime

3. **GitHub Repository**
   - `GCP_SA_KEY` secret added to repository settings
   - Repository connected to Google Cloud Build (optional)

## Deployment Steps

### Step 1: Configure GCP Authentication

```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project
gcloud config set project YOUR-PROJECT-ID

# Create service account (if not exists)
gcloud iam service-accounts create cloudpulse-ci-cd \
    --display-name="CloudPulse CI/CD Service Account"
```

### Step 2: Create Required Cloud Resources

```bash
# Create Artifact Registry repository
gcloud artifacts repositories create cloudpulse \
    --repository-format=docker \
    --location=us-central1 \
    --description="CloudPulse container images"

# Create Terraform state bucket
gcloud storage buckets create gs://cloudpulse-terraform-state \
    --location=us-central1 \
    --uniform-bucket-level-access
```

### Step 3: Initial Terraform Infrastructure Deployment

```bash
cd terraform

# Initialize Terraform
terraform init

# Plan the infrastructure
terraform plan -var="project_id=YOUR-PROJECT-ID" -var="vpc_name=cloudpulse-vpc-dev" -var="subnet_cidr=10.0.0.0/24"

# Apply infrastructure (dev)
terraform apply -var="project_id=YOUR-PROJECT-ID" -var="vpc_name=cloudpulse-vpc-dev" -auto-approve
```

### Step 4: Build and Push Docker Image

```bash
# Build the image
cd app
docker build -t cloudpulse:latest .

# Tag for Artifact Registry
docker tag cloudpulse:latest us-central1-docker.pkg.dev/YOUR-PROJECT-ID/cloudpulse/cloudpulse:latest
docker tag cloudpulse:latest us-central1-docker.pkg.dev/YOUR-PROJECT-ID/cloudpulse/cloudpulse:v1.0.0

# Push to Artifact Registry
docker push us-central1-docker.pkg.dev/YOUR-PROJECT-ID/cloudpulse/cloudpulse:latest
docker push us-central1-docker.pkg.dev/YOUR-PROJECT-ID/cloudpulse/cloudpulse:v1.0.0
```

### Step 5: Deploy to GKE with Helm

```bash
# Get GKE credentials
gcloud container clusters get-credentials cloudpulse-cluster-prod \
    --region us-central1 \
    --project YOUR-PROJECT-ID

# Deploy using Helm
helm upgrade --install cloudpulse ./helm/cloudpulse \
    --namespace default \
    --set image.repository=us-central1-docker.pkg.dev/YOUR-PROJECT-ID/cloudpulse/cloudpulse \
    --set image.tag=v1.0.0 \
    --wait \
    --timeout 5m

# Verify deployment
kubectl rollout status deployment/cloudpulse
kubectl get pods -l app.kubernetes.io/name=cloudpulse
kubectl get svc cloudpulse
```

### Step 6: Access the Application

```bash
# Port-forward to test locally
kubectl port-forward svc/cloudpulse 8080:80

# Test health endpoint
curl http://localhost:8080/health

# Test API
curl http://localhost:8080/api/todo
```

## Configuration Reference

### Docker Image Labels

| Label | Value |
|-------|-------|
| maintainer | CloudPulse Team |
| version | 1.0.0 |
| description | CloudPulse Flask application with Prometheus metrics |
| org.opencontainers.image.source | https://github.com/your-org/cloudpulse |

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| LOG_LEVEL | Application log level | info |
| ENVIRONMENT | Environment name | production |

### Kubernetes Resources

| Resource | Default | Production |
|----------|---------|------------|
| Replicas | 2 | 3 |
| CPU Limit | 500m | 500m |
| Memory Limit | 512Mi | 512Mi |
| CPU Request | 250m | 250m |
| Memory Request | 256Mi | 256Mi |

## Monitoring

### Health Check

```bash
# Container health check
docker inspect <container-id> --format='{{json .State.Health}}'

# Kubernetes liveness probe
kubectl get pods -l app.kubernetes.io/name=cloudpulse -o=jsonpath='{.items[*].status.containerStatuses[0].health}'
```

### Prometheus Metrics

The application exposes metrics at `/metrics`:

```bash
# Via port-forward
curl http://localhost:8080/metrics | head -20

# Available metrics:
# - http_requests_total (Counter)
# - http_request_duration_seconds (Histogram)
# - python_gc_* (System metrics)
# - process_* (Process metrics)
```

### Grafana Dashboard

Import `grafana/dashboards/cloudpulse-dashboard.json` into Grafana for:
- Request Rate
- Request Latency (95th/50th percentile)
- Error Rate
- Pod CPU Usage
- Pod Memory Usage
- Replica Count

## CI/CD Pipeline

The project uses GitHub Actions for automated CI/CD:

### Workflows

| Workflow | Purpose | Triggers |
|----------|---------|----------|
| CI/CD Pipeline | Build, test, and deploy | Push to main/develop |
| Terraform | Infrastructure as Code | Push to terraform/** |
| Demo Test | Local testing without GCP | Manual trigger |

### Required Secrets

Add to GitHub repository settings:

| Secret | Description |
|--------|-------------|
| `GCP_SA_KEY` | GCP Service Account JSON key |

## Troubleshooting

### Common Issues

1. **Image Pull Errors**
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

2. **Health Check Failures**
   ```bash
   kubectl describe pod <pod-name>
   # Check container logs and restart counts
   ```

3. **Permission Errors**
   ```bash
   # Verify service account permissions
   gcloud projects get-iam-policy YOUR-PROJECT-ID
   ```

4. **Terraform State Lock**
   ```bash
   terraform force-unlock <LOCK_ID>
   ```

## Rollback Procedure

```bash
# Rollback Helm release
helm rollback cloudpulse <REVISION_NUMBER>

# Or rollback to specific version
helm rollback cloudpulse --set image.tag=previous-tag
```

## Cleanup

To remove all resources:

```bash
# Uninstall Helm release
helm uninstall cloudpulse

# Destroy Terraform infrastructure
cd terraform
terraform destroy -var="project_id=YOUR-PROJECT-ID"
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-30 | Initial release with Flask app, Prometheus metrics, GKE deployment |
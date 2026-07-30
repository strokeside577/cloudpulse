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

## Quick Start
1. Configure GCP credentials and service account
2. Run Terraform to provision infrastructure
3. Deploy app via Helm
4. Access Grafana dashboards

## Documentation
See `docs/` for detailed setup instructions.

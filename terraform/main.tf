terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  
  required_version = ">= 1.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "network" {
  source = "./modules/network"
  
  project_id  = var.project_id
  region      = var.region
  vpc_name    = "${var.vpc_name}-${var.environment}"
  subnet_cidr = var.subnet_cidr
}

module "gke" {
  source = "./modules/gke"
  
  project_id            = var.project_id
  region                = var.region
  cluster_name          = "${var.cluster_name}-${var.environment}"
  network_id            = module.network.network_id
  subnet_name           = module.network.subnet_name
  pods_range_name       = module.network.pods_range_name
  services_range_name   = module.network.services_range_name
  node_count            = var.node_count
  machine_type          = var.machine_type
  min_nodes             = var.min_nodes
  max_nodes             = var.max_nodes
}
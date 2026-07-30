variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR range"
  type        = string
}

variable "node_count" {
  description = "Initial node count"
  type        = number
}

variable "machine_type" {
  description = "Node machine type"
  type        = string
}

variable "min_nodes" {
  description = "Minimum nodes for autoscaling"
  type        = number
}

variable "max_nodes" {
  description = "Maximum nodes for autoscaling"
  type        = number
}
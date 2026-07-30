output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.cluster_name
}

output "network_id" {
  description = "Network ID"
  value       = module.network.network_id
}
output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = google_container_cluster.cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_name" {
  description = "Cluster name"
  value       = google_container_cluster.cluster.name
}

output "location" {
  description = "Cluster location"
  value       = google_container_cluster.cluster.location
}

output "node_pool_name" {
  description = "Node pool name"
  value       = google_container_node_pool.node_pool.name
}
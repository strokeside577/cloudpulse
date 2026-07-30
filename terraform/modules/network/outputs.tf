output "network_id" {
  description = "VPC network ID"
  value       = google_compute_network.vpc.id
}

output "subnet_id" {
  description = "Subnetwork ID"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "Subnetwork name"
  value       = google_compute_subnetwork.subnet.name
}

output "pods_range_name" {
  description = "Pods IP range name"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
}

output "services_range_name" {
  description = "Services IP range name"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
}
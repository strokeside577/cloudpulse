resource "google_container_cluster" "cluster" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.region
  
  network = var.network_id
  subnetwork = var.subnet_name
  
  remove_default_node_pool = true
  initial_node_count = 1
  
  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
  
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
  }
  
  network_policy {
    enabled = true
  }
  
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }
  
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
  }
  
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  
  release_channel {
    channel = "REGULAR"
  }
  
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "node_pool" {
  name    = "${var.cluster_name}-node-pool"
  project = var.project_id
  location = var.region
  cluster = google_container_cluster.cluster.name
  
  node_count = var.node_count
  
  node_config {
    machine_type = var.machine_type
    disk_size_gb = 100
    disk_type    = "pd-standard"
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
  
  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }
  
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}
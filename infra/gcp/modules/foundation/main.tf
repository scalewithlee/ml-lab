// The foundation module contains things like cloud storage and networking.
// Put things here that probably don't change very often.
// This module should be able to be used by things other than ML infra

# Google provider config
provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs, it not already enabled
resource "google_project_service" "gcp_services" {
  for_each           = toset(var.gcp_services)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false

  # Ensure services are created before other resources
  lifecycle {
    ignore_changes = []
  }
}

# VPC network for ML infra
resource "google_compute_network" "ml_network" {
  name                    = "${var.environment}-ml-network"
  auto_create_subnetworks = false
  description             = "VPC network for ml infra"
}

# Subnet for GKE cluster
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "${var.environment}-gke-subnet"
  ip_cidr_range = var.gke_subnet_cidr
  region        = var.region
  network       = google_compute_network.ml_network.id

  # Enable private access to google APIs (e.g. for pulling images)
  private_ip_google_access = true

  # Enable VPC flow logs
  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  # Secondary IP ranges for pods and services
  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = var.gke_pod_cidr
  }

  secondary_ip_range {
    range_name    = "service-range"
    ip_cidr_range = var.gke_service_cidr
  }
}

# Router for NAT gateway
resource "google_compute_router" "router" {
  name    = "${var.environment}-ml-router"
  region  = var.region
  network = google_compute_network.ml_network.id
}
# NAT gateway for outbound traffic
resource "google_compute_router_nat" "nat" {
  name                               = "${var.environment}-ml-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall rule for internal cluster communication
resource "google_compute_firewall" "internal" {
  name    = "${var.environment}-ml-internal"
  network = google_compute_network.ml_network.id

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [var.gke_subnet_cidr, var.gke_pod_cidr]
}

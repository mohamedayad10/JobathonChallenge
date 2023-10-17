# Specify the provider and authentication details
provider "google" {
  credentials = file("path/to/your/credentials.json")
  project     = "your-project-id"
  region      = "us-central1"
}

# Create a GKE cluster
resource "google_container_cluster" "cluster" {
  name               = "app"
  location           = "us-central1"
  initial_node_count = 3

  master_auth {
    username = ""
    password = ""
  }

  node_config {
    machine_type = "n1-standard-2"
    disk_size_gb = 100
  }
}

# Output the cluster information
output "cluster_name" {
  value = google_container_cluster.cluster.name
}

output "cluster_endpoint" {
  value = google_container_cluster.cluster.endpoint
}

output "cluster_master_version" {
  value = google_container_cluster.cluster.master_version
}

# Create a firewall rule to allow access to the cluster
resource "google_compute_firewall" "firewall" {
  name    = "allow-gke-access"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_tags = ["allow-gke"]
  target_tags = [google_container_cluster.cluster.name]
}

# Create a static IP address for the cluster
resource "google_compute_address" "static_ip" {
  name         = "cluster-ip"
  address_type = "EXTERNAL"
}

# Associate the static IP address with the cluster
resource "google_container_cluster_iam_member" "static_ip_binding" {
  cluster    = google_container_cluster.cluster.name
  location   = google_container_cluster.cluster.location
  role       = "roles/container.clusterViewer"
  member     = "allAuthenticatedUsers"
}

# Output the static IP address
output "static_ip_address" {
  value = google_compute_address.static_ip.address
}

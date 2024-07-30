# Define firewall rules
# resource "google_compute_firewall" "allow_internal" {
#   name    = "allow-internal"
#   network = google_compute_network.custom_network.name

#   allow {
#     protocol = "icmp"
#   }

#   allow {
#     protocol = "tcp"
#     ports    = ["0-65535"]
#   }

#   allow {
#     protocol = "udp"
#     ports    = ["0-65535"]
#   }

#   source_ranges = ["10.0.0.0/16"]
# }

# resource "google_compute_firewall" "allow_ssh" {
#   name    = "allow-ssh"
#   network = google_compute_network.custom_network.name

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   source_ranges = ["0.0.0.0/0"]
# }

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  # network = google_compute_network.default.name
	network = google_compute_instance.this.network_interface[0].network

  allow {
    protocol = "http"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}
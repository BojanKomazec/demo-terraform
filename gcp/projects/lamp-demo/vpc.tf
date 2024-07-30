# Define the custom VPC
# resource "google_compute_network" "custom_network" {
#   name                    = "custom-vpc"
#   auto_create_subnetworks = false
# }

data "google_compute_network" "default" {
  # name = "default-europe-west4"
	name = "default"
}

# Define a subnet within the custom VPC
# resource "google_compute_subnetwork" "custom_subnet" {
#   name          = "custom-subnet"
#   ip_cidr_range = "10.0.0.0/16"
#   region        = "us-central1"
#   network       = google_compute_network.custom_network.id
# }
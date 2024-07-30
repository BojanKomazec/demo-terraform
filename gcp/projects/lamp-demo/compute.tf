resource "google_compute_instance" "this" {
	# (Required) A unique name for the resource, required by GCE. Changing this
	# forces a new resource to be created.
  name         = "bloghost"

	# (Required) The machine type to create.
  machine_type = "e2-medium"

	# (Optional) The zone that the machine should be created in. If it is not
	# provided, the provider zone is used.
  zone         = "europe-west4-b"

	# (Required) The boot disk for the instance.
  boot_disk {
    initialize_params {
      # image = "debian-cloud/debian-10"
			image = "debian-cloud/debian-11"
    }
  }

	# (Required) Networks to attach to the instance. This can be specified
	# multiple times.
  network_interface {
		# A default network is created for all GCP projects
    network = "default"
		# network = data.google_compute_network.default.self_link
    access_config {
				# Ephemeral public IP
    }
  }

	# (Optional) Metadata key/value pairs to make available from within the instance.
  # metadata = {
  #   enable-oslogin : "TRUE"
  # }

	# (Optional) An alternative to using the startup-script metadata key, except
	# this one forces the instance to be recreated (thus re-running the script) if
	# it is changed.
	# metadata_startup_script = "echo hi > /test.txt"

	// deploy busybox
 	metadata_startup_script = "apt update; apt upgrade; apt install apache2 php php-mysql -y;service apache2 restart;"

  # service_account {
  #   # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
  #   email  = google_service_account.default.email
  #   scopes = ["cloud-platform"]
  # }
}
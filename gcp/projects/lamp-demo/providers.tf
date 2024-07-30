# Specify the Terraform version
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.37.0"
    }
  }
}

provider "google" {
  project = "lamp-demo-429400"
  region  = "europe-west4"
  access_token = var.access_token
}

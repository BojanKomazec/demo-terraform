terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
      version = "3.4.3"
    }

    local = {
      source = "hashicorp/local"
      version = "2.5.1"
    }
  }
}
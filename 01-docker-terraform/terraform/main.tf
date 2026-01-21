terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.16.0"
    }
  }
}

provider "google" {
  credentials = "./keys/my-creds.json"
  project     = "terraform-demo-485008"
  region      = "africa-south1"
}

resource "google_storage_bucket" "demo-bucket" {
  name          = "terraform-demo-485008-bucket"
  location      = "africa-south1"
  force_destroy = true



  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project     = "quiosquefood3000"
  region      = "us-central1"
  credentials = file("./autenticacao.json")
}

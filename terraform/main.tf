terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("gcp.json")

  project = var.project
  region  = var.region
  zone    = "${var.region}-a"
}


resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}


resource "google_compute_firewall" "vpc_icmp" {
  name    = "terraform-icmp-allow"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  target_tags   = ["icmp-allow"]
    
}


resource "google_compute_firewall" "vpc_http" {
  name    = "terraform-http-allow"
  network = google_compute_network.vpc_network.name
    
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  target_tags   = ["http-allow"]
      
}


resource "google_compute_firewall" "vpc_https" {
  name    = "terraform-https-allow"
  network = google_compute_network.vpc_network.name

  
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags   = ["https-allow"]
      
}

resource "google_compute_firewall" "vpc_ssh" {
  name    = "terraform-ssh-allow"
  network = google_compute_network.vpc_network.name

  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["ssh-allow"]
      
}


resource "google_compute_instance" "eschool-srv" {
  name         = "eschool-srv"
  machine_type = var.instance
  tags         = ["ssh-allow","http-allow","https-allow","icmp-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210720"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }

  metadata_startup_script = file("./first_run.sh")
  
  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
    
  }
  
}


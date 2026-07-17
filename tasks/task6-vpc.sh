#!/bin/bash
# Task 6: Use Module from Registry

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }

read -p "Enter Project ID: " PROJECT_ID
read -p "Enter Bucket Name: " BUCKET_NAME
read -p "Enter VPC Name: " VPC_NAME

cd ~
cat > main.tf << EOF
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket  = "$BUCKET_NAME"
    prefix  = "terraform/state"
  }
}
provider "google" {
  project = "$PROJECT_ID"
  region  = "us-central1"
  zone    = "us-central1-a"
}
module "instances" {
  source     = "./modules/instances"
  region     = "us-central1"
  zone       = "us-central1-a"
  project_id = "$PROJECT_ID"
}
module "storage" {
  source     = "./modules/storage"
  region     = "us-central1"
  project_id = "$PROJECT_ID"
}
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "10.0.0"
  project_id   = "$PROJECT_ID"
  network_name = "$VPC_NAME"
  routing_mode = "GLOBAL"
  subnets = [
    { subnet_name = "subnet-01", subnet_ip = "10.10.10.0/24", subnet_region = "us-central1" },
    { subnet_name = "subnet-02", subnet_ip = "10.10.20.0/24", subnet_region = "us-central1" }
  ]
}
EOF

cat > modules/instances/instances.tf << EOF
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = var.zone
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "$VPC_NAME", subnetwork = "subnet-01" }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         = var.zone
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "$VPC_NAME", subnetwork = "subnet-02" }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF

terraform init
terraform plan
terraform apply -auto-approve
print_success "Task 6 completed!"

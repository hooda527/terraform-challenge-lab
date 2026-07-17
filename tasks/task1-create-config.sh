#!/bin/bash
# Task 1: Create Configuration Files

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }

read -p "Enter Project ID: " PROJECT_ID
read -p "Enter Bucket Name: " BUCKET_NAME

cd ~
mkdir -p modules/instances modules/storage

cat > variables.tf << EOF
variable "region" {
  description = "The region to deploy resources"
  default     = "us-central1"
}
variable "zone" {
  description = "The zone to deploy resources"
  default     = "us-central1-a"
}
variable "project_id" {
  description = "The project ID"
  default     = "$PROJECT_ID"
}
EOF

cat > main.tf << EOF
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
module "instances" {
  source     = "./modules/instances"
  region     = var.region
  zone       = var.zone
  project_id = var.project_id
}
module "storage" {
  source     = "./modules/storage"
  region     = var.region
  project_id = var.project_id
}
EOF

cat > modules/instances/variables.tf << EOF
variable "region" {}
variable "zone" {}
variable "project_id" {}
EOF

cat > modules/instances/instances.tf << EOF
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-medium"
  zone         = var.zone
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "default" }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-medium"
  zone         = var.zone
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "default" }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF

cat > modules/instances/outputs.tf << EOF
output "instance_1_name" { value = google_compute_instance.tf-instance-1.name }
output "instance_2_name" { value = google_compute_instance.tf-instance-2.name }
EOF

cat > modules/storage/variables.tf << EOF
variable "region" {}
variable "project_id" {}
EOF

cat > modules/storage/storage.tf << EOF
resource "google_storage_bucket" "tf-bucket" {
  name        = "$BUCKET_NAME"
  location    = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}
EOF

cat > modules/storage/outputs.tf << EOF
output "bucket_name" { value = google_storage_bucket.tf-bucket.name }
EOF

terraform init
print_success "Task 1 completed!"

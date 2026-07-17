#!/bin/bash
# Task 3: Configure Remote Backend

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }

read -p "Enter Project ID: " PROJECT_ID
read -p "Enter Bucket Name: " BUCKET_NAME

cd ~
terraform apply -auto-approve

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
EOF

terraform init -migrate-state <<< "yes"
terraform apply -auto-approve
print_success "Task 3 completed!"

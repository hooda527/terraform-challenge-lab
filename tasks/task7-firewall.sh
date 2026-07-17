#!/bin/bash
# Task 7: Configure Firewall

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }

read -p "Enter VPC Name: " VPC_NAME

cd ~
cat >> main.tf << EOF

resource "google_compute_firewall" "tf-firewall" {
  name    = "tf-firewall"
  network = "$VPC_NAME"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}
EOF

terraform init
terraform plan
terraform apply -auto-approve
print_success "Task 7 completed!"

#!/bin/bash
# Task 2: Import Infrastructure

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }

cd ~
print_info "Get Instance IDs from Compute Engine > VM Instances"
read -p "Enter Instance ID for tf-instance-1: " INSTANCE_ID_1
read -p "Enter Instance ID for tf-instance-2: " INSTANCE_ID_2

terraform import module.instances.google_compute_instance.tf-instance-1 $INSTANCE_ID_1
terraform import module.instances.google_compute_instance.tf-instance-2 $INSTANCE_ID_2

terraform plan
terraform apply -auto-approve
print_success "Task 2 completed!"

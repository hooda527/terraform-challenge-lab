#!/bin/bash

# Terraform Challenge Lab Solver
# Automatically solves all tasks in the challenge lab

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
PROJECT_ID=""
BUCKET_NAME=""
INSTANCE_NAME=""
VPC_NAME=""
REGION="us-central1"
ZONE="us-central1-a"

# Print banner
print_banner() {
    echo -e "${BLUE}"
    echo "=========================================="
    echo "   Terraform Challenge Lab Solver"
    echo "=========================================="
    echo -e "${NC}"
}

# Print section header
print_section() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Print success message
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error message
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Print info message
print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Get project configuration
get_config() {
    print_section "Configuration"

    if [ -z "$PROJECT_ID" ]; then
        read -p "Enter your Project ID: " PROJECT_ID
    fi

    if [ -z "$BUCKET_NAME" ]; then
        read -p "Enter Bucket Name: " BUCKET_NAME
    fi

    if [ -z "$INSTANCE_NAME" ]; then
        read -p "Enter Instance Name: " INSTANCE_NAME
    fi

    if [ -z "$VPC_NAME" ]; then
        read -p "Enter VPC Name: " VPC_NAME
    fi

    print_info "Project ID: $PROJECT_ID"
    print_info "Bucket Name: $BUCKET_NAME"
    print_info "Instance Name: $INSTANCE_NAME"
    print_info "VPC Name: $VPC_NAME"
}

# Install Terraform
install_terraform() {
    print_section "Installing Terraform"

    if command -v terraform &> /dev/null; then
        print_success "Terraform already installed"
        terraform --version
        return
    fi

    print_info "Installing Terraform..."
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install -y terraform

    print_success "Terraform installed"
    terraform --version
}

# Task 1: Create configuration files
task1() {
    print_section "Task 1: Create Configuration Files"

    # Create directory structure
    print_info "Creating directory structure..."
    cd ~
    mkdir -p modules/instances modules/storage

    # Create root variables.tf
    print_info "Creating root variables.tf..."
    cat > variables.tf << EOF
variable "region" {
  description = "The region to deploy resources"
  default     = "$REGION"
}

variable "zone" {
  description = "The zone to deploy resources"
  default     = "$ZONE"
}

variable "project_id" {
  description = "The project ID"
  default     = "$PROJECT_ID"
}
EOF

    # Create root main.tf
    print_info "Creating root main.tf..."
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
EOF

    # Create modules/instances/variables.tf
    print_info "Creating modules/instances/variables.tf..."
    cat > modules/instances/variables.tf << EOF
variable "region" {
  description = "The region to deploy resources"
}

variable "zone" {
  description = "The zone to deploy resources"
}

variable "project_id" {
  description = "The project ID"
}
EOF

    # Create modules/instances/instances.tf
    print_info "Creating modules/instances/instances.tf..."
    cat > modules/instances/instances.tf << EOF
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT

  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT

  allow_stopping_for_update = true
}
EOF

    # Create modules/instances/outputs.tf
    print_info "Creating modules/instances/outputs.tf..."
    cat > modules/instances/outputs.tf << EOF
output "instance_1_name" {
  value = google_compute_instance.tf-instance-1.name
}

output "instance_2_name" {
  value = google_compute_instance.tf-instance-2.name
}
EOF

    # Create modules/storage/variables.tf
    print_info "Creating modules/storage/variables.tf..."
    cat > modules/storage/variables.tf << EOF
variable "region" {
  description = "The region to deploy resources"
}

variable "project_id" {
  description = "The project ID"
}
EOF

    # Create modules/storage/storage.tf
    print_info "Creating modules/storage/storage.tf..."
    cat > modules/storage/storage.tf << EOF
resource "google_storage_bucket" "tf-bucket" {
  name        = "$BUCKET_NAME"
  location    = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}
EOF

    # Create modules/storage/outputs.tf
    print_info "Creating modules/storage/outputs.tf..."
    cat > modules/storage/outputs.tf << EOF
output "bucket_name" {
  value = google_storage_bucket.tf-bucket.name
}
EOF

    # Add module references to main.tf
    print_info "Adding module references to main.tf..."
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

    # Initialize Terraform
    print_info "Initializing Terraform..."
    terraform init

    print_success "Task 1 completed!"
}

# Task 2: Import infrastructure
task2() {
    print_section "Task 2: Import Infrastructure"

    print_info "Please get Instance IDs from Compute Engine > VM Instances"
    read -p "Enter Instance ID for tf-instance-1: " INSTANCE_ID_1
    read -p "Enter Instance ID for tf-instance-2: " INSTANCE_ID_2

    print_info "Importing instances..."
    terraform import module.instances.google_compute_instance.tf-instance-1 $INSTANCE_ID_1
    terraform import module.instances.google_compute_instance.tf-instance-2 $INSTANCE_ID_2

    print_info "Applying changes..."
    terraform plan
    terraform apply -auto-approve

    print_success "Task 2 completed!"
}

# Task 3: Configure remote backend
task3() {
    print_section "Task 3: Configure Remote Backend"

    print_info "Applying current configuration..."
    terraform apply -auto-approve

    print_info "Adding GCS backend to main.tf..."
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

    print_info "Initializing with migration..."
    terraform init -migrate-state <<< "yes"

    print_info "Applying changes..."
    terraform apply -auto-approve

    print_success "Task 3 completed!"
}

# Task 4: Modify and update infrastructure
task4() {
    print_section "Task 4: Modify and Update Infrastructure"

    print_info "Updating instances with e2-standard-2 and adding third instance..."
    cat > modules/instances/instances.tf << EOF
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT

  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT

  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-3" {
  name         = "$INSTANCE_NAME"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT

  allow_stopping_for_update = true
}
EOF

    print_info "Applying changes..."
    terraform plan
    terraform apply -auto-approve

    print_success "Task 4 completed!"
}

# Task 5: Destroy resources
task5() {
    print_section "Task 5: Destroy Resources"

    print_info "Removing third instance..."
    cat > modules/instances/instances.tf << EOF
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT

  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT

  allow_stopping_for_update = true
}
EOF

    print_info "Initializing and applying..."
    terraform init
    terraform apply -auto-approve

    print_success "Task 5 completed!"
}

# Task 6: Use module from Registry
task6() {
    print_section "Task 6: Use Module from Registry"

    print_info "Adding VPC network module..."
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

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "10.0.0"

  project_id   = var.project_id
  network_name = "$VPC_NAME"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = var.region
    },
    {
      subnet_name   = "subnet-02"
      subnet_ip     = "10.10.20.0/24"
      subnet_region = var.region
    }
  ]
}
EOF

    print_info "Updating instances to use new VPC..."
    cat > modules/instances/instances.tf << EOF
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = "$VPC_NAME"
    subnetwork = "subnet-01"
  }

  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT

  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = "$VPC_NAME"
    subnetwork = "subnet-02"
  }

  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT

  allow_stopping_for_update = true
}
EOF

    print_info "Initializing and applying..."
    terraform init
    terraform plan
    terraform apply -auto-approve

    print_success "Task 6 completed!"
}

# Task 7: Configure firewall
task7() {
    print_section "Task 7: Configure Firewall"

    print_info "Adding firewall rule to main.tf..."
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

    print_info "Initializing and applying..."
    terraform init
    terraform plan
    terraform apply -auto-approve

    print_success "Task 7 completed!"
}

# Run all tasks
run_all() {
    print_section "Running All Tasks"

    task1
    task2
    task3
    task4
    task5
    task6
    task7

    print_success "All tasks completed!"
}

# Main function
main() {
    print_banner

    # Get configuration
    get_config

    # Install Terraform
    install_terraform

    # Run selected task or all
    if [ -z "$1" ]; then
        echo -e "\n${YELLOW}Select task to run:${NC}"
        echo "1) task1 - Create configuration files"
        echo "2) task2 - Import infrastructure"
        echo "3) task3 - Configure remote backend"
        echo "4) task4 - Modify and update"
        echo "5) task5 - Destroy resources"
        echo "6) task6 - Use Registry module"
        echo "7) task7 - Configure firewall"
        echo "8) all - Run all tasks"
        read -p "Enter choice [1-8]: " choice

        case $choice in
            1) task1 ;;
            2) task2 ;;
            3) task3 ;;
            4) task4 ;;
            5) task5 ;;
            6) task6 ;;
            7) task7 ;;
            8) run_all ;;
            *) print_error "Invalid choice"; exit 1 ;;
        esac
    else
        case $1 in
            task1) task1 ;;
            task2) task2 ;;
            task3) task3 ;;
            task4) task4 ;;
            task5) task5 ;;
            task6) task6 ;;
            task7) task7 ;;
            all) run_all ;;
            *) print_error "Unknown task: $1"; exit 1 ;;
        esac
    fi
}

# Run main function
main "$@"

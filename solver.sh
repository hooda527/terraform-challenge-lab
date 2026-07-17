#!/bin/bash

# Terraform Challenge Lab Solver
# Project: qwiklabs-gcp-02-e9ef3f99ca82
# Bucket: tf-bucket-159100
# Instance: tf-instance-818696
# VPC: tf-vpc-984625

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_step() { echo -e "\n${YELLOW}━━━ $1 ━━━${NC}"; }

PROJECT_ID="qwiklabs-gcp-02-e9ef3f99ca82"
BUCKET_NAME="tf-bucket-159100"
INSTANCE_NAME="tf-instance-818696"
VPC_NAME="tf-vpc-984625"

echo -e "${BLUE}=========================================="
echo "   Terraform Challenge Lab Solver"
echo "   Project: $PROJECT_ID"
echo "==========================================${NC}"

# ==================== TASK 1 ====================
print_step "TASK 1: Create Configuration Files"

cd ~
rm -rf modules terraform.tf* variables.tf main.tf .terraform
mkdir -p modules/instances modules/storage

cat > variables.tf <<'EOF'
variable "region" {
  default = "us-central1"
}
variable "zone" {
  default = "us-central1-a"
}
variable "project_id" {
  default = "qwiklabs-gcp-02-e9ef3f99ca82"
}
EOF

cat > main.tf <<'EOF'
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

cat > modules/instances/variables.tf <<'EOF'
variable "region" {}
variable "zone" {}
variable "project_id" {}
EOF

cat > modules/instances/instances.tf <<'EOF'
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

cat > modules/instances/outputs.tf <<'EOF'
output "instance_1_name" {
  value = google_compute_instance.tf-instance-1.name
}
output "instance_2_name" {
  value = google_compute_instance.tf-instance-2.name
}
EOF

cat > modules/storage/variables.tf <<'EOF'
variable "region" {}
variable "project_id" {}
EOF

cat > modules/storage/storage.tf <<'EOF'
resource "google_storage_bucket" "tf-bucket" {
  name                        = "tf-bucket-159100"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}
EOF

cat > modules/storage/outputs.tf <<'EOF'
output "bucket_name" {
  value = google_storage_bucket.tf-bucket.name
}
EOF

terraform init
print_success "Task 1: Configuration files created!"

# ==================== TASK 2 ====================
print_step "TASK 2: Import Infrastructure"

print_info "Getting instance IDs from GCP..."
INSTANCE_ID_1=$(gcloud compute instances describe tf-instance-1 --zone=us-central1-a --format="value(id)" 2>/dev/null || echo "")
INSTANCE_ID_2=$(gcloud compute instances describe tf-instance-2 --zone=us-central1-a --format="value(id)" 2>/dev/null || echo "")

if [ -z "$INSTANCE_ID_1" ]; then
    print_info "Could not auto-detect instance IDs. Getting from console..."
    read -p "Enter Instance ID for tf-instance-1: " INSTANCE_ID_1
    read -p "Enter Instance ID for tf-instance-2: " INSTANCE_ID_2
else
    print_info "Instance 1 ID: $INSTANCE_ID_1"
    print_info "Instance 2 ID: $INSTANCE_ID_2"
fi

terraform import module.instances.google_compute_instance.tf-instance-1 $INSTANCE_ID_1
terraform import module.instances.google_compute_instance.tf-instance-2 $INSTANCE_ID_2

terraform plan
terraform apply -auto-approve
print_success "Task 2: Infrastructure imported!"

# ==================== TASK 3 ====================
print_step "TASK 3: Configure Remote Backend"

terraform apply -auto-approve

cat > main.tf <<'EOF'
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket  = "tf-bucket-159100"
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

terraform init -migrate-state <<< "yes"
terraform apply -auto-approve
print_success "Task 3: Remote backend configured!"

# ==================== TASK 4 ====================
print_step "TASK 4: Modify and Update Infrastructure"

cat > modules/instances/instances.tf <<'EOF'
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
  name         = "tf-instance-818696"
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

terraform plan
terraform apply -auto-approve
print_success "Task 4: Infrastructure modified!"

# ==================== TASK 5 ====================
print_step "TASK 5: Destroy Resources"

cat > modules/instances/instances.tf <<'EOF'
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

terraform init
terraform apply -auto-approve
print_success "Task 5: Resources destroyed!"

# ==================== TASK 6 ====================
print_step "TASK 6: Use Module from Registry"

cat > main.tf <<'EOF'
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket  = "tf-bucket-159100"
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
  network_name = "tf-vpc-984625"
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

cat > modules/instances/instances.tf <<'EOF'
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
    network    = "tf-vpc-984625"
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
    network    = "tf-vpc-984625"
    subnetwork = "subnet-02"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF

terraform init
terraform plan
terraform apply -auto-approve
print_success "Task 6: VPC created!"

# ==================== TASK 7 ====================
print_step "TASK 7: Configure Firewall"

cat >> main.tf <<'EOF'

resource "google_compute_firewall" "tf-firewall" {
  name    = "tf-firewall"
  network = "tf-vpc-984625"

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
print_success "Task 7: Firewall configured!"

# ==================== DONE ====================
echo -e "\n${GREEN}=========================================="
echo "   ALL TASKS COMPLETED!"
echo "   Click Check my progress for each task"
echo "==========================================${NC}"

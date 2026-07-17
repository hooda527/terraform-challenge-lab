#!/bin/bash

# Terraform Challenge Lab Solver - FULLY AUTOMATIC
# Project: qwiklabs-gcp-02-e9ef3f99ca82
# Bucket: tf-bucket-159100
# Instance: tf-instance-818696
# VPC: tf-vpc-984625

set -e

PROJECT_ID="qwiklabs-gcp-02-e9ef3f99ca82"
BUCKET_NAME="tf-bucket-159100"
INSTANCE_NAME="tf-instance-818696"
VPC_NAME="tf-vpc-984625"
REGION="us-central1"
ZONE="us-central1-a"

echo "=========================================="
echo "   Terraform Challenge Lab Solver"
echo "   Auto-solving all 7 tasks..."
echo "=========================================="

# ==================== TASK 1 ====================
echo ""
echo ">>> TASK 1: Create Configuration Files"

cd ~
rm -rf modules terraform.tf* variables.tf main.tf .terraform terraform.tfstate* 2>/dev/null || true
mkdir -p modules/instances modules/storage

cat > variables.tf <<EOF
variable "region" {
  default = "$REGION"
}
variable "zone" {
  default = "$ZONE"
}
variable "project_id" {
  default = "$PROJECT_ID"
}
EOF

cat > main.tf <<EOF
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

cat > modules/instances/variables.tf <<EOF
variable "region" {}
variable "zone" {}
variable "project_id" {}
EOF

cat > modules/instances/instances.tf <<EOF
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

cat > modules/instances/outputs.tf <<EOF
output "instance_1_name" {
  value = google_compute_instance.tf-instance-1.name
}
output "instance_2_name" {
  value = google_compute_instance.tf-instance-2.name
}
EOF

cat > modules/storage/variables.tf <<EOF
variable "region" {}
variable "project_id" {}
EOF

cat > modules/storage/storage.tf <<EOF
resource "google_storage_bucket" "tf-bucket" {
  name                        = "$BUCKET_NAME"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}
EOF

cat > modules/storage/outputs.tf <<EOF
output "bucket_name" {
  value = google_storage_bucket.tf-bucket.name
}
EOF

terraform init
echo "TASK 1 DONE"

# ==================== TASK 2 ====================
echo ""
echo ">>> TASK 2: Import Infrastructure"

INSTANCE_ID_1=$(gcloud compute instances describe tf-instance-1 --zone=$ZONE --project=$PROJECT_ID --format="value(id)" 2>/dev/null || echo "")
INSTANCE_ID_2=$(gcloud compute instances describe tf-instance-2 --zone=$ZONE --project=$PROJECT_ID --format="value(id)" 2>/dev/null || echo "")

echo "Instance 1 ID: $INSTANCE_ID_1"
echo "Instance 2 ID: $INSTANCE_ID_2"

terraform import module.instances.google_compute_instance.tf-instance-1 $INSTANCE_ID_1
terraform import module.instances.google_compute_instance.tf-instance-2 $INSTANCE_ID_2

terraform apply -auto-approve
echo "TASK 2 DONE"

# ==================== TASK 3 ====================
echo ""
echo ">>> TASK 3: Configure Remote Backend"

terraform apply -auto-approve

cat > main.tf <<EOF
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

terraform init -migrate-state <<< "yes"
terraform apply -auto-approve
echo "TASK 3 DONE"

# ==================== TASK 4 ====================
echo ""
echo ">>> TASK 4: Modify and Update Infrastructure"

cat > modules/instances/instances.tf <<EOF
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

terraform apply -auto-approve
echo "TASK 4 DONE"

# ==================== TASK 5 ====================
echo ""
echo ">>> TASK 5: Destroy Resources"

cat > modules/instances/instances.tf <<EOF
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
echo "TASK 5 DONE"

# ==================== TASK 6 ====================
echo ""
echo ">>> TASK 6: Use Module from Registry"

cat > main.tf <<EOF
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

cat > modules/instances/instances.tf <<EOF
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

terraform init
terraform apply -auto-approve
echo "TASK 6 DONE"

# ==================== TASK 7 ====================
echo ""
echo ">>> TASK 7: Configure Firewall"

cat >> main.tf <<EOF

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
terraform apply -auto-approve
echo "TASK 7 DONE"

echo ""
echo "=========================================="
echo "   ALL 7 TASKS COMPLETED!"
echo "   Click Check my progress for each task"
echo "=========================================="

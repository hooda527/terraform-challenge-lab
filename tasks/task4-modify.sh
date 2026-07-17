#!/bin/bash
# Task 4: Modify and Update Infrastructure

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }

read -p "Enter Instance Name: " INSTANCE_NAME

cd ~
cat > modules/instances/instances.tf << EOF
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
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
  machine_type = "e2-standard-2"
  zone         = var.zone
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "default" }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
resource "google_compute_instance" "tf-instance-3" {
  name         = "$INSTANCE_NAME"
  machine_type = "e2-standard-2"
  zone         = var.zone
  boot_disk { initialize_params { image = "debian-cloud/debian-11" } }
  network_interface { network = "default" }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF

terraform plan
terraform apply -auto-approve
print_success "Task 4 completed!"

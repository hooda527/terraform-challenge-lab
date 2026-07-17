# Terraform Challenge Lab Solver

Automated solver for Google Cloud Terraform Challenge Lab.

## Features

- **Task 1**: Create configuration files and directory structure
- **Task 2**: Import existing VM instances into Terraform
- **Task 3**: Configure GCS remote backend
- **Task 4**: Modify and update infrastructure
- **Task 5**: Destroy resources
- **Task 6**: Use module from Terraform Registry
- **Task 7**: Configure firewall rules

## Quick Start

### 1. Clone the repo
```bash
git clone https://github.com/YOUR_USERNAME/terraform-challenge-lab.git
cd terraform-challenge-lab
```

### 2. Run the solver
```bash
chmod +x solver.sh
./solver.sh
```

### 3. Or run specific task
```bash
./solver.sh task1    # Create configuration files
./solver.sh task2    # Import infrastructure
./solver.sh task3    # Configure remote backend
./solver.sh task4    # Modify and update
./solver.sh task5    # Destroy resources
./solver.sh task6    # Use Registry module
./solver.sh task7    # Configure firewall
```

## Requirements

- Google Cloud SDK (gcloud) installed
- Terraform installed
- Active Google Cloud account
- Lab credentials from Qwiklabs

## Configuration

The solver will ask you for:
- **Project ID** - Your Qwiklabs project ID
- **Bucket Name** - GCS bucket for remote backend
- **Instance Names** - VM instance names
- **VPC Name** - VPC network name

## License

MIT License - Educational use only

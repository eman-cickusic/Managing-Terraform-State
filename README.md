# Managing Terraform State

This repository demonstrates how to effectively manage Terraform state, including working with local backends, Cloud Storage backends, refreshing state, and importing existing infrastructure into Terraform.

## Overview

Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to:
- Map real-world resources to your configuration
- Keep track of metadata
- Improve performance for large infrastructures

By default, state is stored in a local file named `terraform.tfstate`, but it can also be stored remotely, which works better in team environments.

## Video 

https://youtu.be/HX4px1zDuPs


## Contents

This repository includes:

1. [Task 1: Working with Backends](#task-1-working-with-backends)
   - [Local Backend](#local-backend)
   - [Cloud Storage Backend](#cloud-storage-backend)
   - [Refreshing State](#refreshing-state)

2. [Task 2: Importing Terraform Configuration](#task-2-importing-terraform-configuration)
   - [Creating Infrastructure to Import](#creating-infrastructure-to-import)
   - [Importing Into Terraform](#importing-into-terraform)
   - [Creating and Refining Configuration](#creating-and-refining-configuration)
   - [Managing Resources with Terraform](#managing-resources-with-terraform)

## Task 1: Working with Backends

### Local Backend

The local backend stores state on the local filesystem and uses system APIs for state locking.

```hcl
# Example local backend configuration
terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
```

### Cloud Storage Backend

The GCS backend stores state as an object in a Cloud Storage bucket and supports state locking.

```hcl
# Example GCS backend configuration
terraform {
  backend "gcs" {
    bucket  = "your-bucket-name"
    prefix  = "terraform/state"
  }
}
```

### Refreshing State

The `terraform refresh` command reconciles the state Terraform knows about with the real-world infrastructure.

## Task 2: Importing Terraform Configuration

### Creating Infrastructure to Import

For demonstration purposes, we first create infrastructure outside of Terraform (e.g., a Docker container):

```bash
docker run --name hashicorp-learn --detach --publish 8080:80 nginx:latest
```

### Importing Into Terraform

To import existing infrastructure:

1. Define an empty resource in your configuration:
   ```hcl
   resource "docker_container" "web" {}
   ```

2. Import the existing resource:
   ```bash
   terraform import docker_container.web $(docker inspect -f {{.ID}} hashicorp-learn)
   ```

### Creating and Refining Configuration

After importing, refine your configuration to match the imported state:

```hcl
resource "docker_container" "web" {
  image = docker_image.nginx.image_id
  name  = "hashicorp-learn"
  ports {
    external = 8080
    internal = 80
    ip       = "0.0.0.0"
    protocol = "tcp"
  }
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}
```

### Managing Resources with Terraform

After importing, you can manage the resources using Terraform commands:

```bash
terraform plan    # Preview changes
terraform apply   # Apply changes
terraform destroy # Destroy resources
```

## Getting Started

1. Clone this repository
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review and execute tasks as described in the respective sections

## Limitations and Considerations

- Terraform import only knows the current state of infrastructure as reported by providers
- It doesn't know whether the infrastructure is working correctly
- Manual steps can be error-prone
- Importing manipulates the Terraform state file
- Import doesn't detect relationships between infrastructure
- Not all providers and resources support import
- Imported infrastructure might depend on unmanaged resources

## Files in this Repository

- `main.tf` - Provider configuration
- `gcs_backend.tf` - Cloud Storage backend configuration
- `local_backend.tf` - Local backend configuration
- `docker.tf` - Docker container and image configuration
- `import.sh` - Helper script for importing resources

## License

This project is licensed under the MIT License - see the LICENSE file for details.

#!/bin/bash
# Helper script for importing Docker resources into Terraform

# Make sure script fails on errors
set -e

echo "Creating Docker container with NGINX..."
docker run --name hashicorp-learn --detach --publish 8080:80 nginx:latest

echo "Verifying container is running..."
docker ps --filter "name=hashicorp-learn"

echo "Initializing Terraform..."
terraform init

echo "Importing Docker container into Terraform..."
CONTAINER_ID=$(docker inspect -f {{.ID}} hashicorp-learn)
terraform import docker_container.web $CONTAINER_ID

echo "Container imported successfully!"
echo "Now you should:"
echo "1. Run 'terraform show -no-color > imported-config.tf' to see the full configuration"
echo "2. Edit your docker.tf file to include required attributes"
echo "3. Run 'terraform plan' to ensure configuration matches the imported state"

echo "Done!"

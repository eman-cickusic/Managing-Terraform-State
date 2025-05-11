#!/bin/bash
# Helper script for demonstrating state refreshing

# Make script fail on errors
set -e

echo "Refreshing Terraform state..."
echo "This will reconcile the state file with real-world infrastructure"
echo "Note: This does not modify your infrastructure"

# Create a backup of the current state
if [ -f "terraform/state/terraform.tfstate" ]; then
  echo "Creating backup of current state..."
  cp terraform/state/terraform.tfstate terraform/state/terraform.tfstate.backup.$(date +%Y%m%d%H%M%S)
fi

# Run terraform refresh
echo "Running terraform refresh..."
terraform refresh

echo "Showing current state..."
terraform show

echo "Done!"
echo ""
echo "If you're using a GCS backend, you can check the updated state file in your bucket"
echo "If you're using a local backend, check the terraform/state/terraform.tfstate file"

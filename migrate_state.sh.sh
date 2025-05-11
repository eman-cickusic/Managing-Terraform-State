#!/bin/bash
# Helper script for migrating between state backends

# Make script fail on errors
set -e

# Function to display usage
usage() {
  echo "Usage: $0 [--to-gcs | --to-local]"
  echo ""
  echo "Options:"
  echo "  --to-gcs    Migrate state from local to Google Cloud Storage backend"
  echo "  --to-local  Migrate state from Google Cloud Storage to local backend"
  exit 1
}

# Check arguments
if [ "$#" -ne 1 ]; then
  usage
fi

case "$1" in
  --to-gcs)
    echo "Migrating state from local to Google Cloud Storage backend..."
    
    # Create backup of current state
    echo "Creating backup of current state..."
    if [ -f "terraform/state/terraform.tfstate" ]; then
      cp terraform/state/terraform.tfstate terraform/state/terraform.tfstate.backup.$(date +%Y%m%d%H%M%S)
    fi
    
    # Comment out local backend and uncomment GCS backend
    echo "Updating backend configuration..."
    sed -i 's/^terraform {$/\/\* terraform {/g' local_backend.tf
    sed -i 's/^}$/} \*\//g' local_backend.tf
    
    sed -i 's/^\/\* terraform {$/terraform {/g' gcs_backend.tf
    sed -i 's/^} \*\/$/}/g' gcs_backend.tf
    
    # Migrate state
    echo "Running terraform init with -migrate-state flag..."
    terraform init -migrate-state
    
    echo "Migration to GCS backend complete!"
    ;;
    
  --to-local)
    echo "Migrating state from Google Cloud Storage to local backend..."
    
    # Comment out GCS backend and uncomment local backend
    echo "Updating backend configuration..."
    sed -i 's/^terraform {$/\/\* terraform {/g' gcs_backend.tf
    sed -i 's/^}$/} \*\//g' gcs_backend.tf
    
    sed -i 's/^\/\* terraform {$/terraform {/g' local_backend.tf
    sed -i 's/^} \*\/$/}/g' local_backend.tf
    
    # Migrate state
    echo "Running terraform init with -migrate-state flag..."
    terraform init -migrate-state
    
    echo "Migration to local backend complete!"
    ;;
    
  *)
    usage
    ;;
esac

echo "Don't forget to verify your state and infrastructure with 'terraform plan'"

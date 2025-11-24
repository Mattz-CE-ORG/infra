#!/bin/bash
# Script to sync variables from terraform.tfvars to Terraform Cloud workspace
#
# Why this exists:
# - terraform.tfvars is for LOCAL runs (terraform apply on your machine)
# - Terraform Cloud runs don't read local files, so variables must be set in the workspace
# - This script bridges that gap by syncing variables to Terraform Cloud
#
# Alternative: Use Terraform Cloud Variable Sets (better for shared vars)

set -e

ORG="Ars-Org"
WORKSPACE="infra"
TFC_API="https://app.terraform.io/api/v2"

# Get token from environment variable or Terraform credentials file
if [ -n "$TF_TOKEN_app_terraform_io" ]; then
    TFC_TOKEN="$TF_TOKEN_app_terraform_io"
else
    CREDENTIALS_FILE="$HOME/.terraform.d/credentials.tfrc.json"
    if [ -f "$CREDENTIALS_FILE" ]; then
        TFC_TOKEN=$(jq -r '.credentials."app.terraform.io".token' "$CREDENTIALS_FILE" 2>/dev/null)
    fi
    
    if [ -z "$TFC_TOKEN" ] || [ "$TFC_TOKEN" == "null" ]; then
        echo "Error: Could not find Terraform Cloud token"
        echo "Either set TF_TOKEN_app_terraform_io environment variable, or"
        echo "run 'terraform login' to store credentials in $CREDENTIALS_FILE"
        exit 1
    fi
fi

# Get workspace ID
echo "Getting workspace ID..."
WORKSPACE_ID=$(curl -s \
    --header "Authorization: Bearer $TFC_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    "$TFC_API/organizations/$ORG/workspaces/$WORKSPACE" | \
    jq -r '.data.id')

if [ "$WORKSPACE_ID" == "null" ] || [ -z "$WORKSPACE_ID" ]; then
    echo "Error: Could not find workspace '$WORKSPACE' in organization '$ORG'"
    exit 1
fi

echo "Found workspace ID: $WORKSPACE_ID"

# Function to create or update a variable
set_variable() {
    local key=$1
    local value=$2
    local sensitive=${3:-false}
    local description=$4

    echo "Setting variable: $key (sensitive=$sensitive)..."

    # Check if variable exists
    VAR_ID=$(curl -s \
        --header "Authorization: Bearer $TFC_TOKEN" \
        --header "Content-Type: application/vnd.api+json" \
        "$TFC_API/workspaces/$WORKSPACE_ID/vars" | \
        jq -r ".data[] | select(.attributes.key == \"$key\") | .id")

    if [ -n "$VAR_ID" ] && [ "$VAR_ID" != "null" ]; then
        # Update existing variable
        curl -s -X PATCH \
            --header "Authorization: Bearer $TFC_TOKEN" \
            --header "Content-Type: application/vnd.api+json" \
            --data "{
                \"data\": {
                    \"id\": \"$VAR_ID\",
                    \"attributes\": {
                        \"key\": \"$key\",
                        \"value\": \"$value\",
                        \"sensitive\": $sensitive,
                        \"description\": \"$description\",
                        \"category\": \"terraform\"
                    },
                    \"type\": \"vars\"
                }
            }" \
            "$TFC_API/workspaces/$WORKSPACE_ID/vars/$VAR_ID" > /dev/null
        echo "  ✓ Updated variable: $key"
    else
        # Create new variable
        curl -s -X POST \
            --header "Authorization: Bearer $TFC_TOKEN" \
            --header "Content-Type: application/vnd.api+json" \
            --data "{
                \"data\": {
                    \"type\": \"vars\",
                    \"attributes\": {
                        \"key\": \"$key\",
                        \"value\": \"$value\",
                        \"sensitive\": $sensitive,
                        \"description\": \"$description\",
                        \"category\": \"terraform\"
                    }
                },
                \"relationships\": {
                    \"workspace\": {
                        \"data\": {
                            \"type\": \"workspaces\",
                            \"id\": \"$WORKSPACE_ID\"
                        }
                    }
                }
            }" \
            "$TFC_API/workspaces/$WORKSPACE_ID/vars" > /dev/null
        echo "  ✓ Created variable: $key"
    fi
}

# Parse terraform.tfvars and set variables
# Note: This is a simple parser - it handles basic key = "value" format
TFVARS_FILE="terraform.tfvars"

if [ ! -f "$TFVARS_FILE" ]; then
    echo "Error: $TFVARS_FILE not found"
    echo "Please create $TFVARS_FILE from terraform.tfvars.example"
    exit 1
fi

# Simple parser for terraform.tfvars (handles key = "value" format)
while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$key" ]] && continue
    
    # Trim whitespace
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    
    # Remove quotes from value
    value=$(echo "$value" | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")
    
    # Skip if value is empty
    [[ -z "$value" ]] && continue
    
    # Determine if sensitive based on key name
    sensitive=false
    if [[ "$key" =~ (token|secret|password|key) ]]; then
        sensitive=true
    fi
    
    # Set variable in Terraform Cloud
    set_variable "$key" "$value" "$sensitive" "Synced from $TFVARS_FILE"
done < <(grep -v '^[[:space:]]*#' "$TFVARS_FILE" | grep '=')

echo ""
echo "✓ All variables synced to Terraform Cloud workspace: $WORKSPACE"


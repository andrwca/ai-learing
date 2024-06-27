#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "Getting outputs..."
export STORAGE_ACCOUNT_ID=$(az stack sub show -n "ai-training" --query outputs.storageAccountId.value | tr -d '"')
export SEARCH_SERVICE_IDENTITY_ID=$(az stack sub show -n "ai-training" --query outputs.searchServiceIdentityId.value | tr -d '"')

echo "Updating template..."
envsubst < "$SCRIPT_DIR/../data/data-source.template.json" > "$SCRIPT_DIR/../data/data-source.json"
echo "Done."
#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

name=$(az account show | jq -r '.name')
echo "Deploying to subscription name: $name." 
echo "Press ctrl+c to cancel or wait 3 seconds to continue"
sleep 3

pushd "$SCRIPT_DIR/../infra"

az stack sub create \
  --name 'ai-training' \
  --location 'uksouth' \
  --template-file './openai.resources.bicep' \
  --action-on-unmanage 'deleteAll' \
  --deny-settings-mode 'none'

popd

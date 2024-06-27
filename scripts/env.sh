#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

export OPEN_AI_ENDPOINT=$(az stack sub show -n "ai-training" --query outputs.openAIEndpoint.value | tr -d '"')
export SEARCH_ENDPOINT=$(az stack sub show -n "ai-training" --query outputs.searchServiceEndpoint.value | tr -d '"')
export OPEN_AI_IDENTITY_ID=$(az stack sub show -n "ai-training" --query outputs.openAIIdentityId.value | tr -d '"')

targetScope = 'subscription'

param location string = 'uksouth'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-ai-training'
  location: location
}

module openai 'modules/openai.bicep' = {
  name: 'openai'
  params: {
    location: location
    skuName: 'S0'
  }
  scope: resourceGroup
}

output openAIIdentityId string = openai.outputs.openAIIdentityId
output searchServiceIdentityId string = openai.outputs.searchServiceIdentityId
output storageAccountId string = openai.outputs.storageAccountId
output searchServiceEndpoint string = openai.outputs.searchServiceEndpoint
output openAIEndpoint string = openai.outputs.openAIEndpoint

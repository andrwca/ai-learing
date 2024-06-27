param location string
param skuName string
param name string = 'oai-ai-training-acc-${uniqueString(resourceGroup().id)}'

resource openai_identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-ai-training-openai'
  location: location
}

resource search_service_identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-ai-training-search-service'
  location: location
}

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  kind: 'OpenAI'
  sku: {
    name: skuName
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${openai_identity.id}': {}
    }
  }
  properties: {
    customSubDomainName: name
    encryption: {
      keySource: 'Microsoft.CognitiveServices'
    }
    disableLocalAuth: true
  }
}

resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: account
  name: 'ai-training-deployment'
  sku: {
    name: 'Standard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4'
      version: '1106-Preview'
    }
  }
}

// Need to assign a RBAC role to access this through the portal: 
// https://learn.microsoft.com/en-us/azure/storage/blobs/assign-azure-role-data-access 
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'sasearch${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    isLocalUserEnabled: false
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
  }
  kind: 'StorageV2'
}

resource storageBlob 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  name: 'default'
  parent: storageAccount
  properties: {}
}

resource storageBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: 'search-content'
  parent: storageBlob
  properties: {
    publicAccess: 'None'
  }
}

resource searchService 'Microsoft.Search/searchServices@2024-03-01-preview' = {
  name: 'ss-ai-training-${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'basic'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${search_service_identity.id}': {}
    }
  }
  properties: {
    disableLocalAuth: true
  }
}

resource ra_oai_si_data_reader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, 'Search Index Data Reader')
  scope: searchService
  properties: {
    principalId: openai_identity.properties.principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    )
  }
}

resource ra_oai_ss_contributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, 'Search Service Contributor')
  scope: searchService
  properties: {
    principalId: openai_identity.properties.principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
    )
  }
}

resource ra_ss_sa_data_reader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, 'Storage Blob Data Reader')
  scope: storageAccount
  properties: {
    principalId: search_service_identity.properties.principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
    )
  }
}

output openAIIdentityId string = openai_identity.id
output searchServiceIdentityId string = search_service_identity.id
output storageAccountId string = storageAccount.id
output searchServiceEndpoint string = 'https://${searchService.name}.search.windows.net/'
output openAIEndpoint string = 'https://${account.properties.customSubDomainName}.openai.azure.com/'


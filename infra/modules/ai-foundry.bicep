// metadata description = 'Creates an AI Foundry Hub + Project with Storage, Key Vault, and connections.'

// param location string
// param tags object = {}
// param hubName string
// param projectName string
// param storageAccountName string
// param keyVaultName string
// param aiServiceName string
// param aiServiceResourceId string
// param searchServiceTarget string
// param searchServiceResourceId string
// param searchConnectionName string = 'aisearch-connection'

// // ──────────────────────────────────────────────
// // Storage Account (required by Hub)
// // ──────────────────────────────────────────────
// resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
//   name: storageAccountName
//   location: location
//   tags: tags
//   kind: 'StorageV2'
//   sku: { name: 'Standard_LRS' }
//   properties: {
//     accessTier: 'Hot'
//     allowBlobPublicAccess: false
//     minimumTlsVersion: 'TLS1_2'
//   }

//   resource blobServices 'blobServices' = {
//     name: 'default'
//     resource dataContainer 'containers' = {
//       name: 'data'
//     }
//   }
// }

// // ──────────────────────────────────────────────
// // Key Vault (required by Hub)
// // ──────────────────────────────────────────────
// resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
//   name: keyVaultName
//   location: location
//   tags: tags
//   properties: {
//     sku: { family: 'A', name: 'standard' }
//     tenantId: subscription().tenantId
//     enableRbacAuthorization: true
//     enableSoftDelete: true
//   }
// }

// // ──────────────────────────────────────────────
// // Reference existing AI Services account (to get keys)
// // ──────────────────────────────────────────────
// resource aiService 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
//   name: aiServiceName
// }

// // ──────────────────────────────────────────────
// // AI Foundry Hub
// // ──────────────────────────────────────────────
// resource hub 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
//   name: hubName
//   location: location
//   tags: tags
//   kind: 'Hub'
//   sku: { name: 'Basic', tier: 'Basic' }
//   identity: { type: 'SystemAssigned' }
//   properties: {
//     friendlyName: hubName
//     storageAccount: storage.id
//     keyVault: keyVault.id
//     publicNetworkAccess: 'Enabled'
//   }
// }

// // ──────────────────────────────────────────────
// // AI Foundry Project (under the Hub)
// // ──────────────────────────────────────────────
// resource project 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
//   name: projectName
//   location: location
//   tags: tags
//   kind: 'Project'
//   sku: { name: 'Basic', tier: 'Basic' }
//   identity: { type: 'SystemAssigned' }
//   properties: {
//     friendlyName: projectName
//     hubResourceId: hub.id
//     publicNetworkAccess: 'Enabled'
//   }
// }

// // ──────────────────────────────────────────────
// // Connection: AI Services (ApiKey auth for full feature access
// // including Content Understanding)
// // ──────────────────────────────────────────────
// resource aiServicesConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-10-01' = {
//   parent: hub
//   name: 'Default_AIServices'
//   properties: {
//     category: 'AIServices'
//     target: 'https://${aiServiceName}.cognitiveservices.azure.com/'
//     authType: 'ApiKey'
//     credentials: {
//       key: aiService.listKeys().key1
//     }
//     isSharedToAll: true
//     metadata: {
//       ApiType: 'Azure'
//       ResourceId: aiServiceResourceId
//     }
//   }
// }

// // ──────────────────────────────────────────────
// // Connection: Azure AI Search
// // ──────────────────────────────────────────────
// resource searchConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-10-01' = {
//   parent: hub
//   name: searchConnectionName
//   properties: {
//     category: 'CognitiveSearch'
//     target: searchServiceTarget
//     authType: 'AAD'
//     isSharedToAll: true
//     metadata: {
//       ApiType: 'Azure'
//       ResourceId: searchServiceResourceId
//     }
//   }
// }

// // ──────────────────────────────────────────────
// // Outputs
// // ──────────────────────────────────────────────
// output hubId string = hub.id
// output hubName string = hub.name
// output projectId string = project.id
// output projectName string = project.name
// output projectEndpoint string = 'https://${hubName}.services.ai.azure.com/api/projects/${projectName}'
// output searchConnectionName string = searchConnection.name

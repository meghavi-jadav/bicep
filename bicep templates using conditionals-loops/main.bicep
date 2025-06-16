@description('The azure region where you want to deploy the resources.')
param location string = resourceGroup().location

@secure()
@description('The administrator login username for the SQL server.')
param sqlAdminUsername string

@secure()
@description('The administrator login password for the SQL server.')
param sqlAdminPassword string

@description('The name and tier of the SQL server SKU.')
param sqlDatabaseSku object = {
  name: 'Standard'
  tier: 'Standard'
}

@description('The name of the SQL server.')
param sqlServerName string = 'sql${uniqueString(resourceGroup().id)}'

var sqlDatabaseName = 'db${uniqueString(resourceGroup().id)}'

@description('The name of the environment. This must be Development or Production.')
@allowed([
  'Development'
  'Production'
])
param environmentName string = 'Production'

var auditingEnabled = environmentName == 'Production'
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'
param storageAccountSkuName string = 'Standard_LRS'

resource server 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  parent: server
  name: sqlDatabaseName
  location: location
  sku: sqlDatabaseSku
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = if (auditingEnabled) {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'  
}

resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2024-05-01-preview' = if (auditingEnabled) {
  parent: server
  name: 'default'
  properties: {
    state: 'Enabled'
    storageEndpoint: environmentName == 'Production' ? storageAccount.properties.primaryEndpoints.blob : ''
    storageAccountAccessKey: environmentName == 'Production' ? storageAccount.listKeys().keys[0].value : ''
  }
}

// @description('Set true to deploy a storage account.')
// param deployStorageAccount bool

// @description('The azure region where you want to deploy the resources.')
// param location string = resourceGroup().location

// param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'
// param storageAccountSkuName string = 'Standard_LRS'

// @allowed([
//   'Development'
//   'Production'
// ])
// param environmentName string

// var auditingEnabled = environmentName == 'Production'

// @description('The name of the SQL server.')
// param sqlServerName string = 'sql${uniqueString(resourceGroup().id)}'

// resource server 'Microsoft.Sql/servers@2022-02-01-preview' = {
//   name: sqlServerName
//   location: location
//   properties: {
//     administratorLogin: 'sqladminuser'
//     administratorLoginPassword: 'P@ssw0rd1234!' // Replace with a secure parameter in production
//     version: '12.0'
//   }
// }

// resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = if (deployStorageAccount) {
//   name: storageAccountName
//   location: location
//   kind: 'StorageV2'
//   sku: {
//     name: storageAccountSkuName
//   }
// }

// resource auditingSettings 'Microsoft.Sql/servers/auditingSettings@2024-05-01-preview' = if (auditingEnabled) {
//   parent: server
//   name: 'default'
//   properties: {
//     state: 'Enabled'
//     storageEndpoint: environmentName == 'Production' ? storageAccount.properties.primaryEndpoints.blob : ''
//     storageAccountAccessKey: environmentName == 'Production' ? listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value : ''
//   }
// }

// // resource auditingSettings 'Microsoft.Sql/servers/auditingSettings@2024-05-01-preview' = if (environmentName == 'Production') {
// //   parent: server
// //   name: 'default'
// // }


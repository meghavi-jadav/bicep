@minLength(3)
@maxLength(24)
@description('Provide a name for the storage account. Use only lowercase letters and numbers. The name must be unique across Azure.')
param storageAccountName string = 'store${uniqueString(resourceGroup().id)}' //String interpolation
// param storageAccountName string = uniqueString(resourceGroup().id)
param webAppName string = 'webapp${uniqueString(resourceGroup().id)}' 
param location string = resourceGroup().location

@allowed([
  'prod'
  'dev'
  'test'
])
param environmentType string


var storageAccountSku = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'exampleVNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource storageaccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSku
  }
}

module app 'App_Service.bicep' = {
  name: 'appServiceModule'
  params: {
    location: location
    webAppName: webAppName
    environmentType: environmentType
  }
}

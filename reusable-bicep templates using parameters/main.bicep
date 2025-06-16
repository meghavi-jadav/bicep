@description('The name of the environment. This must be dev, test, or pord.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@minLength(5)
@maxLength(30)
param solutionName  string = 'test${uniqueString(resourceGroup().id)}'

@minValue(1)
@maxValue(10)
@description('The number of instances for the App Service Plan.')
param appServiceInstanceCount int = 1


@secure()
@description('The administrator login username for the SQL Server')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL Server')
param sqlServerAdministratorPassword string

@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object

@description('The name and tier of the App Service Plan SKU.')
param appServicePlanSku object = {
  name: 'F1'
  tier: 'Free'
}

@description('The Azure region where the resources will be deployed.')
param location string = 'westus3'

var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceName = '${environmentName}-${solutionName}-app'
var sqlServerName = '${environmentName}-${solutionName}-sql'
var sqlDatabaseName = 'EmployeeDB'  

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku:{
    name:appServicePlanSku.name
    tier:appServicePlanSku.tier
    capacity: appServiceInstanceCount
  }
}

resource serviceApp 'Microsoft.Web/sites@2024-11-01' = {
  name: appServiceName
  location: location
  properties:{
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: sqlServerName
  location:location
  properties:{
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview'= {
  name:sqlDatabaseName
  parent: sqlServer
  location: location
  sku: {
    name: sqlDatabaseSku.name
    tier: sqlDatabaseSku.tier
  }
}

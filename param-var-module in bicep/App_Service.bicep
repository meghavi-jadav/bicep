param location string
param webAppName string

@allowed([
  'prod'
  'dev'
  'test'
])
param environmentType string
var appServicePlanSku = (environmentType == 'prod') ? 'P2v3' : 'F1'

resource AppServicePlan 'Microsoft.Web/serverfarms@2024-11-01' = {
  location: location
  name: 'exampleAppServicePlan'
  sku:{
    name: appServicePlanSku
  } 
}

resource AppService 'Microsoft.Web/sites@2024-11-01' = {
  name: webAppName
  location: location
  properties:{
    serverFarmId: AppServicePlan.id
    publicNetworkAccess: 'Disabled'
    httpsOnly:true
  }
} 

// output AppServiceUrl string = 'https://${webAppName}.azurewebsites.net'
output AppServiceHostname string = AppService.properties.defaultHostName

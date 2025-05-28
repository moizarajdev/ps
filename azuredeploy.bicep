targetScope = 'resourceGroup'

// Parameters
param location string
param hostPoolName string
param registrationInfoToken string
param registrationInfoExpirationTime string
param sessionHostNames array
param vmSize string
param adminUsername string
@secure()
param adminPassword string
param imagePublisher string
param imageOffer string
param imageSku string
param imageVersion string = 'latest'
param vnetResourceGroup string
param vnetName string
param subnetName string
param nsgId string
param domainToJoin string
param ouPath string = ''
@secure()
param domainJoinUsername string
@secure()
param domainJoinPassword string
param scriptUri string
param osDiskType string = 'Standard_LRS'
param diskSizeGB int = 128

// Variables
var subnetResourceId = resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

// Update registration token on Host Pool
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2024-11-01-preview' = {
  name: hostPoolName
  location: location
  properties: {
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
    friendlyName: hostPoolName
    registrationInfo: {
      registrationTokenOperation: 'Update'
      token: registrationInfoToken
      expirationTime: registrationInfoExpirationTime
    }
  }
}

// Network Interfaces
resource nics 'Microsoft.Network/networkInterfaces@2024-05-01' = [for (name, i) in sessionHostNames: {
  name: '${name}-nic'
  location: location
  dependsOn: [ hostPool ]
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: subnetResourceId }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    networkSecurityGroup: { id: nsgId }
  }
}]

// Virtual Machines
resource vms 'Microsoft.Compute/virtualMachines@2024-11-01' = [for (name, i) in sessionHostNames: {
  name: name
  location: location
  dependsOn: [ nics[i], hostPool ]
  identity: { type: 'SystemAssigned' }
  properties: {
    hardwareProfile: { vmSize: vmSize }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: imageVersion
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: { storageAccountType: osDiskType }
        diskSizeGB: diskSizeGB
      }
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: { enableAutomaticUpdates: true }
    }
    networkProfile: { networkInterfaces: [ { id: nics[i].id } ] }
    diagnosticsProfile: { bootDiagnostics: { enabled: true } }
  }
}]

// Domain Join Extension (top-level loop)
resource domainJoinExt 'Microsoft.Compute/virtualMachines/extensions@2024-11-01' = [for (name, i) in sessionHostNames: {
  name: 'joindomain-${name}'
  parent: vms[i]
  location: location
  dependsOn: [ vms[i] ]
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: domainToJoin
      OUPath: ouPath
      User: domainJoinUsername
      Restart: 'true'
    }
    protectedSettings: { Password: domainJoinPassword }
  }
}]

// Custom Script Extension
resource customScriptExt 'Microsoft.Compute/virtualMachines/extensions@2024-11-01' = [for (name, i) in sessionHostNames: {
  name: 'CustomScript-${name}'
  parent: vms[i]
  location: location
  dependsOn: [ domainJoinExt[i] ]
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: { fileUris: [ scriptUri ] }
    protectedSettings: { commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${last(split(scriptUri, '/'))}' }
  }
}]

// Output
output sessionHostNames array = sessionHostNames

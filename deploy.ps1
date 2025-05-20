Connect-AzAccount
Set-AzContext -SubscriptionId "56e282ac-7d87-46ad-900a-4c0ed6912002"

$prefix = "win11test"
$newCount = 3

$existingIdx = Get-AzVM -ResourceGroupName "RG-AVD-Dev" |
Where-Object Name -match "^$prefix-(\d+)$" |
ForEach-Object { [int]$Matches[1] }
$maxIdx = if ($existingIdx) { ($existingIdx | Measure-Object -Maximum).Maximum } else { -1 }

$sessionHostNames = 1..$newCount | ForEach-Object { "$prefix-$($maxIdx + $_)" }

$expireUTC = (Get-Date).ToUniversalTime().AddHours(4).ToString("yyyy-MM-ddTHH:mm:ssZ")
$regInfo = New-AzWvdRegistrationInfo -ResourceGroupName "RG-AVD-Dev" -HostPoolName "HP-AVDDev" -ExpirationTime $expireUTC

$secrets = @{
    adminPassword      = (Get-AzKeyVaultSecret -VaultName "KV-DomainVault" -Name "VMLocalAdminPassword").SecretValue
    domainJoinUsername = (Get-AzKeyVaultSecret -VaultName "KV-DomainVault" -Name "DomainEnrollUsername").SecretValue
    domainJoinPassword = (Get-AzKeyVaultSecret -VaultName "KV-DomainVault" -Name "DomainEnrollPassword").SecretValue
}

New-AzResourceGroupDeployment `
    -Name                          "avd-names-array" `
    -ResourceGroupName             "RG-AVD-Dev" `
    -TemplateFile                  "azuredeploy.json" `
    -location                      "northcentralus" `
    -hostPoolName                  "HP-AVDDev" `
    -sessionHostNames              $sessionHostNames `
    -vmSize                        "Standard_D4as_v5" `
    -imagePublisher                "MicrosoftWindowsDesktop" `
    -imageOffer                    "office-365" `
    -imageSku                      "win11-24h2-avd-m365" `
    -imageVersion                  "latest" `
    -vnetResourceGroup             "RG-AVD-Dev" `
    -vnetName                      "VNET-TestAvdNetwork" `
    -subnetName                    "default" `
    -nsgId                         "/subscriptions/56e282ac-7d87-46ad-900a-4c0ed6912002/resourceGroups/RG-AVD-Dev/providers/Microsoft.Network/networkSecurityGroups/NSG-VNET-TestAVDNetwork-default" `
    -adminUsername                 "usmavdadmin" `
    -adminPassword                 $secrets.adminPassword `
    -domainToJoin                  "usm1.local" `
    -ouPath                        "OU=VMs,OU=USM_New_AVD,DC=usm1,DC=local" `
    -domainJoinUsername            $secrets.domainJoinUsername `
    -domainJoinPassword            $secrets.domainJoinPassword `
    -registrationInfoToken         $regInfo.Token `
    -registrationInfoExpirationTime $expireUTC `
    -scriptUri                     "https://raw.githubusercontent.com/moizarajdev/ps/main/script.ps1"

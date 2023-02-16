$Supervisor = 'Da Boss'
$NameRoot = "$($env:USERNAME)W10HOD" #must be 15 char or less
$Subscription = 'NotFree'
$VMLocalAdminUser = 'vmAdmin'
$VMLocalAdminSecurePassword = Read-Host -Prompt 'Enter password' -AsSecureString
$LocationName = 'southcentralus'
$ResourceGroupName = "$NameRoot"
$ResourceGroupTag = @{
  'IT Manager'       = 'Big Boss'
  'IT Support Group' = 'Digital Security'
  'Application Name' = 'Digital Security Detonate OS'
  'IT Supervisor'    = $Supervisor
}
$VMName = "$NameRoot"
$VMSize = 'Standard_B2s'
$VMPublisherName = 'MicrosoftWindowsDesktop'
$VMOffer = 'Windows-10'
$VMSkus = '20h2-pro'
$VMVersion = 'latest'

$NetworkName = "$NameRoot-vnet"
$NICName = "$NameRoot-nic"
$SubnetName = "$NameRoot-subnet"
$SubnetAddressPrefix = '10.0.0.0/24'
$VnetAddressPrefix = '10.0.0.0/24'
$PublicIpAddress = "$NameRoot-publicip"
$NetworkSecurityGroupName = "$NameRoot-nsg"

Set-AzContext -Subscription $Subscription

if (-not 
  (Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue)
) {
  $newAzResourceGroupParam = @{
    Name     = $ResourceGroupName
    Location = $LocationName
    Tag      = $ResourceGroupTag
  }
  New-AzResourceGroup @newAzResourceGroupParam
}

$NewAzNetworkSecurityRuleConfigParam = @{
  'Access'                   = 'Allow' 
  'Protocol'                 = 'Tcp'
  'Direction'                = 'Inbound'
  'SourceAddressPrefix'      = 'Internet'
  'SourcePortRange'          = '*'
  'DestinationAddressPrefix' = '*'
}
$NsgRule1 = New-AzNetworkSecurityRuleConfig -Name 'rdp-rule' -Description 'Allow RDP' -Priority 100 -DestinationPortRange 3389 @NewAzNetworkSecurityRuleConfigParam
# $NsgRule2 = New-AzNetworkSecurityRuleConfig -Name 'http-rule' -Description 'Allow HTTP' -Priority 101 -DestinationPortRange 80 @NewAzNetworkSecurityRuleConfigParam
# $NsgRule3 = New-AzNetworkSecurityRuleConfig -Name 'https-rule' -Description 'Allow HTTPS' -Priority 102 -DestinationPortRange 443 @NewAzNetworkSecurityRuleConfigParam
$nsg = New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName -ResourceGroupName $ResourceGroupName -Location $LocationName -SecurityRules $NsgRule1 #, $NsgRule2, $NsgRule3

$SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
$Vnet = New-AzVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName -Location $LocationName -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet
$PublicIp = New-AzPublicIpAddress -Name $PublicIpAddress -ResourceGroupName $ResourceGroupName -AllocationMethod Dynamic -Location $LocationName
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $PublicIp.Id -NetworkSecurityGroupId $Nsg.Id

$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $VMPublisherName -Offer $VMOffer -Skus $VMSkus -Version $VMVersion

Write-Host 'Creating VM. Please wait...'
New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose
$NewVm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
# create autoshutdown object
$ShutDownResourceId = $NewVm.Id -replace 'Microsoft\.Compute\/virtualMachines\/', 'microsoft.devtestlab/schedules/shutdown-computevm-'
$ShutDownResourceProperties = @{
  'Status'               = 'Enabled'
  'TaskType'             = 'ComputeVmShutdownTask'
  'DailyRecurrence'      = @{'time' = '1900' }
  'TimeZoneId'           = 'Central Standard Time'
  'NotificationSettings' = @{
    'Status'             = 'Enabled'
    'TimeInMinutes'      = 30
    'EmailRecipient'     = 'steven.judd@dvn.com'
    'NotificationLocale' = 'en'
  }
  'TargetResourceId'     = $NewVm.Id
}
$NewAzResourceParams = @{
  'ResourceId' = $ShutDownResourceId
  'Location'   = $LocationName
  'Properties' = $ShutDownResourceProperties
  'Force'      = $true
}
New-AzResource @NewAzResourceParams

# connect via Remote Desktop
mstsc /v:$((Get-AzPublicIpAddress -ResourceName $PublicIpAddress).IpAddress)
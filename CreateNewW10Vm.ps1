function NewSjAzureWin10Vm {
  param(
    [parameter(Mandatory)]
    [string]$EmailRecipient,
    # add validation for email format
    [parameter(Mandatory)]
    [securestring]$VMLocalAdminSecurePassword,
    # add validation for the password complexity
    [string]$Subscription,
    [string]$VMLocalAdminUser,
    [string]$LocationName

  )
  
  #region Variables
  $ErrorActionPreference = 'Stop'
  $userName = switch ($true) {
    $IsLinux {
      $env:USER
    }
    $IsMacOS {
      $env:USER
    }
    $IsWindows {
      $env:USERNAME
    }
    default {
      $env:USERNAME
    }
  } 
  $NameRoot = 'W10VM' + $userName
  $ResourceGroupName = "$NameRoot"
  $ResourceGroupTag = @{
    'Supervisor'       = 'Da Boss'
    'Manager'          = 'Big Boss'
    'Support Group'    = 'Digital Security'
    'Application Name' = 'Digital Security Detonate OS'
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
  #endregion Variables

  if (-not (Get-AzSubscription -ErrorAction SilentlyContinue)) {
    throw 'Unable to get Azure Subscription. Please connect using Add-AzAccount.'
  }
  
  Set-AzContext -Subscription $Subscription

  $getAzVmParam = @{
    'ResourceGroupName' = $ResourceGroupName
    'Name'              = $VMName
    'ErrorAction'       = 'SilentlyContinue'
  }
  if (Get-AzVM @getAzVmParam) {
    Write-Warning 'VM already exists'
    return
  }

  $GetAzReourceGroupParam = @{
    'Name'        = $ResourceGroupName
    'ErrorAction' = 'SilentlyContinue'
  }
  if (Get-AzResourceGroup @GetAzReourceGroupParam) {
    Write-Warning 'ResourceGroup already exists'
  } else {
    $newAzResourceGroupParam = @{
      Name     = $ResourceGroupName
      Location = $LocationName
      Tag      = $ResourceGroupTag
    }
    New-AzResourceGroup @newAzResourceGroupParam
  }

  #region Create security rules
  $securityRules = @()
  $priority = 100

  # base params

  $NewAzNetworkSecurityRuleConfigParam = @{
    'Access'                   = 'Allow' 
    'Protocol'                 = 'Tcp'
    'Direction'                = 'Inbound'
    'SourceAddressPrefix'      = 'Internet'
    'SourcePortRange'          = '*'
    'DestinationAddressPrefix' = '*'
  }

  # Enable to allow RDP traffic
  $NewAzNetworkSecurityRuleConfigParam.Name = 'rdp-rule'
  $NewAzNetworkSecurityRuleConfigParam.Description = 'Allow RDP'
  $NewAzNetworkSecurityRuleConfigParam.DestinationPortRange = 3389
  $NewAzNetworkSecurityRuleConfigParam.Priority = $priority
  $SecurityRules += New-AzNetworkSecurityRuleConfig @NewAzNetworkSecurityRuleConfigParam
  $priority++
  <#
  # Enable to allow http traffic
  $NewAzNetworkSecurityRuleConfigParam.Name = 'http-rule'
  $NewAzNetworkSecurityRuleConfigParam.Description = 'Allow HTTP'
  $NewAzNetworkSecurityRuleConfigParam.Priority = $priority
  $NewAzNetworkSecurityRuleConfigParam.DestinationPortRange = 80
  $SecurityRules += New-AzNetworkSecurityRuleConfig @NewAzNetworkSecurityRuleConfigParam
  $priority++
  # Enable to allow https traffic
  $NewAzNetworkSecurityRuleConfigParam.Name = 'https-rule'
  $NewAzNetworkSecurityRuleConfigParam.Description = 'Allow HTTPS'
  $NewAzNetworkSecurityRuleConfigParam.Priority = $priority
  $NewAzNetworkSecurityRuleConfigParam.DestinationPortRange = 443
  $SecurityRules += New-AzNetworkSecurityRuleConfig @NewAzNetworkSecurityRuleConfigParam
  $priority++
  #>

  #endregion Create security rules

  # Apply security rules
  $NewAzNetworkSecurityGroupParam = @{
    'Name'              = $NetworkSecurityGroupName
    'ResourceGroupName' = $ResourceGroupName
    'Location'          = $LocationName
    'SecurityRules'     = $SecurityRules
  }
  $nsg = New-AzNetworkSecurityGroup @NewAzNetworkSecurityGroupParam

  $NewAzVirtualNetworkSubnetConfigParam = @{
    'Name'          = $SubnetName
    'AddressPrefix' = $SubnetAddressPrefix
  }
  $SingleSubnet = New-AzVirtualNetworkSubnetConfig @NewAzVirtualNetworkSubnetConfigParam

  $NewAzVirtualNetworkParam = @{
    'Name'              = $NetworkName
    'ResourceGroupName' = $ResourceGroupName
    'Location'          = $LocationName
    'AddressPrefix'     = $VnetAddressPrefix
    'Subnet'            = $SingleSubnet
  }
  $Vnet = New-AzVirtualNetwork @NewAzVirtualNetworkParam

  $NewAzPublicIpAddressParam = @{
    'Name'              = $PublicIpAddress
    'ResourceGroupName' = $ResourceGroupName
    'AllocationMethod'  = 'Dynamic'
    'Location'          = $LocationName
  }
  $PublicIp = New-AzPublicIpAddress @NewAzPublicIpAddressParam

  $NewAzNetworkInterfaceParam = @{
    'Name'                   = $NICName
    'ResourceGroupName'      = $ResourceGroupName
    'Location'               = $LocationName
    'SubnetId'               = $Vnet.Subnets[0].Id
    'PublicIpAddressId'      = $PublicIp.Id
    'NetworkSecurityGroupId' = $Nsg.Id
  }
  $NIC = New-AzNetworkInterface @NewAzNetworkInterfaceParam


  $Credential = New-Object System.Management.Automation.PSCredential (
    $VMLocalAdminUser, $VMLocalAdminSecurePassword
  )

  $NewAzVMConfigParam = @{
    'VMName' = $VMName
    'VMSize' = $VMSize
  }
  $VirtualMachine = New-AzVMConfig @NewAzVMConfigParam
  
  $SetAzVMOperatingSystemParam = @{
    'VM'               = $VirtualMachine
    'Windows'          = $true
    'ComputerName'     = $VMName
    'Credential'       = $Credential
    'ProvisionVMAgent' = $true
    'EnableAutoUpdate' = $true
  }
  $VirtualMachine = Set-AzVMOperatingSystem @SetAzVMOperatingSystemParam

  
  $AddAzVMNetworkInterfaceParam = @{
    'VM' = $VirtualMachine
    'Id' = $NIC.Id
  }
  $VirtualMachine = Add-AzVMNetworkInterface @AddAzVMNetworkInterfaceParam
  
  $SetAzVMSourceImageParam = @{
    'VM'            = $VirtualMachine
    'PublisherName' = $VMPublisherName
    'Offer'         = $VMOffer
    'Skus'          = $VMSkus
    'Version'       = $VMVersion
  }
  $VirtualMachine = Set-AzVMSourceImage @SetAzVMSourceImageParam

  Write-Host '===========================' -ForegroundColor Green
  Write-Host 'Creating VM. Please wait...' -ForegroundColor Green
  Write-Host '===========================' -ForegroundColor Green
  $NewAzVMParam = @{
    'ResourceGroupName' = $ResourceGroupName
    'Location'          = $LocationName
    'VM'                = $VirtualMachine
    'Verbose'           = $true
  }
  New-AzVM @NewAzVMParam
  $NewVm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName
  # create autoshutdown object
  $search = 'Microsoft\.Compute\/virtualMachines\/'
  $replace = 'microsoft.devtestlab/schedules/shutdown-computevm-'
  $ShutDownResourceId = $NewVm.Id -replace $search, $replace
  $ShutDownResourceProperties = @{
    'Status'               = 'Enabled'
    'TaskType'             = 'ComputeVmShutdownTask'
    'DailyRecurrence'      = @{'time' = '1900' }
    'TimeZoneId'           = 'Central Standard Time'
    'NotificationSettings' = @{
      'Status'             = 'Enabled'
      'TimeInMinutes'      = 30
      'EmailRecipient'     = "$EmailRecipient"
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
  $vmIpAddress = $((Get-AzPublicIpAddress -ResourceName $PublicIpAddress).IpAddress)
  switch ($true) {
    $IsLinux {
      Write-Host "Run mstsc and connect as '$VMLocalAdminUser' to $vmIpAddress"
    }
    $IsMacOS {
      Write-Host "Run mstsc and connect as '$VMLocalAdminUser' to $vmIpAddress"
    }
    $IsWindows {
      Write-Host "Connect as '$VMLocalAdminUser' to $vmIpAddress"
      mstsc /v:$vmIpAddress /prompt
    }
    default {
      Write-Host "Connect as '$VMLocalAdminUser' to $vmIpAddress"
      mstsc /v:$vmIpAddress /prompt
    }
  }
}

$NewSjAzureWin10Vm = @{
  'EmailRecipient'             = (Read-Host -Prompt 'Enter email to notify about shutdown')
  'VMLocalAdminSecurePassword' = (Read-Host -Prompt 'Enter password for the Admin account' -AsSecureString)
  'Subscription'               = 'NotFree'
  'VMLocalAdminUser'           = 'vmAdmin'
  'LocationName'               = 'southcentralus'
}
NewSjAzureWin10Vm @NewSjAzureWin10Vm
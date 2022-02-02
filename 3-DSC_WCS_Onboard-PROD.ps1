# The DSC configuration that will generate metaconfigurations
[DscLocalConfigurationManager()]
Configuration DscMetaConfigs
{
     param
     (
         [Parameter(Mandatory=$True)]
         [String]$RegistrationUrl,

         [Parameter(Mandatory=$True)]
         [String]$RegistrationKey,

         [Parameter(Mandatory=$True)]
         [String[]]$ComputerName,

         [Int]$RefreshFrequencyMins = 30,

         [Int]$ConfigurationModeFrequencyMins = 15,

         [String]$ConfigurationMode = 'ApplyAndMonitor',

         [String]$NodeConfigurationName,

         [Boolean]$RebootNodeIfNeeded= $False,

         [String]$ActionAfterReboot = 'ContinueConfiguration',

         [Boolean]$AllowModuleOverwrite = $False,

         [Boolean]$ReportOnly
     )

     if(!$NodeConfigurationName -or $NodeConfigurationName -eq '')
     {
         $ConfigurationNames = $null
     }
     else
     {
         $ConfigurationNames = @($NodeConfigurationName)
     }

     if($ReportOnly)
     {
         $RefreshMode = 'PUSH'
     }
     else
     {
         $RefreshMode = 'PULL'
     }

     Node $ComputerName
     {
         Settings
         {
             RefreshFrequencyMins           = $RefreshFrequencyMins
             RefreshMode                    = $RefreshMode
             ConfigurationMode              = $ConfigurationMode
             AllowModuleOverwrite           = $AllowModuleOverwrite
             RebootNodeIfNeeded             = $RebootNodeIfNeeded
             ActionAfterReboot              = $ActionAfterReboot
             ConfigurationModeFrequencyMins = $ConfigurationModeFrequencyMins
         }

         if(!$ReportOnly)
         {
         ConfigurationRepositoryWeb AzureAutomationStateConfiguration
             {
                 ServerUrl          = $RegistrationUrl
                 RegistrationKey    = $RegistrationKey
                 ConfigurationNames = $ConfigurationNames
             }

             ResourceRepositoryWeb AzureAutomationStateConfiguration
             {
                 ServerUrl       = $RegistrationUrl
                 RegistrationKey = $RegistrationKey
             }
         }

         ReportServerWeb AzureAutomationStateConfiguration
         {
             ServerUrl       = $RegistrationUrl
             RegistrationKey = $RegistrationKey
         }
     }
}

 # Create the metaconfigurations
 # NOTE: DSC Node Configuration names are case sensitive in the portal.
 # TODO: edit the below as needed for your use case
$Params = @{
     RegistrationUrl = 'https://cacec527-ab84-4d88-8bc9-d00289f066b0.agentsvc.ase.azure-automation.net/accounts/cacec527-ab84-4d88-8bc9-d00289f066b0';
     RegistrationKey = 'bc2iAyRPkRQG5K3oz8F1y7K9ZdlyD+q8VTbH1rOQiTEX0YUwe8AYE0NdOUwoA0gxa1eK9ITVlW6KMr4iDvuvfw==';
     ComputerName = @("localhost");
     NodeConfigurationName = 'wcscommon.localhost'
     RefreshFrequencyMins = 1440;
     ConfigurationModeFrequencyMins = 720;
     RebootNodeIfNeeded = $True;
     AllowModuleOverwrite = $True;
     ConfigurationMode = 'ApplyAndMonitor';
     ActionAfterReboot = 'ContinueConfiguration';
     ReportOnly = $false; 
}
 
# Use PowerShell splatting to pass parameters to the DSC configuration being invoked
# For more info about splatting, run: Get-Help -Name about_Splatting


DscMetaConfigs @Params -OutputPath C:\workarea\DscMetaConfigs 


Set-DscLocalConfigurationManager -Path C:\workarea\DscMetaConfigs -Force # -Credential $Creds

workflow kh-wf
{
      param (
        #Azure Login Credentials KH
        [Parameter(Mandatory=$false)]
        [String]$AzureLoginCredentials = 'CustomerPortalAdminAccount',
        
        #Customer Portal SQL Server Credentials
        [Parameter(Mandatory=$false)]
        [String]$SQLServerAzureCredentials = 'CustomerPortalSQLCredentials',
        
        #Customer Portal SQL Server
        [Parameter(Mandatory=$false)]
        [String]$SQLServerNameAzureVariable = 'akh-customerportal-sqlserver.database.windows.net',
        
        #Customer Portal SQL Database
        [Parameter(Mandatory=$false)]
        [String]$SQLDatabaseNameAzureVariable = 'eBECS_CustomerHub_Stage',
        
        #Automation Runbook to Run (Update Services) "RESOURCE GROUP NAME"
        [Parameter(Mandatory=$false)]
        [String]$AutomationAccountResourceGroup = 'Ahmad-117081416183371',
        
        #Automation Runbook to Run (Update Services) "AUTOMATION ACCOUNT NAME"
        [Parameter(Mandatory=$false)]
        [String]$AutomationAccountName = 'Ahmad-117081416183371',
        
        #Automation Runbook to Run (Update Services) "SUBSCRIPTION ID"
        [Parameter(Mandatory=$false)]
        [String]$AutomationSubscriptionID = '1acb57b5-ed46-4dfb-9326-45efa6ea9c95',

        #Automation Runbook to Run (Update Services)
        [Parameter(Mandatory=$false)]
        [String]$AutomationAccountRunBookToRun = 'CustomerHubService-',

        #Current Working Customer SQL ID
        [Parameter(Mandatory=$false)]
        [int]$CustomerSQLID= 1,

        #Current Working Customer Subscription ID
        [Parameter(Mandatory=$false)]
        [String]$CustomerSubscriptionID = 'fcebdb0c-44cf-4d89-8248-e9acdbafd358'
    
    ) #End of Parameters 
 
$SQLServer = $SQLServerNameAzureVariable
$SQLDatabase = $SQLDatabaseNameAzureVariable

$WebhookParameterSet = @{"SQLServerNameAzureVariable"="$SQLServer";
                                 "SQLDatabaseNameAzureVariable"="$SQLDatabase";
                                 "AutomationAccountResourceGroup"="$AutomationAccountResourceGroup";
                                 "AutomationAccountName"="$AutomationAccountName";
                                 "AutomationSubscriptionID"="$AutomationSubscriptionID";
                                 "AutomationAccountRunBookToRun"="$AutomationAccountRunBookToRun";
                                 "CustomerSQLID"="$CustomerSQLID";
                                 "CustomerSubscriptionID"="$CustomerSubscriptionID";
                                 #"CustomerHasWebhook"="$true"
                                 }


$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

#$AzureCred = Get-AutomationPSCredential -Name $AzureLoginCredentials



$exp= (get-date).AddYears(1)
$webHoookName = "UpdateData-$CustomerSubscriptionID"

$NewCustomerWebook = New-AzureRmAutomationWebhook -Name $webHoookName `
                                     -RunbookName AzureAutomationTutorialScript `
                                     -ResourceGroupName $AutomationAccountResourceGroup `
                                     -AutomationAccountName $AutomationAccountName `
                                     -IsEnabled $true `
                                     -ExpiryTime $exp `
                                     -Force `
                                     -Parameters $WebhookParameterSet
                                    

$NewCustomerWebook.WebhookURI
}
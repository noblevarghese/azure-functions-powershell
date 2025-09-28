using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
#Connect-MgGraph -Identity -ClientId "547483ff-e61e-4291-8050-baaed6c420f1" -NoWelcome
#Get-MgContext

<# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}
#>

$tenantId = $Request.Headers.tenantId

#$body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

<#if ($name) {
    $array = @()
    #Get-MgBetaServicePrincipal -Filter "not(startswith(publisherName,'Microsoft'))" -ConsistencyLevel eventual | ForEach-Object {
        $spObj = [PSCustomObject]@{
            Id                     = $_.Id
            DisplayName            = $_.DisplayName
        }

        # Output to the console (or log)
        Write-Output $spObj

        $array += $spObj
    }
    $body = $array | ConvertTo-Json -Compress
#}#>
$appsregisteredinTenant = 0
$appsnotregisteredinTenant = 0
$totalappsinTenant = 0

$totalappsinTenant = (Get-MgBetaServicePrincipal -All |? {$_.AppOwnerOrganizationId -ne "f8cdef31-a31e-4b4a-93e4-5f571e91255a"}).count
$appsregisteredinTenant = (Get-MgBetaServicePrincipal -All |?{$_.AppOwnerOrganizationId -eq $tenantId}).count
$appsnotregisteredinTenant = (Get-MgBetaServicePrincipal -All |?{$_.AppOwnerOrganizationId -ne $tenantId -and $_.AppOwnerOrganizationId -ne "f8cdef31-a31e-4b4a-93e4-5f571e91255a"}).count

$spObj = [PSCustomObject]@{
            "Total Service Principals discovered in this tenant"            = $totalappsinTenant
            "Service Principals with an app registration in this tenant"                  = $appsregisteredinTenant
            "Service Principals without an app registration in this tenant"               = $appsnotregisteredinTenant
        }

$body = $spObj | ConvertTo-Json -Compress

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

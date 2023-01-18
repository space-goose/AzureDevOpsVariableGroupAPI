param (
    [Parameter(Mandatory = $true)][string]$devOpsPAT,
    [Parameter(Mandatory = $true)][string]$organizationName,
    [Parameter(Mandatory = $true)][string]$requestFileName
)

$body = Get-Content $requestFileName | ConvertFrom-Json
$variableGroupName = $body.name
$projectName = $body.variableGroupProjectReferences[0].projectReference.name

$azureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$devOpsPAT")) }
$getAPIUrl = "https://dev.azure.com/$organizationName/$projectName/_apis/distributedtask/variablegroups?groupName=$variableGroupName&api-version=7.0"

$apiResponse = Invoke-RestMethod -Uri $getAPIUrl -Method GET -Headers $azureDevOpsAuthenicationHeader 

if ($apiResponse.count -eq 0) {
    Write-Host "Found no matching variable groups with name '$variableGroupName'"
    return $null
} elseif ($apiResponse.count -eq 1) {
    Write-Host "Found matching variable groups with name '$variableGroupName' and id '$($apiResponse.value[0].id)'"
    return $apiResponse.value[0].id
} else {
    throw "Found '$($apiResponse.count)' variable groups with name '$variableGroupName'"
}
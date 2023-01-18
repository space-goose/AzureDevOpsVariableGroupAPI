param (
    [Parameter(Mandatory = $true)][string]$devOpsPAT,
    [Parameter(Mandatory = $true)][string]$organizationName,
    [Parameter(Mandatory = $true)][string]$requestFileName,
    [Parameter(Mandatory = $false)][string]$variableGroupId
)

$jsonDepth = 3
$body = Get-Content $requestFileName | ConvertFrom-Json
$contentType = "application/json"
$variableGroupName = $body.name
$projectName = $body.variableGroupProjectReferences[0].projectReference.name

$azureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$devOpsPAT")) }
$createAPIUrl = "https://dev.azure.com/$organizationName/_apis/distributedtask/variablegroups?api-version=7.0"
$updateAPIUrl = "https://dev.azure.com/$organizationName/$projectName/_apis/distributedtask/variablegroups/$($variableGroupId)?api-version=7.0"
Write-Host $updateAPIUrl
if (!$variableGroupId) {
    Write-Host "Creating new variable group with name '$variableGroupName' under project '$projectName'"
    Invoke-RestMethod -Uri $createAPIUrl -Method POST -Headers $azureDevOpsAuthenicationHeader -Body ($body | ConvertTo-Json -Depth $jsonDepth) -ContentType $contentType
}
else {
    Write-Host "Updating existing variable group '$variableGroupName' with id '$variableGroupId' under project '$projectName'"
    Invoke-RestMethod -Uri $updateAPIUrl -Method PUT -Headers $azureDevOpsAuthenicationHeader -Body ($body | ConvertTo-Json -Depth $jsonDepth) -ContentType $contentType
}

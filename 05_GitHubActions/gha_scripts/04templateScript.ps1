[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [ValidateSet("GET", "POST", "PUT")]
  [string] $Method,
  [Parameter(Mandatory)]
  [string] $BaseUrl,
  [Parameter(Mandatory)]
  [string] $Message
)

$endpoint = switch ($Method) {
  "GET"  { "/get" }
  "POST" { "/post" }
  "PUT"  { "/put" }
}

$uri = "$BaseUrl$endpoint"

$body = @{
  message   = $Message
  timestamp = (Get-Date).ToString("o")
} | ConvertTo-Json

Write-Host "Method: $Method"
Write-Host "URI   : $uri"
Write-Host "Body  : $body"

$response = Invoke-RestMethod `
  -Method $Method `
  -Uri $uri `
  -Body $body `
  -ContentType "application/json"

Write-Host "Response received:"
$response | ConvertTo-Json -Depth 5
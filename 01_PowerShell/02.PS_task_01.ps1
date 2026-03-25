<#
SCENARIO:
You have a PowerShell script that was created as a test; this generates a report for an AVD
session host. The script currently uses hardcoded values for the environment name, host pool
name, session host name, run date, and output path. This is not appropriate to move onto
production, as it lacks flexibility and reusability. To make the script more dynamic and suitable
for various environments and host pools, you need to refactor it by introducing parameters and
generating some values dynamically.

TASK:
Your task is to refactor the script to make it more dynamic and reusable by converting the
hardcoded values into parameters and generating some of the values dynamically. The output should
remain in the same format, and the script should still create the necessary directories if they
do not exist.

WHY IT MATTERS:
Refactoring the script to be more dynamic and reusable is crucial for several reasons:
1. Flexibility: By using parameters, the script can be easily adapted to different environments and
    host pools without modifying the code.
2. Reusability: A parameterised script can be reused across multiple scenarios, saving time and
    effort in the long run.
3. Maintainability: Dynamic generation of values reduces the chances of errors and makes the script
    easier to maintain, as it can automatically adapt to changes in the environment or host pool
    without requiring manual updates.
4. The output of the JSON file is similar to the objects required by Nerdio API automation, so is
    a realistic example of data that may be used in a production scenario.

Task guidance
TODO 1: Convert EnvironmentName and HostPoolName into parameters.
TODO 2: Generate SessionHostName dynamically (for example, from machine context).
TODO 3: Generate RunDate dynamically using current UTC time.
TODO 4: Build OutputPath dynamically using Join-Path and a timestamped file name.
TODO 5: Keep output object structure unchanged.
#>

# --------------------------------------------------------------------------------------------------
# Starter values (INTENTIONALLY HARDCODED FOR THE TASK)
# --------------------------------------------------------------------------------------------------
$EnvironmentName = 'LD'
$HostPoolName    = 'avd-hostpool-01'
$SessionHostName = 'avd-sh-01'
$RunDate         = '2026-01-01T00:00:00Z'
$OutputPath      = '.\01_PowerShell\report-ld-avd-sh-01.json'

# --------------------------------------------------------------------------------------------------
# Existing behaviour (keep this behaviour, but remove hardcoded inputs above)
# --------------------------------------------------------------------------------------------------
$Report = [PSCustomObject]@{
    Environment = $EnvironmentName
    HostPool    = $HostPoolName
    SessionHost = $SessionHostName
    RunDateUtc  = $RunDate
    Status      = 'ReadyForMaintenance'
}

$OutputDirectory = Split-Path -Path $OutputPath -Parent
if (-not (Test-Path -Path $OutputDirectory)) {
    New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
}

$Report | ConvertTo-Json -Depth 4 | Set-Content -Path $OutputPath -Encoding UTF8
$Report
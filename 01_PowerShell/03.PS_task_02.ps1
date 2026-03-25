<#
SCENARIO:
Before decommissioning a batch of AVD session hosts, the team runs a naming convention compliance
check to confirm every host follows the agreed standard before raising the change request. A junior
engineer has written this as four separate blocks — one per host — each performing the same checks
and appending a result to the same output file. It works, but it is fragile: a fifth host means
copying the block again, and any change to the compliance logic must be made in four places.

TASK:
Refactor the script by extracting the repeated logic into a reusable PowerShell function, then
replace the four repeated blocks with an array of host names and a foreach loop that calls the
function for each entry.

WHY IT MATTERS:
1. DRY Principle: A single function means changes to the compliance logic only need to be made in
    one place, reducing the risk of inconsistencies.
2. Readability: A named function communicates intent. A loop over a list of hosts is far easier to
    follow than four near-identical blocks.
3. Scalability: Adding a new host becomes a one-line change to the array, not a copy-paste of a block.
4. Testability: An isolated function with defined inputs and outputs is straightforward to unit test
    with Pester — flat scripts with no functions are not.

Task guidance
TODO 1: Create a function called Test-HostNameCompliance that accepts HostName, ExpectedPrefix,
          and MaxLength as parameters.
TODO 2: Move the prefix check, length check, result object construction, and file append logic
          into the function.
TODO 3: The function should return the result object.
TODO 4: Define an array of host names and replace the four repeated blocks with a foreach loop
          that calls the function for each entry.
NOTE: In a real scenario, the host name array would likely come from a parameter, such as from
        a pipeline/Github Action input. For this task, you can hardcode it in the script for
        simplicity.
#>

$ExpectedPrefix = 'avd-prod-sh-'
$MaxLength      = 15
$OutputPath     = '.\01_PowerShell\compliance-results.json'

$OutputDirectory = Split-Path -Path $OutputPath -Parent
if (-not (Test-Path -Path $OutputDirectory)) {
    New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
}

# --------------------------------------------------------------------------------------------------
# INTENTIONALLY REPETITIVE CODE - refactor this using a function and a loop
# --------------------------------------------------------------------------------------------------

# Host 1
$PrefixValid = 'avd-prod-sh-01'.StartsWith($ExpectedPrefix)
$LengthValid = 'avd-prod-sh-01'.Length -le $MaxLength

$Result = [PSCustomObject]@{
    HostName    = 'avd-prod-sh-01'
    PrefixValid = $PrefixValid
    LengthValid = $LengthValid
    IsCompliant = ($PrefixValid -and $LengthValid)
}

$Result | ConvertTo-Json -Depth 2 | Add-Content -Path $OutputPath -Encoding UTF8
$Result

# Host 2
$PrefixValid = 'avd-prod-sh-02'.StartsWith($ExpectedPrefix)
$LengthValid = 'avd-prod-sh-02'.Length -le $MaxLength

$Result = [PSCustomObject]@{
    HostName    = 'avd-prod-sh-02'
    PrefixValid = $PrefixValid
    LengthValid = $LengthValid
    IsCompliant = ($PrefixValid -and $LengthValid)
}

$Result | ConvertTo-Json -Depth 2 | Add-Content -Path $OutputPath -Encoding UTF8
$Result

# Host 3 - note: this host fails due to length only
$PrefixValid = 'avd-prod-sh-1234'.StartsWith($ExpectedPrefix)
$LengthValid = 'avd-prod-sh-1234'.Length -le $MaxLength

$Result = [PSCustomObject]@{
    HostName    = 'avd-prod-sh-1234'
    PrefixValid = $PrefixValid
    LengthValid = $LengthValid
    IsCompliant = ($PrefixValid -and $LengthValid)
}

$Result | ConvertTo-Json -Depth 2 | Add-Content -Path $OutputPath -Encoding UTF8
$Result

# Host 4 - note: this host fails due to prefix only
$PrefixValid = 'wvd-prod-sh-04'.StartsWith($ExpectedPrefix)
$LengthValid = 'wvd-prod-sh-04'.Length -le $MaxLength

$Result = [PSCustomObject]@{
    HostName    = 'wvd-prod-sh-04'
    PrefixValid = $PrefixValid
    LengthValid = $LengthValid
    IsCompliant = ($PrefixValid -and $LengthValid)
}

$Result | ConvertTo-Json -Depth 2 | Add-Content -Path $OutputPath -Encoding UTF8
$Result
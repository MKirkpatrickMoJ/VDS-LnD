<#
PESTER:
The below is a starter to begin testing with Pester. There are gaps and a couple of tests that fail.
The intention of this task is to become familiar with Pester concepts such as BeforeAll, Describe,
Context, It, and some of the assertion types. You will need to read through the script and understand
the logic and flow, as this will be important when creating the Pester tests. The script is well commented
to assist with this.

Read through the script and understand the logic and flow, as this will be important when creating the Pester tests.
Each new concept will be commented and introduced in the test file, and you will be tasked with filling in the
blanks to complete the tests and adding an additional one.

WHY IT MATTERS:
Having confidence that your code works as expected is crucial in any production environment. Pester allows you to
write tests that validate your code's functionality, catch bugs early, and ensure that future changes do not
break existing functionality. By writing tests for the provided script, you will gain hands-on experience with
Pester and understand how to apply it to your own scripts in the future.

TASK:
There is one broken test that requires troubleshooting and fixing. There are 4 issues within this test.
Run the test suite from the Describe (assuming the setup and pre-reqs in the readme have been followed, there will
be a green play button next to the Describe block in the test file). This will flag all successful and failed tests,
along with useful error messages for the failed test.

Reading and following the other tests along with the errors will provide all the information needed to rectify the
problematic test.

The other task is to add a new test to validate the error handling logic for a failed CSV export. This will
require mocking the Export-Csv function, asserting and Should commands. Looking at previous tests will provide
guidance on how to do this effectively.
#>

BeforeAll {
  # This block runs once before all tests in the Describe block. You can use it to set up any necessary
  # variables, mock functions, or perform any initialisation required for the tests.
  # In this example, this will just prepare the script to be tested by dot sourcing.
  function Invoke-PSScript01 {
    param (
      [string] $User,
      [string] $Password,
      [string] $TenantId,
      [string] $SubId,
      [string] $HpNaming,
      [string] $OutputPath
    )

    . (Join-Path -Path $PSScriptRoot -ChildPath '02.Pester_PSScript_01.ps1') `
      -User $User `
      -Password $Password `
      -TenantId $TenantId `
      -SubId $SubId `
      -HpNaming $HpNaming `
      -OutputPath $OutputPath
    
    return $HostCount
  }
}

Describe 'Testing 02.Pester_PSScript_01.ps1 entire script' {
  # This Describe block will contain all the tests related to the entire script. You can have multiple It blocks
  # within this Describe block to test different aspects of the script's functionality.
  # It is also possible to have multiple Describe blocks to group related tests together if a script is large
  # or has distinct sections.
  BeforeEach {
    # This block runs before each It block within this Describe block. You can use it to reset any variables,
    # clear mocks, or perform any setup that needs to be done before each test.
    # In this example, we will setup external calls via null functions. This is to ensure that individual tests
    # can mock these calls as needed, without making actual calls to external services.
    # This is important to ensure that tests do not interfere with each other by sharing state.
    # It is important to mock any external dependencies or functions that the script relies on, such as
    # Connect-AzAccount, to ensure that the tests are isolated and do not make actual calls to external services.
    # Internal functions/logic can be ran for real to ensure that the flow of the script is valid.
    function Connect-AzAccount {}
    function Get-AzWvdHostPool {}
    function Get-AzWvdSessionHost {}
    function Test-Path {}
    function Export-Csv {}
    # We can additionally set up variables that will be used across multiple tests
    # These can be overridden within individual tests as needed.
    $TestUser = "testuser"
    $TestPassword = "testpassword"
    $TestTenantId = "testtenantid"
    $TestSubId = "testsubid"
    $TestHpNaming = "testhp*"
    $TestOutputPath = ".\testoutput"
  }
  Context 'Parameter validation' {
    # This Context block will contain tests related to parameter validation. You can have multiple It blocks
    # within this Context block to test different scenarios of parameter validation, such as missing parameters,
    # invalid values, etc.
    It 'Should throw an error if the User parameter is missing' {
      # This test checks that the script throws an error when the User parameter is missing. You can use the
      # Should -Throw assertion to validate that the correct error message is thrown.
      # In this example, we will check for the error message "User parameter is required."
      { Invoke-PSScript01 `
        -User "" `
        -Password $TestPassword `
        -TenantId $TestTenantId `
        -SubId $TestSubId `
        -HpNaming $TestHpNaming `
        -OutputPath $TestOutputPath } `
        | Should -Throw "User parameter is required."
        ## Should -Throw checks that a specific error is thrown. 
        ## Should can also check for other conditions, such as Should -Be,
        ## Should -Contain, Should -Match, etc. to look for positive conditions,
        ## not just errors. This is the ultimate success criteria for the test.
    }
    It 'Should throw an error if the Password parameter is missing' {
      { Invoke-PSScript01 `
        -User $TestUser `
        -Password "" `
        -TenantId $TestTenantId `
        -SubId $TestSubId `
        -HpNaming $TestHpNaming `
        -OutputPath $TestOutputPath } `
        | Should -Throw "Password parameter is required."
    }
    It 'Should throw an error if the TenantId parameter is missing' {
      { Invoke-PSScript01 `
        -User $TestUser `
        -Password $TestPassword `
        -TenantId "" `
        -SubId $TestSubId `
        -HpNaming $TestHpNaming `
        -OutputPath $TestOutputPath } `
        | Should -Throw "TenantId parameter is required."
    }
    It 'Should throw an error if the SubId parameter is missing' {
      { Invoke-PSScript01 `
        -User $TestUser `
        -Password $TestPassword `
        -TenantId $TestTenantId `
        -SubId "" `
        -HpNaming $TestHpNaming `
        -OutputPath $TestOutputPath } `
        | Should -Throw "SubscriptionId parameter is required."
    }
    It 'Should throw an error if the HpNaming parameter is missing' {
      { Invoke-PSScript01 `
        -User $TestUser `
        -Password $TestPassword `
        -TenantId $TestTenantId `
        -SubId $TestSubId `
        -HpNaming "" `
        -OutputPath $TestOutputPath } `
        | Should -Throw "HpNaming parameter is required."
    }
  }
  # With the Parameter validation tests in place, it is now possible to test the logic
  # for the remainder of the script. The next context is to connect to Azure and pull the
  # Azure data - session hosts from the host pools.
  context 'Azure related commands'{
    # We can use the command mock to force a specific output from a function.
    # This method ensures that we are not making actual calls to Azure and allows the logic
    # of the script to be tested in isolation. This is why the Connect-AzAccount and
    # Get-AzWvdSessionHost functions were prepared in the BeforeEach block.
    it 'Should fail to connect to Azure with invalid credentials' {
      # In this test, we will mock the Connect-AzAccount function to throw an error when called, simulating a failed connection to Azure.
      # We will then check that the correct error message is thrown by the script.
      Mock Connect-AzAccount { throw "Error connecting to Azure: Invalid credentials" }
      { Invoke-PSScript01 `
        -User $TestUser `
        -Password $TestPassword `
        -TenantId $TestTenantId `
        -SubId $TestSubId `
        -HpNaming $TestHpNaming `
        -OutputPath $TestOutputPath } `
        | Should -Throw "Error connecting to Azure:*"
        ## NOTE that wildcards * are accepted within the Should check.
        ## This is useful when the error contains variables.
    }
    it 'Should throw when failing to call Get-AzWvdHostPool' {
      Mock Connect-AzAccount {}
      Mock Get-AzWvdHostPool { throw "Error retrieving Host Pools: API error" }
      { Invoke-PSScript01 `
        -User $TestUser `
        -Password $TestPassword `
        -TenantId $TestTenantId `
        -SubId $TestSubId `
        -HpNaming $TestHpNaming `
        -OutputPath $TestOutputPath } `
        | Should -Throw "Error retrieving Host Pools*"
    }
    it 'Should throw when Get-AzWvdHostPool returns no host pools' {
      Mock Connect-AzAccount {}
      Mock Get-AzWvdHostPool { @() }
      { Invoke-PSScript01 `
        -User $TestUser `
        -Password $TestPassword `
        -TenantId $TestTenantId `
        -SubId $TestSubId `
        -HpNaming $TestHpNaming `
        -OutputPath $TestOutputPath } `
        | Should -Throw "No Host Pools found with naming pattern*"
    }
    it 'Should successfully connect to Azure, retrieve host pools and correct count of session hosts' {
      Mock Connect-AzAccount {}
      Mock Get-AzWvdHostPool {
        [PSCustomObject]@{
          Id                  = 'abc-456'
          Name                = 'testhp-002'
          ResourceGroupName   = 'Test-RG'
        }
      }
      Mock Get-AzWvdSessionHost {
        @(
          [PSCustomObject]@{ Id = "host1-id"; Name = "testhost1" },
          [PSCustomObject]@{ Id = "host2-id"; Name = "testhost2" }
        )
      }
      Mock Test-Path { $true }
      $result = Invoke-PSScript01 `
        -User $TestUser `
        -Password $TestPassword `
        -TenantId $TestTenantId `
        -SubId $TestSubId `
        -HpNaming $TestHpNaming `
        -OutputPath $TestOutputPath
      Assert-MockCalled Connect-AzAccount -Exactly 1
      Assert-MockCalled Get-AzWvdHostPool -Exactly 1
      Assert-MockCalled Get-AzWvdSessionHost -Exactly 1
      ## When wanting to look for a positive outcome, we can check
      ## that the expected functions were called, and how many times they were called.
      ## That is accomplished here with Assert-MockCalled. In this example, we check that
      ## Connect-AzAccount, Get-AzWvdHostPool and Get-AzWvdSessionHost were all called exactly once.
      $result | should -HaveCount 1
      $result[0].HostCount | should -Be 2
      ## We can also check that the logic is correctly populating. In this example, we check
      ## that the HostCount property of the first (and only) item in the result is 2, which
      ## matches the number of session hosts we mocked in Get-AzWvdSessionHost.
    }
  }
  Context 'Output file handling' {
    # This context can be used to test the logic related to file output, such as checking 
    # that the output directory is created if it does not exist, and that the Export-Csv
    # function is called with the correct parameters.
    it 'Should throw an error if the output directory is not valid' {
    #################################################################################################################
    ## This test has an issue is failing the test.
    ## TASK: Troubleshoot the test and fix the issues so that it successfully passes and validates
    ## the error handling logic for an invalid output directory.
    ## It will help to look at the real script and understand its logic to be able to do this effectively.
    ## And looking at previous tests in the Pester Suite here to identify if there are any other issues
    ## that may be causing the test to fail, such as missing mocks, incorrect data or inaccurate assertions.
    ##
    ##  THERE ARE FOUR ISSUES TO FIX IN THIS TEST:
    #################################################################################################################
      Mock Connect-AzAccount {}
      Mock Get-AzWvdHostPool {
        [PSCustomObject]@{
          Id                  = 'abc-456'
          Name                = 'testhp-002'
          ResourceGroupName   = 'Test-RG'
        }
      }
      Mock Get-AzWvdSessionHost {
        @(
          [PSCustomObject]@{ Id = "host1-id"; Name = "testhost1" },
          [PSCustomObject]@{ Id = "host2-id"; Name = "testhost2" }
        )
      }
      Mock Test-Path { $false }
      { Invoke-PSScript01 `
        -User $TestUser `
        -Password $TestPassword `
        -TenantId $TestTenantId `
        -SubId $TestSubId `
        -HpNaming $TestHpNaming `
        -OutputPath $TestOutputPath } `
        | Should -Throw "The specified output directory is not valid*"
        Assert-MockCalled Test-Path -Exactly 1
    }
    it 'Should throw if the csv fails to export'{
      #################################################################################################################
      ## Complete this It block to test the error handling logic for a failed CSV export. You will need to mock the
      ## Export-Csv function to throw an error, and then check that the correct error message is thrown by the script.
      ## To reach that point, the previous calls need to be mocked with accurate data to allow the internal logic
      ## to reach the Export-Csv call. This is a good example of how tests can build on each other, and how having
      ## comprehensive mocks can help isolate and test specific error handling scenarios.
      #################################################################################################################
      Mock Connect-AzAccount {}
      Mock Get-AzWvdHostPool {
        [PSCustomObject]@{
          Id                  = 'abc-456'
          Name                = 'testhp-002'
          ResourceGroupName   = 'Test-RG'
        }
      }
      Mock Get-AzWvdSessionHost {
        @(
          [PSCustomObject]@{ Id = "host1-id"; Name = "testhost1" },
          [PSCustomObject]@{ Id = "host2-id"; Name = "testhost2" }
        )
      }
      Mock Test-Path { $true }
      Mock Export-Csv { throw "Error exporting CSV: Disk full" }
      { Invoke-PSScript01 `
        -User $TestUser `
        -Password $TestPassword `
        -TenantId $TestTenantId `
        -SubId $TestSubId `
        -HpNaming $TestHpNaming `
        -OutputPath $TestOutputPath } `
        | Should -Throw "Error exporting report*"
        Assert-MockCalled Export-Csv -Exactly 1
    }
  }
}
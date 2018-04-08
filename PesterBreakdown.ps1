# Pester
Describe "Unit Test" {
    It "Does something" {
        "Something" | Should Be "Something"
    }
}


# Syntax
Get-Help Describe
<#
SYNTAX
    Describe [-Name] <String> [-Tag <String[]>] [[-Fixture] <ScriptBlock>]
    [<CommonParameters>]
#>


# Pester Expanded Syntax
Describe -Name "Unit Test" -Fixture {
    It -Name "Does Something" -Test {
        Should -ActualValue "Something" -Be -ExpectedValue "Something"
    }
}


# Traditional Procedure Syntax 
$test = {
    Should -ActualValue "Something" -Be -ExpectedValue "Something"
}
$fixture = {
    It -Name "Does Something" -Test $test
}
Describe -Name "Unit Test" -Fixture $fixture


# Original Example
Describe "Unit Test" {
    It "Does something" {
        "Something" | Should Be "Something"
    }
}

# end

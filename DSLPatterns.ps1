# DSL Paterns

# Value passthrough

Set-State Running
function Set-State
{
    param($State)
    return $State
}


# Simple Template
function RdcServer
{
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline,
            Mandatory,
            Position = 0
        )]
        [string[]]
        $ComputerName
    )
    process
    {
        foreach($node in $ComputerName)
        {
            @"
            <server>
                <properties>
                <name>$node</name>
                </properties>
            </server>
"@
        }
    }
}


# Nested Template
function RdcGroup
{
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [string]
        $GroupName,

        [Parameter(
            Mandatory,
            Position = 1
        )]
        [scriptblock]
        $ChildItem
    )
    process
    {
        @"
        <group>
          <properties>
            <name>$GroupName</name>
          </properties>
"@
       $ChildItem.Invoke()

'        </group>'
    }
}

# Hashtable Passthrough
State Started {
    Write-Verbose 'Started'
}
function State 
{
    [cmdletbinding()]
    param(
        $State,
    
        [scriptblock]
        $StateScript
    )
    return $PSBoundParameters
}


# Hashtable Builder
# DSC Style (without DynamicKeyword)
ServerDetails {
    Name = 'test'
    IP = '10.0.0.1'
}

function ServerDetails
{
    param([scriptblock]$ScriptBlock)

    $newScript = "[ordered]@{$($ScriptBlock.ToString())}"
    $newScriptBlock = [scriptblock]::Create($newScript)
    & $newScriptBlock
}

# Hashtable collector

StateMachine {

    State Start {
        Write-Verbose "Start"
        Set-State "Monitor"
    }  

    State Monitor {
        Write-Verbose "Monitor"
        Set-State "End"
    }  
}

function StateMachine
{
    [cmdletbinding()]
    param(
        [scriptblock]
        $StateScript
    )

    $userScripts = & $StateScript   
    [hashtable]$stateEngine = @{}
    $userScripts | ForEach-Object {
        $stateEngine[$_.State] = $_
    }

    return $stateEngine        
}

# Restricted DSL
# $null for unrestricted
# [string[]]@() for full restrictions
[string[]]$commands = @('State','ServerDetails','RDCServer')
[string[]]$variables = $null
[bool]$allowEnvVariables = $true
$scriptBlock.CheckRestrictedLanguage($commands, $variables, $allowEnvVariables)
 

# Private/Internal functions
function Get-StateMachine
{
    [cmdletbinding()]
    param(
        [scriptblock]
        $StateScript
    )
    
    function Set-State 
    {
        param($State)
        return $State
    }
    
    $userScripts = & $StateScript 
    [hashtable]$stateEngine = @{}
    $userScripts | ForEach-Object {
        $stateEngine[$_.State] = $_
    }

    return $stateEngine        
}

# DynamicKeyword
# https://gist.github.com/altrive/5864208
ServerDetails
{
    Name = 'test'
    IP = '10.0.0.1'
}

#Reset Existing Dynamic Keywords
[System.Management.Automation.Language.DynamicKeyword]::Reset()

#Add Dynamic Keyword
$keyword = New-Object System.Management.Automation.Language.DynamicKeyword
$keyword.Keyword ="ServerDetails"
$keyword.BodyMode = [Management.Automation.Language.DynamicKeywordBodyMode]::HashTable
$keyword.NameMode =  [Management.Automation.Language.DynamicKeywordNameMode]::NoName
$prop = New-Object System.Management.Automation.Language.DynamicKeywordProperty
$prop.Name="Name"
$prop.Mandatory = $true
$keyword.Properties.Add($prop.Name,$prop)
$prop.Name="IP"
$prop.Mandatory = $true
$keyword.Properties.Add($prop.Name,$prop)
[System.Management.Automation.Language.DynamicKeyword]::AddKeyword($keyword)

#Define Function to process DynamicKeyword
function ServerDetails {
    param (
        [Parameter(Mandatory)]
        $KeywordData,

        [string[]] $Name,

        [Parameter(Mandatory)]
        [hashtable] $Value,

        [Parameter(Mandatory)]
        $SourceMetadata
    )
    $PSBoundParameters
}

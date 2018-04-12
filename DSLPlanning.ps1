# Planning a DSL

# RDCMAN possible commands

# idea 1
New-RDCManFile -Servers Server1,Server2

$group = New-RDCGroup -Servers Server1, Server2
New-RDCManFile -Group $group


# idea 2
RDCMan {
    RDCGroup Production @(
        'Server1'
        'Server2'
    )
}

#idea 3
RDCMan {
    RDCGroup production {
        RDCServer Server1
        RDCServer Server2
    }
}



# Implementing #3
# Full syntax
RDCMan -ChildItem {
    RDCGroup -GroupName 'Production' -ChildItem {
        RDCServer -ComputerName 'Server1'
        RDCServer -ComputerName 'Server2'
    }
}

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

function RdcMan
{
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory,
            Position = 0
        )]
        [scriptblock]
        $ChildItem
    )
    process
    {
        @"
<?xml version="1.0" encoding="utf-8"?>
<RDCMan programVersion="2.7" schemaVersion="3">
  <file>
    <credentialsProfiles />
    <properties>
      <expanded>True</expanded>
      <name>rdcman</name>
    </properties>
"@
       $ChildItem.Invoke()

@"
  </file>
  <connected />
  <favorites />
  <recentlyUsed />
</RDCMan>
"@
    }
}


# RDCMan DSL in action

RDCMan {
    RDCGroup Production {
        RDCServer Server1
        RDCServer Server2
    }
} | Set-Content -Path "$env:temp\demo1.rdg"
& "$env:temp\demo1.rdg"
# code "$env:temp\demo1.rdg"

RDCMan {
    RDCGroup Production {
        RDCGroup DMZ {
            RDCServer Server1
        }
        RDCGroup Internal {
            RDCServer Server2
        }
    }
    RDCGroup QA {
        RDCServer Server3
        RDCServer Server4
    }
} | Set-Content -Path "$env:temp\demo2.rdg"
& "$env:temp\demo2.rdg"


# Where is the invoke?
function Build-RDCMan 
{
    [cmdletbinding()]
    param([string]$DestinationPath)

    $rdgList = Get-ChildItem *.rdg.ps1 -Recurse
    foreach($file in $rdgList)
    {
        $splat = @{
            Path = $DestinationPath
            ChildPath = $file.basename
        }
        $path = Join-Path @splat
        & $file.fullname | Set-Content -Path $path
    }
}

# end

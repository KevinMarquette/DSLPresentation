
# DSC
Configuration WebsiteTest {

    Import-DscResource -ModuleName PsDesiredStateConfiguration

    Node 'localhost' {

        WindowsFeature WebServer {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        File WebsiteContent {
            Ensure = 'Present'
            SourcePath = 'c:\test\index.htm'
            DestinationPath = 'c:\inetpub\wwwroot'
        }
    }
}


# Pester
Describe 'Notepad' {
    It 'Exists in Windows folder' {
        'C:\Windows\notepad.exe' | Should -Exist
    }
}
<#
Describing Notepad
  [+] Exists in Windows folder 254ms
#>


# InvokeBuild
task Build {
    exec { MSBuild Project.csproj /t:Build /p:Configuration=Release }
}

task Clean {
    Remove-Item bin, obj -Recurse -Force -ErrorAction 0
}


# PSGraph
Import-Module PSGraph
Graph {
    Node start,middle,end @{shape='box'}
    Edge -From start -To middle
    Edge -From middle -To end
} | Show-PSGraph


# PlasterDSL
Import-Module PlasterManifestDSL
PlasterManifest {
    Metadata {
        Title = "DC Custom Function Template"
        TemplateName = 'CustomFunction'
    }
    Parameters {
        Text -Name "FunctionName" -Prompt "Name of your function"
    }
    Content {
        TemplateFile -Source 'functionTemplate.ps1' -Destination '${PLASTER_PARAM_FunctionName}.ps1'
        TemplateFile -Source 'testsTemplate.ps1' -Destination '${PLASTER_PARAM_FunctionName}.tests.ps1'
    }
} | code -

# End

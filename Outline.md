* intro
** Describe general vs dsl

The pipeline is its own type of DSL. Select and Where

* DSL examples
* basic DSL pattern with scriptblocks
* defining an interface
* abusing advanced functions
* common design patterns
* data vs constrained scriptblocks
* Dynamic Keyword

``` html
<html>
    <body>
    <h1>My heading</h1>
        A basic page of html
    </body>
</html>
```

``` powershell
Import-Module -Name $PSScriptRoot\..\PlasterDSL.psd1 -Force -Verbose
PlasterManifest {
    Metadata {
        Title = "DC Custom Function Template"
    }
    Parameters {
        Text -Name "FunctionName" -Prompt "Name of your function"
    }
} | Export-PlasterManifest -Destination C:\temp\plasterManifest.xml -Verbose -PassThru | % {Code $psitem.fullname}
```
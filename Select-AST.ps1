# querying the AST

The abstract syntax tree.

nobody ever said the ast was easy to work with. 

    [ScriptBlock]$Predicate = {
        Param ([System.Management.Automation.Language.Ast]$Ast)

        [bool]$ReturnValue = $False
        If ($Ast -is [System.Management.Automation.Language.AssignmentStatementAst]) {

            [System.Management.Automation.Language.AssignmentStatementAst]$VariableAst = $Ast
            If ($VariableAst.Left.VariablePath.UserPath -cnotmatch '^([A-Z][a-z]+)+$') {
                $ReturnValue = $True
            }
        }
        return $ReturnValue
    }

    #region Finds ASTs that match the predicates.
    [System.Management.Automation.Language.Ast[]]$Results = $ScriptBlockAst.FindAll($Predicate, $True)

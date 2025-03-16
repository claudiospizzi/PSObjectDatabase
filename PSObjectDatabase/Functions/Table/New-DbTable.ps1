<#
    .SYNOPSIS
        .

    .DESCRIPTION
        .

    .INPUTS
        .

    .OUTPUTS
        .

    .EXAMPLE
        PS C:\> New-DbTable
        .

    .LINK
        https://github.com/claudiospizzi/PSObjectDatabase
#>
function New-DbTable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [System.Object]
        $Database,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    try
    {
        $Database = Find-DbDatabase -Database $Database

        # ToDo...
        # The table storage must be there...
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

Register-ArgumentCompleter -CommandName 'New-DbTable' -ParameterName 'Database' -ScriptBlock {
    param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-DbDatabase -WarningAction 'SilentlyContinue' -ErrorAction 'SilentlyContinue' | Where-Object { $_.Name -like "$wordToComplete*" } | Select-Object -ExpandProperty 'Name'
}

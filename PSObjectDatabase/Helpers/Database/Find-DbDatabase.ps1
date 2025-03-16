<#
    .SYNOPSIS
        Internal helper function to find a database base on no input (by using
        the context), by name or by a database object.

    .LINK
        https://github.com/claudiospizzi/PSObjectDatabase
#>
function Find-DbDatabase
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.Object]
        $Database
    )

    if ([System.String]::IsNullOrEmpty($Database))
    {
        # ToDo: Get from context or throw an error
    }
    elseif ($Database.PSObject.TypeNames -contains 'PSObjectDatabase.Database')
    {
        return $Database
    }
    else
    {
        $Database = Get-DbDatabase -Name $Database | Select-Object -First 1
        if ($null -ne $Database)
        {
            return $Database
        }
    }

    # Fallback to throw an error if no database was found.
    throw "Database was not found."
}

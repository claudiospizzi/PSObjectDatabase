<#
    .SYNOPSIS
        Get all available or the selected databases.

    .DESCRIPTION
        Get all available or the selected databases. The function supports
        filtering by id, name, and location. The function returns all databases
        if no filter is specified.

    .OUTPUTS
        PSObjectDatabase.Database

    .EXAMPLE
        PS C:\> Get-DbDatabase
        Get all available databases.

    .EXAMPLE
        PS C:\> Get-DbDatabase -Id 'cf812122-e978-4652-a092-76aa69f5a782'
        Get the database with the specified id.

    .EXAMPLE
        PS C:\> Get-DbDatabase -Name 'My*'
        Get all databases matching the specified name.

    .EXAMPLE
        PS C:\> Get-DbDatabase -Location 'User'
        Get all databases in the specified location.

    .LINK
        https://github.com/claudiospizzi/PSObjectDatabase
#>
function Get-DbDatabase
{
    [CmdletBinding()]
    param
    (
        # The id of the database.
        [Parameter(Mandatory = $false)]
        [System.String[]]
        $Id,

        # The name of the database. Supports wildcards.
        [Parameter(Mandatory = $false)]
        [SupportsWildcards()]
        [System.String]
        $Name,

        # The database location.
        [Parameter(Mandatory = $false)]
        [System.String]
        $Location

        # # Option to select a single database (the first matching) and throw an
        # # error if the database does not exist.
        # [Parameter(Mandatory = $false)]
        # [Switch]
        # $Strict
    )

    try
    {
        $dbDatabases = @()
        foreach ($dbLocation in $Script:PSOBJECTDATABASE_LOCATIONS)
        {
            $dbLocationDatabases = Import-Clixml -Path $dbLocation.Index
            if ($dbLocationDatabases.Count -gt 0)
            {
                foreach ($dbLocationDatabase in $dbLocationDatabases)
                {
                    if ($dbLocationDatabase.Engine -notin 'XML')
                    {
                        Write-Warning "[PSObjectDatabase] The database '$($dbLocationDatabase.Name)' has an unsupported database engine: $($dbLocationDatabase.Engine)"
                        continue
                    }

                    $dbDatabases += [PSCustomObject] @{
                        PSTypeName = 'PSObjectDatabase.Database'
                        Id         = $dbLocationDatabase.Id
                        Name       = $dbLocationDatabase.Name
                        Engine     = $dbLocationDatabase.Engine
                        Location   = $dbLocation.Id
                    }
                }
            }
        }

        if ($PSBoundParameters.ContainsKey('Id'))
        {
            $dbDatabases = @($dbDatabases | Where-Object { $Id -contains $_.Id })
        }
        if ($PSBoundParameters.ContainsKey('Name'))
        {
            $dbDatabases = @($dbDatabases | Where-Object { $_.Name -like $Name })
        }
        if ($PSBoundParameters.ContainsKey('Location'))
        {
            $dbDatabases = @($dbDatabases | Where-Object { $_.Location -eq $Location })
        }

        Write-Output $dbDatabases
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

Register-ArgumentCompleter -CommandName 'Get-DbDatabase' -ParameterName 'Location' -ScriptBlock {
    param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Script:PSOBJECTDATABASE_LOCATIONS.Id
}

<#
    .SYNOPSIS
        Create a new database.

    .DESCRIPTION
        Create a new empty database with the specified name. The database is
        stored in the specified location, which defaults to 'User'.

    .OUTPUTS
        PSObjectDatabase.Database

    .EXAMPLE
        PS C:\> New-DbDatabase -Name 'MyDatabase'
        Create a new database with the specified name.

    .EXAMPLE
        PS C:\> New-DbDatabase -Name 'MyDatabase' -Location 'System'
        Create a new database with the specified name in the system location.

    .LINK
        https://github.com/claudiospizzi/PSObjectDatabase
#>
function New-DbDatabase
{
    [CmdletBinding()]
    param
    (
        # The name of the database.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # The storage engine of the database.
        [Parameter(Mandatory = $false)]
        [ValidateSet('XML')]
        [System.String]
        $Engine = 'XML',

        # The location of the database.
        [Parameter(Mandatory = $false)]
        [ValidateScript({ $Script:PSOBJECTDATABASE_LOCATIONS.Id -contains $_ })]
        [System.String]
        $Location = 'User'
    )

    try
    {
        $dbLocation = $Script:PSOBJECTDATABASE_LOCATIONS | Where-Object { $_.Id -eq $Location }

        # Verify if the database already exists
        $dbDatabases = Get-DbDatabase -Name $Name
        if ($null -ne $dbDatabases)
        {
            throw "The database named '$Name' already exists."
        }

        $dbDatabase = [PSCustomObject] @{
            PSTypeName = 'PSObjectDatabase.Location'
            Id         = [Guid]::NewGuid().ToString()
            Name       = $Name
            Engine     = $Engine
            Location   = $dbLocation.Id
        }

        # Create the new database in the file system
        $databasePath = Join-Path -Path $dbLocation.Path -ChildPath $dbDatabase.Id
        New-Item -Path $databasePath -ItemType 'Directory' -Force | Out-Null

        # Store the new database in the index file
        $dbLocationDatabases = Import-Clixml -Path $dbLocation.Index
        $dbLocationDatabases += $dbDatabase
        Export-Clixml -Path $dbLocation.Index -InputObject $dbLocationDatabases
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

Register-ArgumentCompleter -CommandName 'New-DbDatabase' -ParameterName 'Location' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Script:PSOBJECTDATABASE_LOCATIONS.Id
}

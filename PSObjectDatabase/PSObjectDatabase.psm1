<#
    .SYNOPSIS
        Root module file.

    .DESCRIPTION
        The root module file loads public functions and private helper functions
        into the module context. Module wide variables are defined and the basic
        setup is ensured.
#>


## Load module functions

# Get and dot source all helper functions (internal)
Split-Path -Path $PSCommandPath |
    Get-ChildItem -Filter 'Helpers' -Directory |
        Get-ChildItem -Include '*.ps1' -File -Recurse |
            ForEach-Object { . $_.FullName }

# Get and dot source all external functions (public)
Split-Path -Path $PSCommandPath |
    Get-ChildItem -Filter 'Functions' -Directory |
        Get-ChildItem -Include '*.ps1' -File -Recurse |
            ForEach-Object { . $_.FullName }


## Module setup

$Script:PSOBJECTDATABASE_LOCATIONS = @(
    [PSCustomObject] @{
        PSTypeName = 'PSObjectDatabase.Location'
        Id         = 'User'
        Path       = Join-Path -Path $Env:LocalAppData -ChildPath 'PSObjectDatabase'
        Index      = Join-Path -Path $Env:LocalAppData -ChildPath 'PSObjectDatabase' | Join-Path -ChildPath 'databases.xml'
    }
    [PSCustomObject] @{
        PSTypeName = 'PSObjectDatabase.Location'
        Id         = 'System'
        Path       = Join-Path -Path $Env:ProgramData -ChildPath 'PSObjectDatabase'
        Index      = Join-Path -Path $Env:ProgramData -ChildPath 'PSObjectDatabase' | Join-Path -ChildPath 'databases.xml'
    }
)

foreach ($dbLocation in $Script:PSOBJECTDATABASE_LOCATIONS)
{
    if (-not (Test-Path -Path $dbLocation.Path))
    {
        New-Item -Path $dbLocation.Path -ItemType 'Directory' -Force | Out-Null
    }

    if (-not (Test-Path -Path $dbLocation.Index))
    {
        Export-Clixml -Path $dbLocation.Index -InputObject @()
    }
}

# Verify if we have multiple databases with the same name in different
# locations, so this can lead to confusion when accessing the database by name.
Get-DbDatabase | Group-Object -Property 'Name' | Where-Object { $_.Count -gt 1 } |
    ForEach-Object { Write-Warning "[PSObjectDatabase] The database '$($_.Name)' exists in multiple locations: $($_.Group.Location -join ', ')" }






Set-DbContext -Database '' -Table ''
Get-DbContext
Clear-DbContext

New-DbDatabase -Name ''
Get-DbDatabase -Name '*'
Remove-DbDatabase -Name ''

New-DbTable -Database '' -Name '' -PrimaryKey '', ''
Get-DbTable -Database ''
Remove-DbTable -Database ''




Add-DbObject -Database '' -Table '' -InputObject $obj
$obj | Add-DbObject


$events = Get-WinEvent -LogName 'Application'

Measure-Command {
    $events |  Export-Clixml -Path C:\Temp\events.xml
}



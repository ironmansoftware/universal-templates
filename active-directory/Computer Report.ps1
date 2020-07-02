$Computers = Get-ADComputer -Server $ComputerName -Credential $Domain -Filter * -Properties @("OperatingSystem", "OperatingSystemServicePack", "Location")

[PSCustomObject]@{
    OperatingSystem = $Computers | Group-Object OperatingSystem | Select-Object Name,Count
    OperatingSystemServicePack = $Computers | Group-Object OperatingSystemServicePack | Select-Object Name,Count
    Location = $Computers | Group-Object Location | ForEach-Object { [PSCustomObject]@{ label = $_.Name; value = $_.count } }
}
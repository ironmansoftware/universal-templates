New-UDPage -Name "Deleted Objects" -Content {
    New-AppBar -Title 'Deleted Objects'
    $Data = Get-ADObject -Filter {(isdeleted -eq $true) -and (name -ne "Deleted Objects")} -includeDeletedObjects @Cache:ConnectionInfo 
    New-UDTable -Data $Data
}
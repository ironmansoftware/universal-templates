New-UDEndpoint -Endpoint {
    try
    {
        Import-Module ActiveDirectory -WarningAction SilentlyContinue

        $Objects = Get-ADObject -Filter { Name -like '*'} @Cache:ConnectionInfo
        $Cache:Classes = $Objects | Group-Object -Property ObjectClass | Sort-Object -Property Count -Descending | Select-Object -First 10

        $Computers = $Objects | Where-Object ObjectClass -eq 'computer'

        $DomainControllers = Get-ADDomainController -Filter {Name -like '*'} @Cache:ConnectionInfo

        $Cache:Computers = @(
            @{ Name = "Total"; Value = ($Computers | Measure-Object).Count }
            @{ Name = "Disabled"; Value = ($Computers | Where-Object Enabled -eq $false | Measure-Object).Count }
            @{ Name = "Domain Controllers"; Value = ($DomainControllers | Measure-Object).Count }
        )

        $Users = Get-ADUser -Filter { Name -like '*'} @Cache:ConnectionInfo -Properties *

        $Cache:Users = @(
            @{ Name = "Total"; Value = ($Users | Measure-Object).Count }
            @{ Name = "Disabled"; Value = ($Users | Where-Object Enabled -eq $false | Measure-Object).Count }
        )

        $Cache:Forest = Get-ADForest @Cache:ConnectionInfo
        $Cache:Domains = Get-ADDomain @Cache:ConnectionInfo
    }
    catch
    {
        $Cache:Error = "Failed to load AD data. $_"
    }
    finally
    {
        $Cache:Loading = $false
    }
}-Schedule (New-UDEndpointSchedule -Every 30 -Second)
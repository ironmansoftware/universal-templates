$Server = 'ironman.local'
$Credential = Get-Secret -Name 'Domain'

New-UDDashboard -Title "Active Directory Help Desk" -Content {
    New-UDCard -Title 'View User' -Content {

        New-UDForm -Content {
            New-UDTextbox -Placeholder 'Identity' -Id 'txtIdentity'
        } -OnSubmit {
            $Input = ConvertFrom-Json $Body
            try
            {
                $Session:UserObject = Get-ADUser -Identity $Input.txtIdentity -Server $Server -Credential $Credential -Properties * -ErrorAction Stop
                Sync-UDElement -Id 'propertyTable'
            }
            catch 
            {
                Show-UDToast -Message $_
            }
        }
    }


    New-UDDynamic -Id 'propertyTable' -Content {
        if ($Session:UserObject)
        {
            $Columns = @(
                New-UDTableColumn -Property Name -Title Name
                New-UDTableColumn -Property Value -Title Value 
            )

            New-UDTable -Data $Session:UserObject.PSObject.Properties -Columns $Columns
        }
        
    }
}
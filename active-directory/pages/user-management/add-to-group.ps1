New-UDPage -Name 'Add to Group' -Url "/user/add-to-group" -Content {

    New-AppBar -Title 'Add user to group'

    New-UDContainer -Content {
        New-UDGrid -Container -Content {
            New-UDGrid -Size 12 -Content {
                New-UDForm -Content {
                    New-UDTextbox -Id 'txtUserName' -Placeholder 'User Name'
                    New-UDTextbox -Id 'txtGroupName' -Placeholder 'Group Name'
                } -OnSubmit {
                    $Data = $Body | ConvertFrom-Json 
    
                    $GroupName = $Data.txtGroupName 
                    $UserName = $Data.txtUserName
    
                    try 
                    { 
                        Add-ADGroupMember -Identity $GroupName -Members (Get-ADUser -Identity $UserName @Cache:ConnectionInfo) @Cache:ConnectionInfo
                        Invoke-UDRedirect -Url "/object/$UserName"
                    }
                    catch 
                    {
                        Show-UDToast -Message "Failed to add user to group. $_"
                    }
                }
            }
        }
    }
}
New-UDPage -Name 'Create User' -Url "/user/create" -Endpoint {
    New-AppBar -Title 'Create user'
    
    New-UDGrid -Container -Content {
        New-UDGrid -Size 12 -Content {
            New-UDForm -Content {
                New-UDTextbox -Id 'txtFirstName' -Placeholder "First Name"
                New-UDTextbox -Id 'txtLastName' -Placeholder "Last Name"
                New-UDTextbox -Id 'txtUserName' -Placeholder "User Name"
                New-UDTextbox -Id 'txtPassword' -Placeholder "Password"
            } -OnSubmit {
                try 
                {
                    New-ADUser -Name $UserName -GivenName $FirstName -Surname $LastName @Cache:ConnectionInfo 
                    $SecurePassword = ConvertTo-SecureString -AsPlainText -String $Password -Force
                    Set-ADAccountPassword -Reset -NewPassword $SecurePassword -Identity $UserName @Cache:ConnectionInfo
                    Invoke-UDRedirect -Url "/object/$UserName"
                }
                catch 
                {
                    Show-UDToast -Message "Failed to add user. $_"
                }
            }
        }
    }
}
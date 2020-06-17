New-UDPage -Name 'Reset Password' -Url "/user/reset-password" -Endpoint {
    New-AppBar -Title 'Reset Password'
    
    New-UDGrid -Container -Content {
        New-UDGrid -Size 12 -Content {
            New-UDForm -Content {
                New-UDTextbox -Id 'txtUserName' -Placeholder 'Account Name'
                New-UDTextbox -Id 'txtPassword' -Placeholder 'Password'
            } -OnSubmit {
                try 
                { 
                    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
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
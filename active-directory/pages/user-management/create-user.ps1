New-UDPage -Name 'Create User' -Url "/user/create" -Icon Plus -Endpoint {
    New-UDRow -Columns {
        New-UDColumn -Size 12 -Content {
            New-UDInput -Title "Create User" -SubmitText "Create" -Content {
                New-UDInputField -Name "FirstName" -Placeholder "First Name" -Type "textbox"
                New-UDInputField -Name "LastName" -Placeholder "Last Name" -Type "textbox"
                New-UDInputField -Name "UserName" -Placeholder "Account Name" -Type "textbox"
                New-UDInputField -Name "Password" -Placeholder "Password" -Type "password"
            } -Endpoint {
                param(
                    $FirstName,
                    $LastName,
                    $UserName,
                    $Password
                )
        
                try 
                {
                    New-ADUser -Name $UserName -GivenName $FirstName -Surname $LastName @Cache:ConnectionInfo 
                    $SecurePassword = ConvertTo-SecureString -AsPlainText -String $Password -Force
                    Set-ADAccountPassword -Reset -NewPassword $SecurePassword -Identity $UserName @Cache:ConnectionInfo
                    New-UDInputAction -RedirectUrl "/object/$UserName"
                }
                catch 
                {
                    New-UDInputAction -Toast "Failed to add user. $_"
                }
            }
        }
    }
}
Set-PSUAuthenticationMethod -ScriptBlock { 
param(
    [PSCredential]$Credential
)

$Result = [Security.AuthenticationResult]::new()
if ($Credential.UserName -eq 'Admin') 
{
    #Maintain the out of box admin user
    $Result.UserName = 'Default Admin'
    $Result.Success = $true 
}
else
{
    $User = Get-ADUser -Identity $Credential.UserName -Server ironman.local -Credential $Credential -ErrorAction SilentlyContinue
    if ($null -ne $User)
    {
        $Result.UserName = ($Credential.UserName)
        $Result.Success = $true 
    }
}

$Result
 }
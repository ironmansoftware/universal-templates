Set-PSUAuthenticationMethod -ScriptBlock { 
param(
    [PSCredential]$Credential
)

#
#   You can call whatever cmdlets you like to conduct authentication here.
#   Just make sure to return the $Result with the Success property set to $true
#

$Result = [Security.AuthenticationResult]::new()
if ($Credential.UserName -eq 'Admin') 
{
    $Result.UserName = 'Admin'
    $Result.Success = $true 
}
$Result
 }
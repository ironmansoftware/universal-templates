param(
    [String]$Identity,
    [String]$Password,
    [Switch]$Unlock,
    [Switch]$ChangePasswordOnLogon
)

$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

Set-ADAccountPassword -Identity $Identity -NewPassword $SecurePassword -Reset -Server $ComputerName -Credential $Domain

if ($Unlock)
{
    Unlock-ADAccount –Identity $Identity -Server $ComputerName -Credential $Domain
}

if ($ChangePasswordOnLogon)
{
    Set-ADUser –Identity $Identity -ChangePasswordAtLogon $true -Server $ComputerName -Credential $Domain
}
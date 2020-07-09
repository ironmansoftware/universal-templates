New-PSURole -Name "Administrator" -Description "Administrators can manage settings of UA, create and edit any entity within UA and view all the entities within UA." -Policy { 
param(
$User
)
        
#
# Policies should return $true or $false to determine whether the user has the particular 
# claim that require them for that role.
#

$true
 } 
New-PSURole -Name "Operator" -Description "Operators have access to manage and execute scripts, create other entities within UA but cannot manage UA itself." -Policy { 
param(
$User
)
        
#
# Policies should return $true or $false to determine whether the user has the particular 
# claim that require them for that role.
#

$true
 } 
New-PSURole -Name "Reader" -Description "Readers have read-only access to UA. They cannot make changes to any entity within the system." -Policy { 
param(
$User
)
        
#
# Policies should return $true or $false to determine whether the user has the particular 
# claim that require them for that role.
#

$true
 }
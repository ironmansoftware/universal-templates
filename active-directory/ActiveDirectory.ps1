$Cache:Loading = $true
$Cache:ChartColorPalette = @('#5899DA', '#E8743B', '#19A979', '#ED4A7B', '#945ECF', '#13A4B4', '#525DF4', '#BF399E', '#6C8893', '#EE6868', '#2F6497')
$ConnectionInfo = @{
    Server = 'server'
    Credential = Get-Secret -Name 'ActiveDirectory'
}

$Cache:ConnectionInfo = $ConnectionInfo

Import-Module ActiveDirectory -WarningAction SilentlyContinue
New-PSDrive -Name AD -PSProvider ActiveDirectory @ConnectionInfo -Root '//RootDSE/' -Scope Global | Out-Null

function New-ADIcon {
    param($ObjectClass, $Size) 

    $icon = 'question_circle'

    if ($ObjectClass -eq 'user') {
        $icon = 'user'
    }

    if ($ObjectClass -eq 'computer') {
        $icon = 'desktop'
    }

    if ($ObjectClass -eq 'group') {
        $icon = 'users'
    }

    New-UDIcon -Icon $icon -Size $Size
}

$Pages = Get-ChildItem (Join-Path $PSScriptRoot 'pages') -Recurse -File | ForEach-Object {
    & $_.FullName
} 

Get-ChildItem (Join-Path $PSScriptRoot 'endpoints') | ForEach-Object {
    & $_.FullName
} | Out-Null

$Navigation = New-UDSideNav -Content {
    New-UDSideNavItem -Text 'Home' -Url 'Home' -Icon home
    New-UDSideNavItem -Text 'Deleted Objects' -Url 'deleted-objects' -Icon user_times
    New-UDSideNavItem -Text 'Explorer' -Url 'Explorer' -Icon folder
    New-UDSideNavItem -Text 'Search' -Url 'Search' -Icon search
    New-UDSideNavItem -Text 'User Management' -Icon user  -Children {
        New-UDSideNavItem -Text 'Add User To Group' -Url 'user/add-to-group' -Icon user_plus
        New-UDSideNavItem -Text 'Create User' -Url 'user/create' -Icon plus_circle
        New-UDSideNavItem -Text 'Reset Password' -Url 'user/reset-password' -Icon code
    }
}

New-UDDashboard -Pages $Pages -Navigation $Navigation -Title 'AD'
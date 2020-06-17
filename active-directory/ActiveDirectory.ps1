$Cache:Loading = $true
$Cache:ChartColorPalette = @('#5899DA', '#E8743B', '#19A979', '#ED4A7B', '#945ECF', '#13A4B4', '#525DF4', '#BF399E', '#6C8893', '#EE6868', '#2F6497')
$ConnectionInfo = @{
    Server = 'ironman.local'
    Credential = Get-Secret -Name 'ActiveDirectory'
}

$Cache:ConnectionInfo = $ConnectionInfo

Import-Module ActiveDirectory -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

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

function New-AppBar {
    param($title)

    $Drawer = New-UDDrawer -Children {
        New-UDList -Children {
            New-UDListItem -Label "Home" -OnClick { Invoke-UDRedirect -Url "/home" }
            New-UDListItem -Label "Deleted Objects" -OnClick { Invoke-UDRedirect -Url "/deleted-objects" }
            New-UDListItem -Label "Explorer" -OnClick { Invoke-UDRedirect -Url "/powershell-universal-dashboard" }
            New-UDListItem -Label "Search" -OnClick { Invoke-UDRedirect -Url "/search" }
            New-UDListItem -Label "User Management" -Children {
                New-UDListItem -Label "Add User to Group" -OnClick { Invoke-UDRedirect -Url "/user/add-to-group" }
                New-UDListItem -Label "Create User" -OnClick { Invoke-UDRedirect -Url "/user/create" }
                New-UDListItem -Label "Reset Password" -OnClick { Invoke-UDRedirect -Url "/user/reset-password" }
            }
        }
    }

    New-UDAppbar -Children {
        New-UDElement -Tag 'div' -Content {$title}
    } -Drawer $Drawer
}

$Complete = @("home", "search", "add-to-group", "create-user", 'reset-password', 'deleted-objects')

$Pages = Get-ChildItem (Join-Path $PSScriptRoot 'pages') -Recurse -File | ForEach-Object {
    foreach($page in $Complete)
    {
        if ($_.FullName.Contains($page))
        {
            . $_.FullName
        }
    }  
} 

Get-ChildItem (Join-Path $PSScriptRoot 'endpoints') | ForEach-Object {
    . $_.FullName
} | Out-Null

New-UDDashboard -Pages $Pages -Title 'Active Directory'
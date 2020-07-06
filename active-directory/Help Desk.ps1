$Server = 'ironman.local'
$Credential = Get-Secret -Name 'Domain'

Import-Module "$Env:ProgramData\PowerShellUniversal\Dashboard\Components\UniversalDashboard.Charts\1.0.0\UniversalDashboard.Charts.psd1"

$Pages = @()

$Pages += New-UDPage -Name 'Dashboard' -Content {
    $LatestComputerReport = Get-UAScript -Name 'Computer Report.ps1' | Get-UAJob -OrderBy Id -OrderDirection Descending -First 1 | Get-UAJobPipelineOutput
    New-UDNivoChart -Data $LatestComputerReport.OperatingSystem -Bar -Keys "count" -IndexBy 'name' -Height 500 -Responsive
    New-UDNivoChart -Data $LatestComputerReport.OperatingSystemServicePack -Bar -Keys "count" -IndexBy 'name' -Height 500 -Responsive
    New-UDNivoChart -Data $LatestComputerReport.Location -Pie 

    $LastTenComputerReports = Get-UAScript -Name 'Computer Report.ps1' | Get-UAJob -OrderBy Id -OrderDirection Ascending -First 25 | Get-UAJobPipelineOutput
    
    $Data = @()
    foreach($jobOutput in $LastTenComputerReports)
    {
        $Location = $jobOutput.Location
        
        $record = @{}
        $Location | ForEach-Object {

            if ($_.Label -ne $null) 
            {
                $record[$_.Label.Split(',')[0]] = [int]$_.Value
            }
        }

        if ($record.Count -ne 0)
        {
            $Data += $record
        }
    }
    
    New-UDNivoChart -Stream -Data $Data -Height 500 -Responsive -Keys @('hailey', 'madison')
}


$Pages += New-UDPage -Name 'Toolbox' -Content {
    New-UDTabs -Tabs {

        New-UDTab -Text 'Restore User' -Content {

            $Columns = @(
                New-UDTableColumn -Property Name -Title "Name"
                New-UDTableColumn -Property DistinguishedName -Title "Distinguished Name"
                New-UDTableColumn -Property DistinguishedName -Title Restore -Render {
                    $Item = $Body | ConvertFrom-Json 
                    New-UDButton -Id "btn$($Item.ObjectGuid)" -Text "Restore" -OnClick { 
                        Show-UDToast -Message "Restoring user $($Item.Name)" -Duration 5000

                        Invoke-UAScript -Name 'Restore User.ps1' -DistinguishedName $Item.DistinguishedName | Tee-Object -Variable job | Wait-UAJob

                        $Job = Get-UAJob -Id $Job.Id 
                        if ($Job.Status -eq 'Completed')
                        {
                            Show-UDToast -Message "Restored user $($Item.Name)" -Duration 5000
                        }
                        else 
                        {
                            $Output = Get-UAJobOutput -JobId $Job.Id | Select-Object -Expand Message
                            Show-UDToast -Message "Failed to restore user. $($Output -join "`n")" -BackgroundColor red -MessageColor white -Duration 5000
                        }
                    }
                }
            )

            $DeletedUsers = Get-ADObject -Filter 'IsDeleted -eq $true -and objectClass -eq "user"' -Server $Server -Credential $Credential -IncludeDeletedObjects
            New-UDTable -Data $DeletedUsers -Columns $Columns
        }

        New-UDTab -Text 'View Users' -Content {
            New-UDCard -Title 'View User' -Content {

                New-UDForm -Content {
                    New-UDTextbox -Placeholder 'Identity' -Id 'txtIdentity'
                } -OnSubmit {
                    $Input = ConvertFrom-Json $Body
                    try
                    {
                        $Session:UserObject = Get-ADUser -Identity $Input.txtIdentity -Server $Server -Credential $Credential -Properties * -ErrorAction Stop
                        Sync-UDElement -Id 'propertyTable'
                    }
                    catch 
                    {
                        Show-UDToast -Message $_
                    }
                }
            }

            New-UDDynamic -Id 'propertyTable' -Content {
                if ($Session:UserObject)
                {
                    $Columns = @(
                        New-UDTableColumn -Property Name -Title Name
                        New-UDTableColumn -Property Value -Title Value 
                    )

                    New-UDTable -Data $Session:UserObject.PSObject.Properties -Columns $Columns
                }
            }
        }

        New-UDTab -Text 'Reset Password' -Content {
            New-UDCard -Title 'Reset Password' -Content {
                New-UDForm -Content {
                    New-UDTextbox -Placeholder 'Identity' -Id 'txtIdentity'
                    New-UDTextbox -Placeholder 'Password' -Id 'txtPassword' -Type password
                    New-UDCheckbox -Label 'Unlock Account' -Id 'chkUnlock'
                    New-UDCheckbox -Label 'Change Password on Next Logon' -Id 'chkChangePassword' 
                } -OnSubmit {
                    $Input = ConvertFrom-Json $Body

                    $Parameters = @{
                        Identity = $Input.txtIdentity 
                        Password = $Input.txtPassword
                    }

                    if ($Input.chkChangePassword -eq 'true')
                    {
                        $Parameters['ChangePasswordOnLogon'] = $true 
                    }

                    if ($Input.chkUnlock -eq 'true')
                    {
                        $Parameters['Unlock'] = $true 
                    }

                    Invoke-UAScript -Name 'Reset Password.ps1' @Parameters | Tee-Object -Variable job | Wait-UAJob

                    $Job = Get-UAJob -Id $Job.Id 
                    if ($Job.Status -eq 'Completed')
                    {
                        Show-UDToast -Message "Reset password for $($Input.txtIdentity)" -Duration 5000
                    }
                    else 
                    {
                        $Output = Get-UAJobOutput -JobId $Job.Id | Select-Object -Expand Message
                        Show-UDToast -Message "Failed to reset password. $($Output -join "`n")" -BackgroundColor red -MessageColor white -Duration 5000
                    }
                }
            }
        }
    }
}

New-UDDashboard -Title "Active Directory Help Desk" -Pages $Pages
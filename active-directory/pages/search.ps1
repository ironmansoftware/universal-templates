New-UDPage -Name "Search" -Content {

    New-AppBar -Title 'Search'

    New-UDElement -Tag "div" -Attributes @{
        style = @{
            height = '25px'
        }
    }

    New-UDContainer -Content {
        New-UDGrid -Container -Content {
            New-UDGrid -Size 10 -Content {
                New-UDForm -OnSubmit {
                    $Search = $Body | ConvertFrom-Json 
                    $Value = $Search.txtSearch

                    $Objects = Get-ADObject -Filter "Name -like '$Value' -or samAccountName -like '$Value'" -ResultSetSize 20 @Cache:ConnectionInfo -IncludeDeletedObjects

                    $Session:SearchResults = $Objects | ForEach-Object {
                        [PSCustomObject]@{
                            Name = $_.Name
                            MoreInfo = New-UDButton -Text "More Info" -OnClick {
                                Invoke-UDRedirect -Url "/object/$($_.Name)"
                            }
                        }
                    } 

                    Sync-UDElement -Id searchResults
                } -Content {
                    New-UDTextbox -Id "txtSearch" -Label "Search" -Placeholder "Search for an object" 
                }
            }
        }
    
        New-UDGrid -Container -Content {
            New-UDGrid -SmallSize 10 -Content {
                New-UDDynamic -Id 'searchResults' -Content {
                    if ($Session:SearchResults)
                    {
                        New-UDTable -Data $Session:SearchResults
                    }
                }
            }
        }
    }
}
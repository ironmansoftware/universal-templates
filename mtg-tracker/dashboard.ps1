function New-MtgCard {
    param($Result, [Switch]$Battlefield)

    $link = $Result.related_uris.gatherer
    if (-not $link) {
        $link = $Result.purchase_uris.tcgplayer
    }

    New-UDLink -url $link -Children {
        New-UDImage -Url $Result.image_uris.small
    } -OpenInNewWindow

    if ($Battlefield) {
        New-UDButton -Text "Tap"
        New-UDButton -Text "Graveyard"
        New-UDButton -Text "Exile"
    }
}

New-UDDashboard -Title "Gatherer!" -Content {

    New-UDContainer -Children {
        if ($Cache:Game -eq $null) {
            New-UDTextbox -Label "Enter User Name" -Id "userName"
            New-UDButton -Text "Start Game" -OnClick {
                $Session:UserName = (Get-UDElement -Id 'userName')['value']
                $Cache:Game = @{
                    Players = @{
                        Name = $Session:UserName
                        Life = 20
                        Cards = @()
                    }
                }
                Invoke-UDRedirect -Url "/"
            }
            return;
        }
    
        if ($Session:UserName -eq $null) {
    
            New-UDTextbox -Label "Enter User Name" -Id "userName"
            New-UDButton -Text "Join" -OnClick {
                $Cache:Game.Players += @{
                    Name = $Session:UserName
                    Life = 20
                    Cards = @()
                }
                $Session:UserName = (Get-UDElement -Id 'userName')['value']
                Invoke-UDRedirect -Url "/"
            }
    
            return;
        }
    
        New-UDRow -Columns {
            New-UDColumn -SmallSize 4 -Content {
                New-UDButton -Text "New Game" -OnClick {
                    $Cache:Game = $null 
                    Invoke-UDRedirect -Url '/' 
                }
            }
        }
    
        New-UDRow -Columns {
            New-UDColumn -SmallSize 4 -Content {
                New-UDTextbox -Label "Card Name" -Id "searchText"
                New-UDButton -Text "Search" -OnClick {
                    Sync-UDElement -Id 'searchResults'
                }
            }
            New-UDColumn -SmallSize 8 -Content {
                New-UDDynamic -Id "searchResults" -Content {
                    $Value = (Get-UDElement -Id 'searchText')['value']
                    if ($value -ne $null -and $value -ne "") {
                        $Result = Invoke-RestMethod "https://api.scryfall.com/cards/named?fuzzy=$value"
            
                        New-MtgCard -Result $Result
    
                        New-UDButton -Text "Play card" -OnClick {
                            $Player = $Cache:Game.Players | Where-Object Name -eq $Session:UserName 
                            $Player.Cards += $Result
                            Sync-UDElement -Id 'battlefield'# -Broadcast
                            Set-UDElement -Id 'searchText' -Properties @{
                                value = ''
                            }
                            Sync-UDElement -Id 'searchResults'
                        }
                    }   
                }
            }
        }
    
        New-UDDynamic -Id 'battlefield' -Content {
            foreach($player in $Cache:Game.Players) {
                New-UDRow -Columns {
                    New-UDTypography -Text $player.Name -Variant h4
    
                    New-UDRow -Columns {
                        New-UDColumn -LargeSize 4 -Content {
                            New-UDTypography -Text "Life: $($player.Life)"
                        }
                    }
                    
                    New-UDRow -Columns {
                        foreach($card in $Player.cards) {
                            New-UDColumn -LargeSize 1 -Content {
                                New-MtgCard -Result $card -Battlefield
                            }
                        }
                    }
                }
            }
        }
    }
}

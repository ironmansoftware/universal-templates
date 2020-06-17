New-UDPage -Name "Home" -DefaultHomePage -Content {
    New-AppBar -Title 'Home'

    New-UDContainer -Children {

        New-UDGrid -Container -Content {
            New-UDGrid -Size 12 -Content {
                if ($Cache:Loading) {
                    New-UDProgress -Circular -Color Green 
                }
                elseif ($Cache:Error -ne $null) 
                {
                    New-UDCard -Title "Error loading data" -Content {
                        $Cache:Error
                    }
                }
                else 
                {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Size 4 -Content {
                            New-UDNivoChart -Bar -Keys "value" -IndexBy 'name' -Data $Cache:Users -Height 300 -Responsive
                        }
                        New-UDGrid -Size 4 -Content {
                            New-UDNivoChart -Bar -Keys "value" -IndexBy 'name' -Data $Cache:Computers -Height 300 -Responsive
                        }
                        New-UDGrid -Size 4 -Content {
                            New-UDNivoChart -Bar -Keys "count" -IndexBy 'name' -Data $Cache:Classes -Height 300 -Responsive
                        }
                    }
    
                    New-UDGrid -Container -Content {
                        New-UDGrid -Size 12 -Content {

                            New-UDTypography -Text 'Forests' -Variant h3

                            $Data = $Cache:Forest | ForEach-Object {
                                [PSCustomObject]@{
                                    Name = $_.Name
                                    RootDomain = $_.RootDomain
                                    ForestMode = $_.ForestMode.ToString()
                                }
                            }
    
                            New-UDTable -Data $Data
                        }
                    }
    
                    New-UDGrid -Container -Content {
                        New-UDGrid -Size 12 -Content {
                            New-UDTypography -Text 'Domains' -Variant h3
                            
                            $Data = $Cache:Domains | ForEach-Object {
                                [PSCustomObject]@{
                                    Name = $_.Name
                                    Forest = $_.Forest
                                    DomainMode = $_.DomainMode.ToString()
                                    DnsRoot = $_.DNSRoot
                                }
                            }
                            New-UDTable -Data $Data
                        }
                    }
                }
            }
        } 
    }

}
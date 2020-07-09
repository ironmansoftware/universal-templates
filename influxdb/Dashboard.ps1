Import-Module C:\ProgramData\PowerShellUniversal\Dashboard\Components\UniversalDashboard.Charts\1.0.0\UniversalDashboard.Charts.psd1
Import-Module "$PSScriptRoot\influxdb.psm1"

New-UDDashboard -Title "Server Performance Dashboard" -Content {

New-UDRow -Columns {
    New-UDColumn -SmallSize 12 -Content {
        New-UDHeading -Text "$ENV:ComputerName" -Size 4
    }
}

New-UDRow -Columns {
    
}

New-UDRow -Columns {
    New-UDColumn -SmallSize 12 -Content {
        New-UDCard -Title "Performance Metrics" -Content {
            New-UDElement -Tag 'div' -Attributes @{ style = @{ "height" = '400px'}} -AutoRefresh -RefreshInterval 5 -Endpoint {

                $Data = Get-InfluxDb -Query 'SELECT * FROM counter WHERE time > now() - 5m GROUP BY counter'

                $ChartData = @()

                foreach($series in $data) {

                    $SeriesData = @{
                        id =  $series.counter
                        data = @()
                    }

                    foreach($field in $Series.Fields) {
                        $SeriesData.data += @{
                            x = $field.time
                            y = $field.value
                        }                        
                    }

                    $ChartData += $SeriesData
                }

                $BottomAxis = New-UDNivoChartAxisOptions -TickRotation 90
                New-UDNivoChart -Data $ChartData -Id "performanceStats" -Line -Responsive -MarginBottom 50 -MarginTop 50 -MarginRight 110 -MarginLeft 60 -YScaleMax 100 -YScaleMin 0 -EnableArea -AxisBottom $BottomAxis -Colors 'paired'
            }
        }
    }
}

New-UDRow -Columns {
    New-UDColumn -SmallSize 12 -Content {
        New-UDCard -Title "Network Traffic" -Content {
            New-UDElement -Tag 'div' -Attributes @{ style = @{ "height" = '400px'}} -AutoRefresh -RefreshInterval 5 -Endpoint {

                $Data = Get-InfluxDb -Query 'SELECT * FROM network WHERE time > now() - 5m GROUP BY counter'

                $ChartData = for($i = 0; $i -lt $data[0].Fields.length; $i++) {
                    $Point = @{}
                    foreach($series in $data) {
                        $Point[$series.counter] = $series.fields[$i].value
                    }
                    $Point
                }
                New-UDNivoChart -Stream -Data $ChartData -Id "networkData" -Responsive -MarginBottom 50 -MarginTop 50 -MarginRight 110 -MarginLeft 60 -Keys $Cache:NetworkStats -OffsetType expand -Curve linear  -Colors 'paired'
            }
        }
    }
}
}
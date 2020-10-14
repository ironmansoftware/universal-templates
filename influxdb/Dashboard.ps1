Import-Module "$PSScriptRoot\influxdb.psm1"

New-UDDashboard -Title 'Performance Data' -Content {

    New-UDGridLayout -Content {
        New-UDCard -Id 'networkData' -Title 'Network Data' -Content {
            New-UDElement -Tag 'div' -Attributes @{ style = @{ width = "100%"; height = "100%" }}  -AutoRefresh -RefreshInterval 5 -Endpoint {

                $Data = Get-InfluxDb -Query 'SELECT * FROM network WHERE time > now() - 60m GROUP BY counter'

                $ChartData = for($i = 0; $i -lt $data[0].Fields.length; $i++) {
                    $Point = @{}
                    foreach($series in $data) {
                        $Point[$series.counter] = $series.fields[$i].value
                    }
                    $Point
                }

                $NetworkStats = @(
                    '\network adapter(*)\bytes received/sec'
                    '\network adapter(*)\bytes sent/sec'
                )

                New-UDNivoChart -Height '250' -Stream -Data $ChartData -Id "networkData" -Responsive -MarginBottom 50 -MarginTop 50 -MarginRight 110 -MarginLeft 60 -Keys $NetworkStats -OffsetType expand -Curve linear
            }
        }

        New-UDCard -Id 'performanceData' -Title 'Performance Data' -Content {
            New-UDElement -Tag 'div' -Attributes @{ style = @{ width = "100%"; height = "100%" }} -AutoRefresh -RefreshInterval 5 -Endpoint {

                $Data = Get-InfluxDb -Query 'SELECT * FROM counter WHERE time > now() - 60m GROUP BY counter'

                $ChartData = @()
  
      
                foreach($series in $data) {

                    $SeriesData = @{
                        id =  $series.counter
                        data = @()
                    }
                    
                    $i = 0
                    foreach($field in $Series.Fields) {
                        $SeriesData.data += @{
                            x = $i
                            y = $field.value
                        }               
                        $i++         
                    }

                    $ChartData += $SeriesData
                }

                New-UDNivoChart -Height 250 -Data $ChartData -Id "performanceStats" -Line -Responsive -MarginBottom 50 -MarginTop 50 -MarginRight 110 -MarginLeft 60 -YScaleMax 100 -YScaleMin 0 -EnableArea
            }
        }

        New-UDCard -Id 'diskData' -Title 'Disk Data' -Content {
            New-UDElement -Tag 'div' -AutoRefresh -RefreshInterval 5 -Endpoint {

                $Data = Get-InfluxDb -Query 'SELECT * FROM disk WHERE time > now() - 60m'

                New-UDTable -Data $Data.Fields
            }
        }
    } -Design
}

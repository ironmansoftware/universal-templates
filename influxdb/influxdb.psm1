function Get-InfluxDb {
    param(
        [Parameter()]
        $Url = 'http://localhost:8086/query?db=performance_data',
        [Parameter()]
        $Query
    )

    $Results = Invoke-RestMethod -Uri "$Url&q=$Query"

    foreach($series in $results.results.series) {

        $ResultSeries = @{
            Fields = @()
        }

        foreach($tag in $series.tags.PSObject.Properties) {
            $ResultSeries[$tag.Name] = $Tag.Value
        }

        $Columns = $series.columns
        foreach($value in $series.values) {
            $Result = @{}
            for($i = 0; $i -lt $Columns.Length; $i++) {

                if ($Columns[$i] -eq 'time') {
                    $result.time = [DateTime]$value[$i]
                } else {
                    $Result[$columns[$i]] = $value[$i]
                }

                
            }

            $ResultSeries.fields += $result
        }

        $ResultSeries
    }
}
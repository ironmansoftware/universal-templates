$InfluxUrl =  "http://localhost:8086/write?db=performance_data"
$TimeStamp = [DateTimeOffset]::Now.ToUnixTimeMilliseconds() * 1000000

Get-Process | ForEach-Object {

    $Cpu = $_.CPU
    if ($Cpu -eq $null) {
        $CPU = 0
    }

    Invoke-RestMethod -Method POST -Uri $InfluxUrl -Body "process,host=$ENV:COMPUTERNAME,process=$($_.Name.Replace(' ', "\ ")) workingset=$($_.WorkingSet),cpu=$CPU,handle_count=$($_.HandleCount),thread_count=$($_.threats.count) $TimeStamp"
}

$PerformanceStats = @(
    '\Processor(_Total)\% Processor Time'
    '\memory\% committed bytes in use'
    '\physicaldisk(_total)\% disk time'
)

foreach($PerformanceStat in $PerformanceStats) {
    $Value = 0
    (Get-Counter $PerformanceStat).CounterSamples | ForEach-Object {
        $Value += $_.CookedValue
    }

    Invoke-RestMethod -Method POST -Uri $InfluxUrl -Body "counter,host=$ENV:COMPUTERNAME,counter=$($PerformanceStat.Replace(' ', '\ ')) value=$value $TimeStamp"
}

foreach($PerformanceStat in $Cache:NetworkStats) {
    $Value = 0
    (Get-Counter $PerformanceStat).CounterSamples | ForEach-Object {
        $Value += $_.CookedValue
    }

    Invoke-RestMethod -Method POST -Uri $InfluxUrl -Body "network,host=$ENV:COMPUTERNAME,counter=$($PerformanceStat.Replace(' ', '\ ')) value=$value $TimeStamp"
}

Get-CimInstance -ClassName Win32_LogicalDisk | ForEach-Object {
    $FreeSpace = $_.FreeSpace
    $UsedSpace = $_.Size - $_.FreeSpace

    Invoke-RestMethod -Method POST -Uri $InfluxUrl -Body "disk,host=$ENV:COMPUTERNAME,device_id=$($_.DeviceID) free_space=$FreeSpace,used_space=$UsedSpace $TimeStamp"
} 
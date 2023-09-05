#Check if all servers have South America Standard Time (BRT) enabled 
Param ( 
$computers = (Get-Content  "C:\temp\servers.txt") 
) 

$DayLigh = Get-DayLightSavingTime

Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computers | Select-Object @{Name="Hostname";Expression={$_.CSName}},
@{Name="Operational System";Expression={$_.Caption}},
@{Name="DateTime";Expression={$_.ConvertToDateTime($_.LocalDateTime)}},
@{Name="EndDate";Expression={Get-DayLightSavingTime | Select-Object {$DayLigh.EndDate}}}



tzutil /s "E. South America Standard Time_dstoff"
tzutil /s "E. South America Standard Time"

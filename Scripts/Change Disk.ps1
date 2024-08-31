$DiskApp = (Get-CimInstance -ClassName Win32_Volume) | where {$_.Label -eq "APP"}
$DiskApp | Set-CimInstance -Property @{DriveLetter ='E:'}



$appLabel = "APP"
$driveLetter = "E:"

$diskApp = (Get-CimInstance -ClassName Win32_Volume) | where {$_.Label -eq $appLabel}
Write-Host $diskApp.driveLetter

If ($diskApp.DriveLetter -eq $driveLetter)
    {
        Write-Host "Disco com a label $appLabel na unidade $driveLetter"
    }
    Else
    {
        $diskApp | Set-CimInstance -Property @{DriveLetter = $driveLetter}
    }
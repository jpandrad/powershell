$networkMask = (netsh interface ipv4 show address | findstr "Subnet Prefix" | Select-String -Pattern "mask ([0-9\.]+)" | Select-Object -First 1).Matches.Groups[1].Value

$secondaryIP = "192.168.10.191"
$tirdIP = "192.168.10.192"
$fourthIP = ""
$fifthIP = ""

$IPs = @($secondaryIP, $tirdIP, $fourthIP, $fifthIP) | Where-Object { $_ -and $_.Trim() -ne "" }

# Loop para percorrer os IPs
foreach ($ip in $IPs) {
    if ([string]::IsNullOrWhiteSpace($ip)) {
        continue  # Pula se estiver vazio ou nulo
    }
    netsh int ipv4 add address "LAN" $ip $networkMask skipassource=true
}
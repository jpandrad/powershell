$srvIPAddress = Get-NetIPAddress -AddressFamily IPv4 | Where {$_.IPAddress -ne "127.0.0.1"}
$hostName = get-content env:computername
$nsLookup = Resolve-DnsName -Name $hostName -Server 8.8.8.8 | Where {$_.Type -eq "A"}

if ($nsLookup.IPAddress -ne $srvIPAddress.IPAddress) {
    Write-Host "Entrada tipo A no DNS nao corresponde ao IP do servidor"
}
else {
    Write-Host "Entrada tipo A no DNS corresponde ao IP do servidor"
}
##########################
### Change IP Address  ###
##########################
# Description : Script to change Network IP Address using PowerShell
# Created by: Joao Paulo de Andrade
# Tested on Operational Systems:
#   - Windows Server 2022
#   - Windows Server 2012
try {
    # Network Configuration
    $ipAddress = "192.168.10.236"       # IP Address
    $subnetMask = "24"                  # Subnet mask, just use prefix lenght (32,24,16 or etc).
    $gateway = "192.168.10.1"           # Default gateway
    $primaryDNS = "192.168.10.1"        # Primary DNS Server
    $secondaryDNS = "8.8.8.8"           # Secondary DNS Server

    # Get the network interface alias (e.g., Ethernet)
    $interfaceAlias = (Get-NetAdapter).InterfaceAlias

    # Set the IP address
    New-NetIPAddress -InterfaceAlias $interfaceAlias -IPAddress $ipAddress -PrefixLength $subnetMask -DefaultGateway $gateway

    # Set the DNS server addresses
    Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias -ServerAddresses ($primaryDNS, $secondaryDNS)

    Write-Host "IP Address and DNS settings have been updated."
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}
#######################
### Set IP Address  ###
#######################
# Description : Script to set IP Address based on DHCP IP Assigned on server
# Created by: Joao Paulo de Andrade
try {
    $interfaceAlias = Get-NetIPConfiguration
    foreach ($interface in $interfaceAlias) {
        $intAlias = $($interface.InterfaceAlias)                # Interface Alias
        $ipAddress = $($interface.IPv4Address.IPAddress)        # IP Address
        $subnetMask = $($interface.IPv4Address.PrefixLength)    # Subnet mask, just use prefix lenght (32,24,16 or etc).
        $gateway = $($interface.IPv4DefaultGateway.NextHop)     # Default gateway
        $dnsServers = $($interface.DNSServer.ServerAddresses)   # Primary DNS Server

        # Disable DHCP
        Set-NetIPInterface -InterfaceAlias $intAlias -Dhcp Disabled

        # Remove IPs
        Get-NetIPAddress -InterfaceAlias $intAlias -AddressFamily IPv4 | Remove-NetIPAddress -Confirm:$false

        # Configure IP address
        New-NetIPAddress -InterfaceAlias $intAlias -IPAddress $ipAddress -PrefixLength $subnetMask -DefaultGateway $gateway

        # Configure DNS Servers
        Set-DnsClientServerAddress -InterfaceAlias $intAlias -ServerAddresses $dnsServers
    }

    # Disable NetBios over TCP/IP
    Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip* -Name NetbiosOptions -Value 2
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}
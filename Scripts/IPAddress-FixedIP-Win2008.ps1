#######################
### Set IP Address  ###
#######################
# Description : Script to set IP Address based on DHCP IP Assigned on Windows 2008 Server or high
# Created by: Joao Paulo de Andrade
try {
    # Get the active interface (assuming it's enabled)
    $activeAdapters = Get-WmiObject Win32_NetworkAdapter -Filter "NetConnectionStatus = 2"
    foreach ($adapter in $activeAdapters) {
        $adapter = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter "Index = $($adapter.DeviceId)"

        # Extract values into interface
        $ip = $adapter.IPAddress[0]           # First IP address (in case of multiple)
        $subnet = $adapter.IPSubnet[0]        # Subnet mask
        $gateway = $adapter.DefaultIPGateway  # Gateway

        # Update Interface and Fixed the IP Address
        $adapter.EnableStatic($ip, $subnet)
        $adapter.SetGateways($gateway)

        # Update Fixed DNS Servers
        $adapter.SetDNSServerSearchOrder($($adapter.DNSServerSearchOrder -join ', '))
    }
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}
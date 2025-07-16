########################################
### Change IP Address - IIS Biding   ###
########################################
# Description : Script to Update Binding IP Address in IIS. This script use automatically uses host-based address. 
# Created by: Joao Paulo de Andrade
if ((Get-WindowsFeature Web-Server).InstallState -eq "Installed") {
    try {
        # Count how many IP Adress exist in the server
        $IPsNumbers = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notmatch '127\.0\.0\.[0-9]'} | Select-Object -ExpandProperty IPAddress).Count
        if ($IPsNumbers -eq 1) {
            # If just one exist, use this on the binding object
            # Realize a foreach on IIS bindings and update the IP Address (Except bindings using wildcard configuration)
            $newIPBinding = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.SkipAsSource -eq $false } | Where-Object {$_.IPAddress -notmatch '127\.0\.0\.[0-9]'} | Select-Object -ExpandProperty IPAddress
            foreach ($website in Get-Website) {
                $bindings = Get-WebBinding -Name $website.name
                foreach ($binding in $website.bindings.Collection) {
                    # Split fields datas to use in Set-WebBinding
                    $bindingInfo = $binding.bindingInformation
                    $parts = $bindingInfo -split ':'
                    $IISPort = $parts[1]
                    $IISHostname = $parts[2]
                    # Update Binding using the new IP Address
                    if ($binding -notmatch 'https?\s*\*:?(80|443):') {
                        Set-WebBinding -Name $website.name -BindingInformation $bindingInfo -PropertyName "IPAddress" -Value $newIPBinding
                    }
                }
            }
        } else {
                $ipList = @(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.SkipAsSource -eq $true } | Where-Object {$_.IPAddress -notmatch '127\.0\.0\.[0-9]'} | Select-Object -ExpandProperty IPAddress)
                $bindingIndex = 0
                foreach ($website in Get-Website) { 
                    $bindings = Get-WebBinding -Name $website.name
                    foreach ($binding in $website.bindings.Collection) {
                        # Split fields datas to use in Set-WebBinding
                        $bindingInfo = $binding.bindingInformation
                        $parts = $bindingInfo -split ':'
                        $IISPort = $parts[1]
                        $IISHostname = $parts[2]
                        # Update Binding using the new IP Address
                        if ($binding -notmatch 'https?\s*\*:?(80|443):') {
                            if ($bindingIndex -lt $ipList.Count) {
                                $newIP = $ipList[$bindingIndex]
                                Set-WebBinding -Name $website.name -BindingInformation $bindingInfo -PropertyName "IPAddress" -Value $newIP
                                $bindingIndex++
                            } else {
                                # If don't have others IPs, use the last IP in the list.
                                Set-WebBinding -Name $website.name -BindingInformation $bindingInfo -PropertyName "IPAddress" -Value $ipList[-1]
                            }
                        }
                    }
                }
            }
    } catch {
        Write-Error "An error occurred: $($_.Exception.Message)"
    }
} else {
    Write-Host "IIS is not installed"
    exit 0
}

### Commands for Network Interface
# Get Primary IP
#     > Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.SkipAsSource -eq $false } | Select-Object IPAddress, InterfaceAlias

# Get Secondary IP
#     > Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.SkipAsSource -eq $true } | Select-Object IPAddress, InterfaceAlias

# Ignore Loopback interface
#     > Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notmatch '127\.0\.0\.[0-9]'}

# CREATE A NEW IP Secondary
#     > netsh int ipv4 add address "Ethernet0" 192.168.10.193 255.255.255.0 skipassource=true





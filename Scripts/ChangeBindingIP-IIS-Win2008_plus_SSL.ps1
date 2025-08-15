########################################
### Change IP Address - IIS Biding   ###
########################################
# Description : Script to Update Binding IP Address in IIS. This script use automatically uses host-based address. 
# Created by: Joao Paulo de Andrade

# Create a Function
function Interfaces_IPV4 {
    $Interface = netsh interface ipv4 show ipaddresses level=verbose

    # Create an array to storage information
    $results = @()

    # Variables to set IP and status
    $currentIP = $null
    $currentSkipStatus = $null

    foreach ($line in $Interface) {
        # Exclude loopback interface
        if ($line -notmatch '127\.0\.0\.\d+' -and $line -match '^Address\s+(\d{1,3}(?:\.\d{1,3}){3})') {
            # Update IP Address
            if ($currentIP -and $currentSkipStatus) {
                $results += [PSCustomObject]@{
                    IPAddress = $currentIP
                    SkipAsSource = $currentSkipStatus
                }
            }
            $currentIP = $matches[1]
            $currentSkipStatus = $null
        }
        
        # Check the "Skip as Source" configuration
        elseif ($line -match '^Skip as Source\s+:\s+(true|false)') {
            $currentSkipStatus = $matches[1]
        }
    }

    # Update variables with IP Address and Skip as Source value
    if ($currentIP -and $currentSkipStatus) {
        $results += [PSCustomObject]@{
            IPAddress = $currentIP
            SkipAsSource = $currentSkipStatus
        }
    }
    return $results
}

# Check if IIS as been installed on server
if ((Get-WindowsFeature Web-Server).Installed -eq "Installed") {
    try {
        # Count how many IP Adress exist in the server
        $IPsNumbers = (Interfaces_IPV4 | Select-Object -ExpandProperty IPAddress).Count
        if ($IPsNumbers -eq 1) {
            # If just one exist, use this on the binding object
            # Realize a foreach on IIS bindings and update the IP Address (Except bindings using wildcard configuration)
            $newIPBinding = Interfaces_IPV4 | Where-Object { $_.SkipAsSource -eq $false } | Select-Object -ExpandProperty IPAddress
            foreach ($website in Get-Website) {
                $bindings = Get-WebBinding -Name $website.name
                foreach ($binding in $website.bindings.Collection) {
                    # Split fields datas to use in Set-WebBinding
                    $bindingInfo = $binding.bindingInformation
                    $parts = $bindingInfo.Split(':')
                    $IISPort = $parts[1]
                    $IISHostname = $parts[2]
                    # Update Binding using the new IP Address
                    if ($binding -notmatch 'https?\s*\*:?\d+:') {
                        # Get Certificate Thumbprint
                        $certThumbprint = Get-ChildItem IIS:\SSLbindings | where{($_.sites -eq $website.name) -and ($_.Port -eq $IISPort)} | select -ExpandProperty Thumbprint
                        
                        # Update Web Site using the new IPAddress
                        Set-WebBinding -Name $website.name -BindingInformation $bindingInfo -PropertyName "IPAddress" -Value $newIPBinding

                        # Validate SSL Certificate
                        if ($IISPort -eq "443") {
                            # Validate if there is still Thumbprint in the link, otherwise update using the old Certificate Thumbprint
                            $ValidateThumbprint = Get-ChildItem IIS:\SSLbindings | where{($_.sites -eq $website.name) -and ($_.Port -eq $IISPort)} | select -ExpandProperty Thumbprint
                            if ($ValidateThumbprint -eq $null) {
                                Write-Host "Adding certification to the site ${IISHostname}..."
                                Get-Item "Cert:\LocalMachine\My\$certThumbprint" | New-Item -Path "IIS:\SslBindings\${newIPBinding}!443!${IISHostname}"
                                Write-Host "The certificate will be added to the site ${IISHostname}."
                            } else {
                                Write-Host "Certificate is already configured on the website ${IISHostname}."
                            }
                        }
                    }
                }
            }
        } else {
                $ipList = @(Interfaces_IPV4 | Where-Object { $_.SkipAsSource -eq $true } | Select-Object -ExpandProperty IPAddress)
                $bindingIndex = 0
                $hostnameToIP = @{}  # Hashtable for mapper hostname -> IP
                
                # Update WebSite
                foreach ($website in Get-Website) { 
                    $bindings = Get-WebBinding -Name $website.name
                    foreach ($binding in $website.bindings.Collection) {
                        # Split fields datas to use in Set-WebBinding
                        $bindingInfo = $binding.bindingInformation
                        $parts = $bindingInfo.Split(':')
                        $IISPort = $parts[1]
                        $IISHostname = $parts[2]
                        
                        # Update Binding using the new IP Address
                        if ($binding -notmatch 'https?\s*\*:?\d+:') {
                            # Get Certificate Thumbprint
                            $certThumbprint = Get-ChildItem IIS:\SSLbindings | where{($_.sites -eq $website.name) -and ($_.Port -eq $IISPort)} | select -ExpandProperty Thumbprint

                            # Checks if we already have an IP assigned to this hostname
                            if (-not $hostnameToIP.ContainsKey($IISHostname)) {
                                # Se não temos IP para este hostname, atribui um novo
                                if ($bindingIndex -lt $ipList.Count) {
                                    $hostnameToIP[$IISHostname] = $ipList[$bindingIndex]
                                    $bindingIndex++
                                } else {
                                    # If there are no more IPs, use the last IP in the list
                                    $hostnameToIP[$IISHostname] = $ipList[-1]
                                }
                            }
                        
                            # Uses the IP already assigned to this hostname
                            $newIP = $hostnameToIP[$IISHostname]
                            Set-WebBinding -Name $website.name -BindingInformation $bindingInfo -PropertyName "IPAddress" -Value $newIP

                            # Certificate validation and update for HTTPS on port 443
                            if ($IISPort -eq "443" -and $certThumbprint) {
                                try {
                                    # Get Certificate Thumbprint
                                    $certificate = Get-Item "Cert:\LocalMachine\My\$certThumbprint" -ErrorAction Stop
                                    Write-Host "Certificate found in $IISHostname : $($certificate.Subject)"
                                    
                                    # Remove SSL Binding if exist
                                    $existingSSLBinding = Get-ChildItem IIS:\SslBindings | Where-Object { $_.IPAddress -eq $newIP -and $_.Port -eq 443 }
                                    if ($existingSSLBinding) {
                                        Remove-Item "IIS:\SslBindings\$newIP!443" -Force
                                        Write-Host "SSL binding updated to $newIP :443"
                                    }
                                    
                                    # Validate if there is still Thumbprint in the link, otherwise update using the old Certificate Thumbprint
                                    New-Item -Path "IIS:\SslBindings\$newIP!443" -Value $certificate -Force
                                    Write-Host "Update binding to $newIP :443 with certificate $certThumbprint"
                                    
                                } catch {
                                    Write-Warning "An error occurred to update SSL $IISHostname : $($_.Exception.Message)"
                                }
                            }
                        } 
                    }
                }
            }
    } catch {
        Write-Error "An error occurred: $($_.Exception.Message)"
    }
} else {
    Write-Host "IIS is not installed!"
}
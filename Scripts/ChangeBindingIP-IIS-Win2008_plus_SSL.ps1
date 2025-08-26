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
        # Import WebAdministration Module
        Import-Module WebAdministration

        # Backup path and file
        $backupDir = "C:\temp\IIS-Backup_Config"
        if (!(Test-Path $backupDir)) {
            New-Item -Path $backupDir -ItemType Directory | Out-Null
        }
        $txtFile = Join-Path $backupDir "bindings-backup.txt"

        # Get Bindings information and write in file
        Get-ChildItem IIS:\Sites | ForEach-Object {
            $siteName = $_.Name
            Add-Content $txtFile "===== Site: $siteName ====="
            $_.Bindings.Collection | ForEach-Object {
                $line = "Protocol: {0} | Binding: {1}" -f $_.protocol, $_.bindingInformation
                if ($_.certificateHash) {
                    $line += " | CertHash: $($_.certificateHash) | Store: $($_.certificateStoreName)"
                }
                Add-Content $txtFile $line
            }
            Add-Content $txtFile "`n"
        }
        Write-Host "Backup finished! Salved in: $txtFile"

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
                    $protocol = $binding.Protocol
                    $bindingInfo = $binding.bindingInformation
                    $parts = $bindingInfo.Split(':')
                    $IISPort = $parts[1]
                    $IISHostname = $parts[2]

                    # Update Binding using the new IP Address
                    if ($binding -notmatch 'https?\s*\*:?\d+:') {

                        # Update Protocol HTTP
                        if ($protocol -ne "https" -and $IISPort -ne 443) {
                            Write-Host "Updating IP Address, site $IISHostname, this is not a HTTPS site..."
                            Set-WebBinding -Name $website.name -BindingInformation $bindingInfo -PropertyName "IPAddress" -Value $newIPBinding
                            Write-Host "Updated IP Address $IISHostname."
                        }

                        # Update Binding HTTPS Protocol with SSL
                        if ($protocol -eq "https" -and $IISPort -eq 443) {
                            Write-Host "Binding $bindingInfo is a $protocol protocol and is running on the port $IISPort. Updating site certification..."

                            # Get Certificate Thumbprint
                            $certThumbprint = Get-ChildItem IIS:\SSLbindings | where{($_.sites -eq $website.name) -and ($_.Port -eq $IISPort)} | select -ExpandProperty Thumbprint
                            Write-Host "Certificate Thumbprin: $certThumbprint"

                            if ($IISHostname) {
                                Write-Host "Removing Binding $website.name with $IISHostname..."

                                # Update IP Address
                                Set-WebBinding -Name $website.name -BindingInformation $bindingInfo -PropertyName "IPAddress" -Value $newIPBinding

                                # Validate SSL Certificate
                                $ValidateThumbprint = Get-ChildItem IIS:\SSLbindings | where{($_.sites -eq $website.name) -and ($_.Port -eq $IISPort)} | select -ExpandProperty Thumbprint
                                if ($ValidateThumbprint -eq $null) {
                                    Write-Host "Adding certification to the site $IISHostname..."
                                    Get-Item "Cert:\LocalMachine\My\$certThumbprint" | New-Item -Path "IIS:\SslBindings\$newIPBinding!443!$IISHostname"
                                    Write-Host "The certificate will be added to the site $IISHostname."
                                } else {
                                    Write-Host "Certificate is already configured on the website $IISHostname."
                                }
                            } else {
                                Write-Host "Removing Binding $website.name..."
                                # Remove HTTPS Binding
                                Remove-WebBinding -Name $website.name -Protocol https -Port "443"

                                # Create Binding HTTP
                                Write-Host "Creating Binding $website.name..."
                                New-WebBinding -Name $website.name -IPAddress $newIPBinding -Port 443 -Protocol "https"

                                # Set SSL Certificate
                                Write-Host "Adding certification to the site $IISHostname..."
                                (Get-WebBinding -Name $website.name -Port 443 -Protocol "https").AddSslCertificate("$certThumbprint", "my")
                                Write-Host "The certificate will be added to the site $IISHostname."

                                # Clean certThumbprint variable
                                $certThumbprint = $null
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
$ipMapping = @{
    "127.0.0.1" = "192.168.10.11"
    "127.0.0.2" = "192.168.10.12"
    "127.0.0.3" = "192.168.10.13"
    "127.0.0.4" = "192.168.10.14"
}

### EXAMPLE FOR USE
foreach ($item in $ipMapping.GetEnumerator()) {
    Write-Host "$($item.Key):$($item.Value)"
}



### EXAMPLE
$ipMapping = @{
    "127.0.0.1" = "192.168.10.11"
    "127.0.0.2" = "192.168.10.12"
    "127.0.0.3" = "192.168.10.13"
    "127.0.0.4" = "192.168.10.14"
}

foreach ($website in Get-Website) {
    $bindings = Get-WebBinding -Name $website.name
    foreach ($binding in $website.bindings.Collection) {
        # Split fields datas to use in Set-WebBinding
        $bindingInfo = $binding.bindingInformation
        $parts = $bindingInfo.Split(':')
        $protocol = $binding.Protocol
        $IISPort = $parts[1]
        $IISHostname = $parts[2]

        if ($binding -notmatch 'https?\s*\*:?\d+:') {
            # Update Binding with HTTP protocol
            if ($protocol -ne "https" -and $IISPort -ne 443) {
                foreach ($item in $ipMapping.GetEnumerator()) {
                    $ipMappingBinding = "$($item.Key):$($IISPort):$($IISHostname)"     # IP Mapping - Binding
                    $newIPBinding = "$($item.Value)"                                   # IP Mapping - New IP
                    if ($ipMappingBinding -eq $bindingInfo) {
                        Write-Host "IIS Binding $bindingInfo will be modify to use a new ip Address..."
                        Set-WebBinding -Name $website.name -BindingInformation $ipMappingBinding -PropertyName 'IPAddress' -Value $newIPBinding -WarningAction SilentlyContinue
                        Write-Host "Binding $bindingInfo has been modified to use new ip address: $newIPBinding."
                    } else {
                        Write-Host "IP $newIPBinding not found in the Bindings. No changes have been made"
                    }
                }
            }
        }

        # Update Binding HTTPS with SSL
        if ($protocol -eq "https" -and $IISPort -eq 443) {
            Write-Host "Binding $bindingInfo is a $protocol protocol and is running on the port $IISPort. Updating site certification..."

            # Get Certificate Thumbprint
            $certThumbprint = Get-ChildItem IIS:\SSLbindings | where{($_.sites -eq $website.name) -and ($_.Port -eq $IISPort)} | select -ExpandProperty Thumbprint
            Write-Host "Certificate Thumbprin: $certThumbprint"

            foreach ($item in $ipMapping.GetEnumerator()) {
                $ipMappingBinding = "$($item.Key):$($IISPort):$($IISHostname)"     # IP Mapping - Binding
                $newIPBinding = "$($item.Value)"                                   # IP Mapping - New IP
                if ($ipMappingBinding -eq $bindingInfo) {
                    if ($IISHostname) {
                        Write-Host "Removing Binding $website.name with $IISHostname..."

                        # Update IP Address
                        Write-Host "IIS Binding $bindingInfo will be modify to use a new ip Address..."
                        Set-WebBinding -Name $website.name -BindingInformation $ipMappingBinding -PropertyName 'IPAddress' -Value $newIPBinding -WarningAction SilentlyContinue
                        Write-Host "Binding $bindingInfo has been modified to use new ip address: $newIPBinding."

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

                        # Create Binding HTTPS
                        Write-Host "Creating Binding $website.name..."
                        New-WebBinding -Name $website.name -IPAddress $newIPBinding -Port 443 -Protocol "https"

                        # Set SSL Certificate
                        Write-Host "Adding certification to the site $IISHostname..."
                        (Get-WebBinding -Name $website.name -Port 443 -Protocol "https").AddSslCertificate("$certThumbprint", "my")
                        Write-Host "The certificate has been added to the site $IISHostname."

                        # Clean certThumbprint variable
                        $certThumbprint = $null
                    }
                }
            }
        } 
    }
}
# Variables: Path and base Registry Name
$basePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Network"
$regName = "LAN"

# Recursive Function for search Register "Name" with regName value.
function Search-RegName {
    param (
        [string]$Path
    )
    # Try get sub keys
    try {
        $subKeys = Get-ChildItem -Path $Path -ErrorAction Stop
    } catch {
        return
    }
    foreach ($key in $subKeys) {
        try {
            $item = Get-ItemProperty -Path $key.PSPath -ErrorAction Stop
            if ($item.PSObject.Properties.Name -contains "Name") {
                $nameValue = $item.Name
                if ($nameValue -match "$regName") {
                    Write-Host "Register $regName found in: $($key.PSPath)"
                    # Uncomment the line bellow to remove the key
                    # Remove-Item -Path $key.PSPath -Recurse -Force
                }
            }
        } catch {
            continue
        }
        # Recursive call in the subkeys
        Search-RegName  -Path $key.PSPath
    }
}
# Execute the Function
Search-RegName  -Path $basePath

# Rename Interface
$interfaceName = "Ethernet"
Rename-NetAdapter -Name "$interfaceName" -NewName "$regName"

# Disable NetBios over TCP/IP
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip* -Name NetbiosOptions -Value 2
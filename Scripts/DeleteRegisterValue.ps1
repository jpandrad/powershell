# Variables: Path and base Registry Name
$basePathCC = "HKLM:\SYSTEM\CurrentControlSet\Control\Network"
$basePathCS = "HKLM:\SYSTEM\ControlSet001\Control\Network\"
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
                    #Remove-Item -Path $key.PSPath -Recurse -Force
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
Search-RegName  -Path $basePathCC
Search-RegName  -Path $basePathCS

#Rename OLD Interface LAN if exist
$oldInterface = Get-NetAdapter | where {$_.Name -like "$regName"}
if ($oldInterface -ne $null) {
  Rename-NetAdapter -Name "$regName" -NewName "OldInterface"
}

# Rename the new Interface to LAN
$newInterface = Get-NetAdapter | Where-Object { $_.Name -like "Ethernet*" }
if ($newInterface) {
    Rename-NetAdapter -Name $newInterface.Name -NewName "LAN" -Confirm:$false
    Write-Host "Interface Adapter '$($newInterface.Name)' renamed to 'LAN'."
} else {
    Write-Host "No Interface found with name starting with 'Ethernet'."
}

# Disable NetBios over TCP/IP
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip* -Name NetbiosOptions -Value 2
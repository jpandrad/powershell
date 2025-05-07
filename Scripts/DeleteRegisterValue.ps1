# Define the base registry path
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Network"
$registryValue = "LOCAL"

# Function to recursively search and delete the registry value
function Remove-RegistryValue {
    param (
        [string]$Path
    )

    # Check if the current path exists
    if (Test-Path -Path $Path) {
        # Get all subkeys under the current path
        $subkeys = Get-ChildItem -Path $Path

        # Iterate through each subkey
        foreach ($subkey in $subkeys) {
            # Recursively call the function for each subkey
            Remove-RegistryValue -Path $subkey.PSPath

            # Check if the "LAN" value exists in the current subkey
            if (Get-ItemProperty -Path $subkey.PSPath -Name $registryValue -ErrorAction SilentlyContinue) {
                # Remove the "LAN" value
                Remove-ItemProperty -Path $subkey.PSPath -Name $registryValue -Force
                Write-Host "Removed $registryValue value from: $($subkey.PSPath)"
            }
        }
    }
}

# Call the function with the base registry path
Remove-RegistryValue -Path $registryPath
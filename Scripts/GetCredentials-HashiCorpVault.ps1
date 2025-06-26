#######################################################
### Start Process using RunAs with Vault Credential ###
#######################################################
# Description : Simple Powershell script to get User and Pass in a Vaul and Start Process using RunAs
# Created by: Joao Paulo de Andrade
$headers = @{
    'X-Vault-Token' = 'myroot'
}
$uri = "http://192.168.10.236:8200/v1/secret/data/domainuser"
$response = Invoke-RestMethod -Method Get -Headers $headers -Uri $uri

# Extract specific fields
$Username = $response.data.data.user
$Password = $response.data.data.pass

# Convert password to SecureString
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force

# Create PSCredential object
$credential = New-Object System.Management.Automation.PSCredential ($Username, $securePassword)

# Start a process (e.g., PowerShell) with elevated privileges
Start-Process "C:\Windows\system32\notepad.exe" -Credential $credential -PassThru -WindowStyle Normal
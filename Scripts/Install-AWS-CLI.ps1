try {
    # Caminho para salvar o instalador
    $installerPath = "$env:TEMP\AWSCLIV2.msi"

    $downloadUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"

    Write-Host "Downloading AWS CLI v2..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

    Write-Host "Installing AWS CLI v2..."
    Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /qn" -Wait

    Write-Host "AWS CLI installed successfully!"
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}

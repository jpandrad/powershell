$localGroup = Get-LocalGroupMember -Group "Administrators" | where {$_.Name -like "*joao*"}
if ($localGroup -ne $null) {
    Write-Host "Membro ja usuario do grupo"
}
else {
    Write-Host "Membro nao encontrado..."
    Write-Host "Inserindo no grupo..."
}
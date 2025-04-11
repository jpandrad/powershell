$json = @'
{
    "RestoreMetadata": {
        "NetworkInterfaces": "[{\"AssociatePublicAddress\":\"True\",\"PrivateIpAddress\":\"127.0.0.1\"}]"
    }
}
'@
$data = $json | ConvertFrom-Json
$networkInterfaces = $data.RestoreMetadata.NetworkInterfaces | ConvertFrom-Json
$privateIp = $networkInterfaces.PrivateIpAddress
$privateIp | ConvertTo-Json
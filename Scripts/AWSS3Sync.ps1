$S3Bucket = "s3://my-bucket/path"
$localPath = "/local/path/"

$hostName = get-content env:computername
$Data = (Get-Date (Get-Date).addDays(-2) -UFormat "%Y-%m-%d")
aws s3 sync $S3Bucket $localPath --query 'Contents[LastModifiedd=$Data][].key'
aws s3 sync $localPath $S3Bucket --query 'Contents[LastModifiedd=$Data][].key'
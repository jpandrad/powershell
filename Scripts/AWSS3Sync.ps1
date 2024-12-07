$S3Bucket = "s3://my-bucket/path/"
$localPath = "/local/path/"

$hostName = get-content env:computername

aws s3 sync $S3Bucket$hostName $localPath
aws s3 sync $localPath $S3Bucket$hostName

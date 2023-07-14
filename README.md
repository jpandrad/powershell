(Get-AdUser -Filter * | Where {$_.Enabled -eq "True"}).Count

(Get-AdUser -Filter * -SearchBase "OU=Finance,OU=UserAccounts,DC=CONTOSO,DC=COM" | Where {$_.Enabled -eq "True"}).Count



(Get-ADUser -Filter * -Properties LastLogonDate | Where-Object {($_.Enabled -eq "True") -and ($_.LastLogonDate -gt (Get-Date).AddDays(-120))}).Count


(Get-ADUser -Filter * -Properties LastLogonDate | Where-Object {$_.LastLogonDate -gt (Get-Date).AddDays(-180)}).Count

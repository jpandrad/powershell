```powershell
(Get-AdUser -Filter * | Where {$_.Enabled -eq "True"}).Count
```
```powershell
(Get-AdUser -Filter * -SearchBase "OU=Finance,OU=UserAccounts,DC=CONTOSO,DC=COM" | Where {$_.Enabled -eq "True"}).Count
```
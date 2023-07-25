```PowerShell
(Get-AdUser -Filter * | Where {$_.Enabled -eq "True"}).Count`
```

```PowerShell
(Get-AdUser -Filter * -SearchBase "OU=Finance,OU=UserAccounts,DC=CONTOSO,DC=COM" | Where {$_.Enabled -eq "True"}).Count
```


-------
```PowerShell
(Get-ADUser -Filter * -Properties LastLogonDate | Where {$_.Enabled -eq "True"} | Where-Object {$_.LastLogonDate -gt (Get-Date).AddDays(-120)}).Count
```
```PowerShell
(Get-ADUser -Filter * -Properties LastLogonDate | Where-Object {$_.LastLogonDate -gt (Get-Date).AddDays(-180)}).Count
```
```PowerShell
(Get-ADUser -Filter * -Properties LastLogonDate | Where-Object {($_.Enabled -eq "True") -and ($_.LastLogonDate -gt (Get-Date).AddDays(-120))}).Count
```

-------
```PowerShell
(Get-ADUser  -Properties * -LDAPFilter '(!userAccountControl:1.2.840.113556.1.4.803:=2)') |  Format-Table Name, GivenName, Surname, LastLogonDate  -A | Out-File -FilePath C:\temp\user.txt
```

Export AD Users
```PowerShell
Get-ADUser  -Properties * -LDAPFilter '(!userAccountControl:1.2.840.113556.1.4.803:=2)' | Select-Object Name, Mail, GivenName, Surname, LastLogonDate | Export-Csv -Path "C:\temp\Users.csv" -Delimiter ';' -NoTypeInformation
```

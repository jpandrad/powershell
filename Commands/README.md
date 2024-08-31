# POWERSHELL COMMANDS/SCRIPTS
Compilation of some commands or scripts in PoWerShell that I use or haved used at some point.

## Commands to Get Informations in Active Directory
Export Domain Controller Enabled Users:
```PowerShell
Get-ADUser  -Properties * -LDAPFilter '(!userAccountControl:1.2.840.113556.1.4.803:=2)' | Select-Object Name, Mail, GivenName, Surname, LastLogonDate | Export-Csv -Path "C:\temp\Users.csv" -Delimiter ';' -NoTypeInformation
```
OR:
```PowerShell
(Get-ADUser  -Properties * -LDAPFilter '(!userAccountControl:1.2.840.113556.1.4.803:=2)') |  Format-Table Name, GivenName, Surname, LastLogonDate  -A | Out-File -FilePath C:\temp\user.txt
```

Export Computer Object from Domain Controller:
```PowerShell
Get-ADComputer -filter * -Properties * | Select Name, OperatingSystem | Export-Csv -Path "C:\temp\Computers.csv" -Delimiter ';' -NoTypeInformation
```


Get Enabled Users Using `SearchBase` OU:
```PowerShell
(Get-AdUser -Filter * -SearchBase "OU=Finance,OU=UserAccounts,DC=CONTOSO,DC=COM" | Where {$_.Enabled -eq "True"}).Count
```


Number of Enabled Users:
```PowerShell
(Get-AdUser -Filter * | Where {$_.Enabled -eq "True"}).Count
```
Number of Enabled Users -120 days:
```PowerShell
(Get-ADUser -Filter * -Properties LastLogonDate | Where {$_.Enabled -eq "True"} | Where-Object {$_.LastLogonDate -gt (Get-Date).AddDays(-120)}).Count
```
OR:
```PowerShell
(Get-ADUser -Filter * -Properties LastLogonDate | Where-Object {($_.Enabled -eq "True") -and ($_.LastLogonDate -gt (Get-Date).AddDays(-120))}).Count
```
Number of Enabled Users -180 days:
```PowerShell
(Get-ADUser -Filter * -Properties LastLogonDate | Where-Object {$_.LastLogonDate -gt (Get-Date).AddDays(-180)}).Count
```

$domainControllers = Get-ADDomainController -Filter *
$instanceID = "4740"
$user = "*<USER_NAME>*"

foreach ($dc in $domainControllers) {
    write-output " Searching EventLog ID in DC --->  $dc "
    Get-EventLog -LogName Security -InstanceId $instanceID -ComputerName $dc -Message $user | Export-Csv -Path "C:\temp\EventLog.csv" -Delimiter ';' -NoTypeInformation
}

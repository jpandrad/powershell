# Script created to integrate SolarWinds SNMP Trap with Zenvia API for sending SMS
$callNumber = (Get-Content  "C:\SMS-TRAP\callNumber.txt")
$body = (Get-Content  -tail 1 "C:\SMS-TRAP\Event-TRAP.txt")

    foreach ($callNumbers in $callNumber){
        $MsgSMS = "$body"
        Invoke-WebRequest -Uri "http://system.human.com.br/URL_PATH/msgSms.do?dispatch=send&account=*****&code=**********&to=$callNumbers&msg=$MsgSMS" -Method POST
        }

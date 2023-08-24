# Script for query an Alarm system Database (MSSQL), and check if any alert. If have any alert, send a SMS message using method POST

$callNumber = (Get-Content  "C:\send-sms\callNumber.txt")
$body = invoke-sqlcmd -server <DATABASE_SERVER> -Database <DATABASE_NAME> -Username "<USER_NAME>" -Password "<PASSWORD>" -Query "SELECT TimeStamp, Acked, Area, Severity, Message FROM [dbo].[Alarms] WHERE TimeStamp <  GetDate() AND TimeStamp > dateadd(second, -15, GetDate()) AND Acked LIKE '0' AND Severity LIKE '0'" 

    foreach ($callNumbers in $callNumber){
        foreach ($bodies in $body) {
        $MsgSMS = "EVENT: $($bodies.Message) AREA: $($bodies.Area), DATA: $($bodies.TimeStamp)"
        Invoke-WebRequest -Uri "http://url.com.br/msgSms.do?&to=$callNumbers&msg=$MsgSMS" -Method POST
        }
    }

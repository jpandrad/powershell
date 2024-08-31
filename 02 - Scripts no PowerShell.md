# Variaveis
Variavel e um objeto situado na memoria que representa um valor de expressao.

As variaveis iniciam com um `$` e o Powershell pode pegar informacoes do sistema, por exemplo, o nome do computador:
```powershell
$env:COMPUTERNAME
```

Um exemplo de como entrar com uma variavel e depois imprimir a variavel:
```powershell
$nome = "Joao Paulo"
write-host "Hello $nome"
```

Podemos fazer com que o PowerShell receba as informacoes:
```powershell
$nome = Read-Host "Qual o seu nome?: "
write-host "Hello $nome"
```


## Arrays
Arays e uma matriz que armazena informacoes em um indice.
Um exemplo de codigo com Array.

Vamos criar uma entrada que informa os DNS do Google e verifica quantos servidores DNS temos na lista e faz um teste de ping nos servidores que colocamos na lista:
```powershell
$GoogleDNS = @("8.8.8.8", "8.8.4.4")
$TotalDNS = $GoogleDNS.Count
Write-Host Pingando todos os $TotalDNS DNS do Google
Test-Connection $GoogleDNS -Count 1
sleep 3
Write-Host FIM!
```

# HashTable
A HashTable tambem e uma matriz, ela permite ordenada:
```powershell
$servidores = [ordered] @{Server1="127.0.0.1";Server2="127.0.0.2";Server1="127.0.0.3";}
$servidores

#Adicionar um novo servidor
$servidores["Server4"]="127.0.0.4"

#Remover um servidor
$servidores.Remove("Server4")

#Teste de ping no servidor 01
Test-connection $servidores.Server1

#Imprimir Somente Valores
$servidores.Values
```


## Select-String
O Select-String e a mesma coisa que utilizar o grep no Linux, com ele voce pode buscar textos dentro de um arquivo:
```powershell
Get-Content  .\banco.txt | Select_String ITAU, BRADESCO
```


## Expressoes Regulares (REGEX)
regexlib.com pode ver varias informacoes sobre regex.

`\d` - Numerico [0-9]

`\w` - Alpha numerico [a-z A-Z 0-9]

`\s` - Caractere de espaco em branco

`.` - Qualquer caractere exceto nova linha

`()` - Sub-expression

`\` Proximo Caractere

Um exemplo de leitura para conta de email:
```powershell
$email = Read-Host Qual o seu email?
$regex = "^[a-z]+\.[a-z]+@contoso.com$"

If (email -notmatch $regex) {
    Write-Host "Email invalido $email"
    Exit
    }

Write-Host Acertou!
```

Podemos fazer uma pesquisa de um padrao com regex, no exemplo abaixo estamos buscando um padrao de CPF:
```powershell
Get-Content .\cpf.txt | Select-String -pattern "\d.\d.\d-\d"
```


## IF... ELSE
Abaixo temos um script que verifica se um servico esta em execucao:
```powershell
$Serv = Get-Service -Name Spooler
If ($Serv.Status -eq "Running")
    {
        Write-Host "Servico em execucao"
    }
    Else
    {
        Write-Host "Servico Parado"
    }
```
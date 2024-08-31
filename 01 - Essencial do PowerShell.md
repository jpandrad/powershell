# Iniciando em PowerShell
O PowerShell possui duas formas de ser utilizado, o Windows `PowerShell` que abre o `CLI` e o `PoweShell ISE (Integrated Scripting Environment)` que abre a interface na qual podemos carregar scripts e editar o script.

Para verificar a versao do PoWeshell:
```powershell
PS C:\Users\Joao Paulo> $PSVersionTable
Name                           Value
----                           -----
PSVersion                      5.1.22621.3672
PSEdition                      Desktop
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}
BuildVersion                   10.0.22621.3672
CLRVersion                     4.0.30319.42000
WSManStackVersion              3.0
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
```
OU
```powershell
PS C:\Users\Joao Paulo> $PSVersionTable.PSVersion

Major  Minor  Build  Revision
-----  -----  -----  --------
5      1      22621  3672
```

Podemos fazer uma forma utilizando o `get-host`:
```powershell
PS C:\Users\Joao Paulo> get-host
Name             : ConsoleHost
Version          : 5.1.22621.3672
InstanceId       : 08445f19-8fe4-40af-bcb5-f47647a48a3b
UI               : System.Management.Automation.Internal.Host.InternalHostUserInterface
CurrentCulture   : en-US
CurrentUICulture : en-US
PrivateData      : Microsoft.PowerShell.ConsoleHost+ConsoleColorProxy
DebuggerEnabled  : True
IsRunspacePushed : False
Runspace         : System.Management.Automation.Runspaces.LocalRunspace
```

```powershell
PS C:\Users\Joao Paulo> (get-host).Version
Major  Minor  Build  Revision
-----  -----  -----  --------
5      1      22621  3672
```

A diferenca do `$PSVersionTable.PSVersion` com o `get-host` e que no caso do `$PSVersionTable.PSVersion` estamos consultando no PoweShell que estamos trabalhando, no `get-host` ele executa no computador, possibilitando executar os comandos remotamente.


## Command-Lets
Os comandos padroes do MS-DOS e `Command-Lets`, que sao comandos utilizados como verbo-substantivo:
Exemplo: `Get-Command`.


## Me da um help please?
O Help e atualizavel, para isso abra um powershell como adminitrador e execute o comando:
```powershell
PS C:\Windows\system32> Update-Help
```

Para usar o help, utilize o comando:
```powershell
PS C:\Windows\system32> Get-Help Write-Host
```

Podemos ate pedir exemplos para o comando:
```powershell
PS C:\Windows\system32> Get-Help Write-Host -example
```

Podemos abrir uma janela utilizando o parametro `-ShowWindow`:
```powershell
PS C:\Windows\system32> Get-Help Get-Date -ShowWindow
```


## Cmdlets, funcoes e Alias
`funcoes`: Conjunto de codigos que executa algo.

`Alias`: Apelido que posso fornecer a alguma commandlets ou funcoes, por exemplo: cat -> Get-Content.


## Controlando a exibicao (saida) de informacoes

























```powershell

```
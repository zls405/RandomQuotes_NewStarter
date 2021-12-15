# Run me on the server hosting your SQL Server
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install dotnet-5.0-sdk -y
choco install dotnet-5.0-runtime -y

choco install sql-server-express -y

$sql2016RegistryPath = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQLServer"                
$sql2017RegistryPath = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQLServer"
$sql2019RegistryPath = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQLServer"
$sqlRegistryPathToUse = $null
if (Test-Path $sql2016RegistryPath)
{        
    $sqlRegistryPathToUse = $sql2016RegistryPath
}
elseif (Test-Path $sql2017RegistryPath)
{        
    $sqlRegistryPathToUse = $sql2017RegistryPath
}
elseif (Test-Path $sql2019RegistryPath)
{        
    $sqlRegistryPathToUse = $sql2019RegistryPath
}        

New-ItemProperty -Path $sqlRegistryPathToUse -Name "LoginMode" -Value "2" -PropertyType DWORD -Force
New-ItemProperty -Path "$sqlRegistryPathToUse\SuperSocketNetLib\Tcp" -Name "Enabled" -Value "1" -PropertyType DWORD -Force
New-ItemProperty -Path "$sqlRegistryPathToUse\SuperSocketNetLib\Np" -Name "Enabled" -Value "1" -PropertyType DWORD -Force

net stop MSSQL`$SQLEXPRESS /y
net start MSSQL`$SQLEXPRESS

& "netsh" advfirewall firewall add rule "name=SQL Server" dir=in action=allow protocol=TCP localport=1433
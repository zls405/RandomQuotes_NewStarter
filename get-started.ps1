# Run me on your main computer, it will configure your laptop to be a development machine so you can host SQL Server and IIS locally and debug and run the app

$randomQuotesUser = 'svcRandomQuotes_Local'
$randomQuotesPassword = 'Password01!'
$randomQuotesDatabase = 'RandomQuotes_Local'

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Dism /Online /Enable-Feature /FeatureName:IIS-ASPNET45 /All
Dism /Online /Enable-Feature /FeatureName:IIS-CertProvider /All
Dism /Online /Enable-Feature /FeatureName:IIS-HttpRedirect /All
Dism /Online /Enable-Feature /FeatureName:IIS-BasicAuthentication /All
Dism /Online /Enable-Feature /FeatureName:IIS-WebSockets /All
Dism /Online /Enable-Feature /FeatureName:IIS-ApplicationInit /All
Dism /Online /Enable-Feature /FeatureName:IIS-CustomLogging /All
Dism /Online /Enable-Feature /FeatureName:IIS-ManagementService /All
Dism /Online /Enable-Feature /FeatureName:IIS-WindowsAuthentication /All

choco install dotnet-6.0-sdk -y
choco install dotnet-6.0-runtime -y

choco install sql-server-express -y

$sqlServerConnectionString = "Server=(local)\SQLEXPRESS;Database=master;Integrated Security=True"
        
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString = $sqlServerConnectionString

#Write-Host $commandText
$command = $sqlConnection.CreateCommand()
$command.CommandType = [System.Data.CommandType]'Text'

$sqlConnection.Open()

$command.CommandText = "IF NOT EXISTS(SELECT 1 FROM sys.server_principals WHERE name = '$randomQuotesUser')
CREATE LOGIN [$randomQuotesUser] with Password='$randomQuotesPassword', default_database=master"      
$command.ExecuteNonQuery()

$command.CommandText = "IF NOT EXISTS (select Name from sys.databases where Name = '$randomQuotesDatabase')
create database [$randomQuotesDatabase]"      
$command.ExecuteNonQuery()

$sqlConnection.Close()

$randomQuotesConnectionString = "Server=(local)\SQLEXPRESS;Database=$randomQuotesDatabase;Integrated Security=True"
$randomQuotesConnection = New-Object System.Data.SqlClient.SqlConnection
$randomQuotesConnection.ConnectionString = $randomQuotesConnectionString

$randomQuotesCommand = $randomQuotesConnection.CreateCommand()
$randomQuotesCommand.CommandType = [System.Data.CommandType]'Text'

$randomQuotesConnection.Open()

$randomQuotesCommand.CommandText = "If Not Exists (select 1 from sysusers where name = '$randomQuotesUser')
	CREATE USER [$randomQuotesUser] FOR LOGIN [$randomQuotesUser] WITH DEFAULT_SCHEMA=[dbo]"            
$randomQuotesCommand.ExecuteNonQuery()

$randomQuotesCommand.CommandText = "ALTER ROLE [db_owner] ADD MEMBER [$randomQuotesUser]"
$randomQuotesCommand.ExecuteNonQuery()

$randomQuotesConnection.Close()

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

# & "netsh" advfirewall firewall add rule "name=SQL Server" dir=in action=allow protocol=TCP localport=1433

if (Test-Path "randomquotesdb")
{
    Remove-Item "randomquotesdb" -Recurse
}

dotnet publish ".\src\RandomQuotes.DbUp\RandomQuotes.DbUp.csproj" -o "randomquotesdb"

& .\randomquotesdb\RandomQuotes.DbUp.exe --connectionString="Server=(local)\SQLEXPRESS;Database=$randomQuotesDatabase;User Id=$randomQuotesUser;Password=$randomQuotesPassword;"

if (Test-Path "randomquotesdb")
{
    Remove-Item "randomquotesdb" -Recurse
}

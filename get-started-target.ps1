# Run me on the servers that are set to be a deployment target

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

choco install dotnet-5.0-sdk -y
choco install dotnet-5.0-runtime -y
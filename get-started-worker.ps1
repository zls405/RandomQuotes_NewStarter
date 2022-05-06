# Run me on the servers that are set to be a worker.  If your deployment target is also registered as a worker then you only need to run get-started-target.ps1

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install dotnet-6.0-sdk -y
choco install dotnet-6.0-runtime -y

# RandomQuotes NewStarter
An application used for new starters to help them onboard and learn Octopus Deploy.

Please fork this to your account.  Modifications, outside of making changes to keep the application up to date with the latest versions of plug-ins or to fix a bug should be avoided.

## Assumptions

## Get me started!

After forking this repo, run the script `get-started.ps1` as an admin.

The setup script assumes the following when setting this up for local runs.

1. You want to have chocolatey installed.
1. You want IIS and .NET 5 installed.
1. You want SQL Server Express installed.
1. You are running SQL Server Express with the instance name `(local)\SQLExpress`.
1. You have a database named `RandomQuotes_Local`.
1. You allow sql logins and have a user created named `svcRandomQuotes_Local`.
1. The password is the default password `Password01!`.
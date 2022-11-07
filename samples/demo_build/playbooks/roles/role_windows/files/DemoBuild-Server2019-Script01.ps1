#Stop Transcript if it's Running
Write-Host "#Stop Transcript if it's Running" -ForegroundColor Red
Stop-Transcript -Verbose

#Start Transcript
Write-Host "#Start Transcript" -ForegroundColor Red
Start-Transcript -Path "C:\Temp\DemoBuild-Server2019-Script01.txt" -Append -Force -Verbose
$DebugPreference = "Continue"
$VerbosePreference = "Continue"
$InformationPreference = "Continue"

#Rename Server
Write-Host "#Rename Server" -ForegroundColor Red
Rename-Computer -NewName demo-windows-twistlock-com -Force -PassThru

#Enable Local Administrator Account
Write-Host "#Enable Local Administrator Account" -ForegroundColor Red
Set-LocalUser -Name Administrator -Password (ConvertTo-SecureString X5PFSrZduT -AsPlainText -Force) -Verbose
Enable-LocalUser -Name Administrator -Verbose

#Install OpenSSH Server
Write-Host "#Install OpenSSH Server" -ForegroundColor Red
Add-WindowsCapability -Name OpenSSH.Server~~~~0.0.1.0 -Online -Verbose

#Install OpenSSHUtils Module
Write-Host "#Install OpenSSHUtils Module" -ForegroundColor Red
Install-Module -Name OpenSSHUtils -Scope AllUsers -Force -Verbose

#Create Firewall Rule for OpenSSH Communication
Write-Host "#Create Firewall Rule for OpenSSH Communication" -ForegroundColor Red
New-NetFirewallRule -DisplayName OpenSSH-Inbound-Port-8000 -Direction Inbound -LocalPort 8000 -Protocol TCP -Action Allow -Verbose

#Create ScheduledTask for Defender Install
Write-Host "#Create ScheduledTask for Defender Install" -ForegroundColor Red
$action = New-ScheduledTaskAction -Execute PowerShell.exe -Argument "-ExecutionPolicy Bypass -File C:\Users\twistlock\defenderinstall.ps1" -Verbose
$principal = New-ScheduledTaskPrincipal System -RunLevel Highest -Verbose
$setting = New-ScheduledTaskSettingsSet -Compatibility Win8 -Verbose
Register-ScheduledTask -TaskName DefenderInstall -Action $action -Principal $principal -Settings $setting -Force -Verbose

#Create Local User Account twistlock
Write-Host "#Create Local User Account twistlock" -ForegroundColor Red
New-LocalUser -Name twistlock -Password (ConvertTo-SecureString X5PFSrZduT -AsPlainText -Force) -AccountNeverExpires -PasswordNeverExpires -UserMayNotChangePassword -Verbose

#Add User twistlock to Administrators Group
Write-Host "#Add User twistlock to Administrators Group" -ForegroundColor Red
Add-LocalGroupMember -Group Administrators -Member twistlock -Verbose

#Install Active Directory Domain Services Role
Write-Host "#Install Active Directory Domain Services Role" -ForegroundColor Red 
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Verbose

#Reboot Server
Write-Host "#Reboot Server" -ForegroundColor Red
Restart-Computer -Confirm:$false

#Stop Transcript
Write-Host "#Stop Transcript" -ForegroundColor Red
Stop-Transcript -Verbose

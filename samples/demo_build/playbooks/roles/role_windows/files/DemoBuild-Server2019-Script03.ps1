#Stop Transcript if it's Running
Write-Host "#Stop Transcript if it's Running" -ForegroundColor Red
Stop-Transcript -Verbose

#Start Transcript
Write-Host "#Start Transcript" -ForegroundColor Red
Start-Transcript -Path "C:\Temp\DemoBuild-Server2019-Script03.txt" -Append -Force -Verbose
$DebugPreference = "Continue"
$VerbosePreference = "Continue"
$InformationPreference = "Continue"

#Install Active Directory Certifcate Services Certification Authority (CA)
Write-Host "#Install Active Directory Certifcate Services Certification Authority (CA)" -ForegroundColor Red
Install-AdcsCertificationAuthority -CAType EnterpriseRootCA -CryptoProviderName "ECDSA_P256#Microsoft Software Key Storage Provider" -KeyLength 256 -HashAlgorithmName SHA256 -Force -Verbose

#Add User twistlock to AD Groups
Write-Host "#Add User twistlock to AD Groups" -ForegroundColor Red
Add-ADPrincipalGroupMembership -Identity twistlock -MemberOf "Domain Admins","Enterprise Admins","Schema Admins" -Verbose

#Remove Local Account Admin
Write-Host "#Remove Local Account Admin" -ForegroundColor Red
Remove-LocalUser -Name Admin -Verbose

#Remove Admin Profile
Write-Host "#Remove Admin Profile" -ForegroundColor Red
$user = "admin"
$profilepath = "C:\\Users\\$user"
$wmi = "SELECT * FROM Win32_UserProfile WHERE localpath = '$profilepath'"
$profile = Get-WmiObject -Query $wmi
Remove-WmiObject -InputObject $profile -Verbose 

#Start Docker Engine Service
Write-Host "#Start Docker Engine Service" -ForegroundColor Red
Start-Service -Name docker -PassThru

#Install Docker-Compose
Write-Host "#Install Docker-Compose" -ForegroundColor Red
Invoke-WebRequest "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-Windows-x86_64.exe" -UseBasicParsing -OutFile $Env:ProgramFiles\Docker\docker-compose.exe -Verbose

#Pull Docker Images
Write-Host "#Pull Docker Images" -ForegroundColor Red
Start-Process docker -ArgumentList "pull mcr.microsoft.com/dotnet/framework/aspnet:4.8" -Wait -PassThru
Start-Process docker -ArgumentList "pull mcr.microsoft.com/dotnet/framework/runtime:3.5" -Wait -PassThru
Start-Process docker -ArgumentList "pull mcr.microsoft.com/dotnet/framework/runtime:4.8" -Wait -PassThru
Start-Process docker -ArgumentList "pull mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019" -Wait -PassThru
Start-Process docker -ArgumentList "pull mcr.microsoft.com/windows/servercore:ltsc2019" -Wait -PassThru

#Add User CA Template
Write-Host "#Add User CA Template" -ForegroundColor Red
Add-CATemplate -Name User -Force -Verbose

#Copy SSH keys for User twistlock
Write-Host "#Copy SSH keys for User twistlock" -ForegroundColor Red
Copy-Item C:\Temp\authorized_keys -Destination C:\Users\twistlock\.ssh -Force -Verbose
Copy-Item C:\Temp\twistlock_ansible_2019 -Destination C:\Users\twistlock\.ssh -Force -Verbose
Copy-Item C:\Temp\twistlock_ansible_2019.pub -Destination C:\Users\twistlock\.ssh -Force -Verbose

#Create sshdPermissionsFix.ps1
Write-Host "#Create sshdpermission.ps1" -ForegroundColor Red
$value="Repair-AuthorizedKeyPermission -FilePath C:\Users\twistlock\.ssh\authorized_keys -Confirm:0 ; Icacls C:\Users\twistlock\.ssh\authorized_keys /remove 'NT SERVICE\sshd'"
New-Item -ItemType "file" -Path "C:\Users\twistlock\sshdPermissionsFix.ps1" -Value $value -Force -Verbose

#Create ScheduledTask to Fix sshd Permissions at Startup
Write-Host "#Create ScheduledTask to Fix SSHD Permissions at Startup" -ForegroundColor Red
$action = New-ScheduledTaskAction -Execute PowerShell.exe -Argument "-ExecutionPolicy Bypass -File C:\Users\twistlock\sshdPermissionsFix.ps1" -Verbose
$principal = New-ScheduledTaskPrincipal System -RunLevel Highest -Verbose
$setting = New-ScheduledTaskSettingsSet -Compatibility Win8 -Verbose
$trigger = New-ScheduledTaskTrigger -AtStartup -Verbose
Register-ScheduledTask -TaskName sshdPermissionsFix -Action $action -Principal $principal -Settings $setting -Trigger $trigger -Force -Verbose

#Reboot Server
Write-Host "#Reboot Server" -ForegroundColor Red
Restart-Computer -Confirm:$false

#Stop Transcript
Write-Host "#Stop Transcript" -ForegroundColor Red
Stop-Transcript -Verbose

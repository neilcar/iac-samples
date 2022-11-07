#Stop Transcript if it's Running
Write-Host "#Stop Transcript if it's Running" -ForegroundColor Red
Stop-Transcript -Verbose

#Start Transcript
Write-Host "#Start Transcript" -ForegroundColor Red
Start-Transcript -Path "C:\Temp\DemoBuild-Server2019-Script02.txt" -Append -Force -Verbose
$DebugPreference = "Continue"
$VerbosePreference = "Continue"
$InformationPreference = "Continue"

#Install Active Directory Domain Services Forest
Write-Host "#Install Active Directory Domain Services Forest" -ForegroundColor Red
Install-ADDSForest -DomainName demo.windows.twistlock.com -DomainMode WinThreshold -DomainNetbiosName DEMOWINDOWS -ForestMode WinThreshold -SafeModeAdministratorPassword (ConvertTo-SecureString X5PFSrZduT -AsPlainText -Force) -NoRebootOnCompletion -Force -Verbose 

#Install Active Directory Certificate Services Certificate Authority Role
Write-Host "#Install Active Directory Certificate Services Certificate Authority Role" -ForegroundColor Red
Install-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools -Verbose

#Start OpenSSH Authentication Agent and OpenSSH SSH Server Services and Set StartupType to Automatic
Write-Host "#Start OpenSSH Authentication Agent and OpenSSH SSH Server Services and Set StartupType to Automatic" -ForegroundColor Red
Set-Service -Name sshd -StartupType Automatic -PassThru
Set-Service -Name ssh-agent -StartupType Automatic -PassThru
Start-Service -Name sshd -PassThru
Start-Service -Name ssh-agent -PassThru

#Run ssh-keygen with User twistlock
Write-Host "#Run ssh-keygen with User twistlock" -ForegroundColor Red
$user = "twistlock"
$password = ConvertTo-SecureString X5PFSrZduT -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $user, $password
Start-Process ssh-keygen -Credential $credential -PassThru

#Send Enter Key to ssh-keygen (Enter file in which to save the key (C:\Users\twistlock/.ssh/id_rsa):)
Write-Host "#Send Enter Key to ssh-keygen (Enter file in which to save the key (C:\Users\twistlock/.ssh/id_rsa):)" -ForegroundColor Red
$wshell = New-Object -ComObject wscript.shell;
$wshell.AppActivate("sshkeygen.exe")
Sleep 1
$wshell.SendKeys('~')

#Send Enter Key to ssh-keygen (Enter passphrase (empty for no passphrase):)
Write-Host "#Send Enter Key to ssh-keygen (Enter passphrase (empty for no passphrase):)" -ForegroundColor Red
$wshell = New-Object -ComObject wscript.shell;
$wshell.AppActivate("sshkeygen.exe")
Sleep 1
$wshell.SendKeys('~')

#Send Enter Key to ssh-keygen (Enter same passphrase again:)
Write-Host "#Send Enter Key to ssh-keygen (Enter same passphrase again:)" -ForegroundColor Red
$wshell = New-Object -ComObject wscript.shell;
$wshell.AppActivate("sshkeygen.exe")
Sleep 1
$wshell.SendKeys('~')
Sleep 5

#Remove Existing SSH keys for Users twistlock
Write-Host "#Remove Existing SSH keys for Users twistlock" -ForegroundColor Red
Remove-Item -Path C:\Users\twistlock\.ssh\id_rsa* -Verbose

#Comment Out AuthorizedKeysFile for SSH
Write-Host "#Comment Out AuthorizedKeysFile for SSH" -ForegroundColor Red
((Get-Content -Path C:\ProgramData\ssh\sshd_config -Raw -Verbose) -replace "       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys","#AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys") | Set-Content -Path C:\ProgramData\ssh\sshd_config -Verbose
Get-Content -Path C:\ProgramData\ssh\sshd_config -Verbose

#Reboot Server
Write-Host "#Reboot Server" -ForegroundColor Red
Restart-Computer -Confirm:$false

#Stop Transcript
Write-Host "#Stop Transcript" -ForegroundColor Red
Stop-Transcript -Verbose

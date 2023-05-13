# This script is called from the answerfile

# You cannot enable Windows PowerShell Remoting on network connections that are set to Public
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa370750(v=vs.85).aspx
# http://blogs.msdn.com/b/powershell/archive/2009/04/03/setting-network-location-to-private.aspx
# Get all network connections and change connection type to "Private"
Write-Host "Setting network connections to private"
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# Enable WinRM 
Write-Host "Enabling WinRM"
Enable-PSRemoting -Force

# Required for WinRM to work without configuring SSL on. 
# Template is set to use "Negotiate" which will use NTLM to authenitcate. No
# credentials are sent in the clear. Once WinRM is connected, it uses an
# encrypted tunnel for all communication
cmd.exe /c winrm set "winrm/config/service" '@{AllowUnencrypted="true"}'
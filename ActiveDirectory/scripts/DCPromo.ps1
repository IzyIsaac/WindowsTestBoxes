Param(
    [string]$ip,
    [string]$fqdn,
    [string]$netbios,
    [string]$safemodepassword
)

# Set DNS server to ourselves
Write-Host "Changing DNS to point to this server..."
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses $ip

# Install DC role
Write-Host "Installing AD roles..."
Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools

# Create forest and promote to domain controller
# The server will restart
Write-Host "Creating forest and promoting to domain controller..."
Install-ADDSForest `
    -DomainName $fqdn `
    -DomainNetBIOSName $netbios `
    -InstallDNS `
    -SafeModeAdministratorPassword (ConvertTo-SecureString $safemodepassword -AsPlainText -Force) `
    -Force

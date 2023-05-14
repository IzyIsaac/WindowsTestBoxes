# Run this script like: ./build.ps1 "C:/path/to/windows.iso"
param (
    [Parameter(Mandatory=$true)]
    [string]$iso_path
)

# Enable verbose build log. Useful for debugging
$env:PACKER_LOG=1
$env:PACKER_LOG_PATH="./buildlog.log"

# Generate SHA256 hash of provided ISO path
$iso_checksum = Get-FileHash $iso_path

# Start the build. 
# -force deletes artifacts from previous builds
# -on-error=ask gives you the option to see why a build is failing before packer deletes everything
# -var allows you to set variables that the packer template uses to build your box
# Variables are defined in variables.pkr.hcl, and then used in InstallWin10Pro.pkr.hcl
packer build -force -on-error=ask -var iso_path=$iso_path -var iso_checksum=$iso_checksum .
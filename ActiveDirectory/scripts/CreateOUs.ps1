param (
    [string]$fqdn,
    [string]$OUTemplate
)

# Load the OU layout from the JSON template file
$OUs = Get-Content -Path $OUTemplate -Raw | ConvertFrom-Json
ForEach-Object $OUs | fl
write-host $fqdn

# Create the domain root OU
New-ADOrganizationalUnit -Name $fqdn

# Create the rest of the OU recursively
function CreateOU($ou, $parentOUPath) {
    # Create an OU
    Write-Host $parentOUPath
    New-ADOrganizationalUnit -Name $ou.Name -Path $parentOUPath

    # Recursively call this function on ChildOUs
    if ($ou.ChildOUs) {
        $ou.ChildOUs | ForEach-Object {
            CreateOU $_ "OU=$($ou.Name),$parentOUPath"
        }
    }
}

# Create the OUs using the CreateOU function
$OUs.OUs | ForEach-Object {
    CreateOU $_ "OU=$fqdn,DC=$($fqdn.split(".")[0]),DC=$($fqdn.split(".")[1])"
}
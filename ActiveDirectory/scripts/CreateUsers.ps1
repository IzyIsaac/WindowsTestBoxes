param (
    [string]$fqdn,
    [string]$UserTemplate
)

# Load the user layout from the JSON template file
$users = Get-Content -Path $UserTemplate -Raw | ConvertFrom-Json

# DistiniguishedName of the domains Users OU
$usersOU = "OU=Users,OU=$fqdn,DC=$($fqdn.split(".")[0]),DC=$($fqdn.split(".")[1])"

function CreateUser($user, $ouPath) {
    # Create a user
    $ADuser = @{
        Name = $user.Name
        SamAccountName = $user.SamAccountName
        UserPrincipalName = "$($user.SamAccountName)@$($fqdn)"
        EmailAddress = "$($user.SamAccountName)@$($fqdn)"
        AccountPassword = ConvertTo-SecureString -String $user.Password -AsPlainText -Force
        Enabled = $true
        Department = $user.Department
        Path = $ouPath
    }
    New-ADUser @ADuser
}

# Loop through the users and create them
$users.Users | ForEach-Object {
    $user = $_
    # Get the OU DistinguishedName for the users Department
    $departmentOU = Get-ADOrganizationalUnit -Filter "name -like `"$($user.Department)`"" -SearchBase $usersOU

    # If an OU doesn't exist for Department, put in root Users OU
    if ($departmentOU -eq $null) {
        CreateUser $user $usersOU
    } else {
        CreateUser $user $departmentOU
    }
}

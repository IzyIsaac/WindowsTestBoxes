param (
    [string]$fqdn,
    [string]$UserTemplate
)

# Load the user layout from the JSON template file
$users = Get-Content -Path $UserTemplate -Raw | ConvertFrom-Json

# Get DistiniguishedName of the OU we put our users in
$usersOU = "OU=Users,OU=$fqdn,DC=$($fqdn.split(".")[0]),DC=$($fqdn.split(".")[1])"

function CreateUser($user, $ouPath) {
    # Create a user
    $ADuser = @{
        GivenName = $user.FirstName
        SurName = $user.LastName
        Name = "$($user.FirstName) $($user.LastName)"
        SamAccountName = $user.SamAccountName
        # Build UPN and email from the user SamAccountName
        UserPrincipalName = "$($user.SamAccountName)@$($fqdn)"
        EmailAddress = "$($user.SamAccountName)@$($fqdn)"
        AccountPassword = ConvertTo-SecureString -String $user.Password -AsPlainText -Force
        Enabled = $true
        Department = $user.Department
        Path = $ouPath
    }
    New-ADUser @ADuser
}

# Loop through the users objects and create them in AD
$users.Users | ForEach-Object {
    $user = $_
    # Attempt to get an OU that matches the user Department
    $departmentOU = Get-ADOrganizationalUnit -Filter "name -like `"$($user.Department)`"" -SearchBase $usersOU

    # If an OU doesn't exist for Department, put in root Users OU
    if ($departmentOU -eq $null) {
        CreateUser $user $usersOU
    } else {
        CreateUser $user $departmentOU
    }
}

#Requires –Modules ActiveDirectory

param (
        [Parameter(Mandatory=$true)]
        [String]$UserNameBase,
        [Parameter(Mandatory=$true)]
        [int]$PasswordLength,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$true)]
        [int]$NumberOfUsers,
        [Switch]$LogCreatedUsers
)

function New-RandomString {
param (
    [int]$Length
)
    $set    = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".ToCharArray()
    $result = ""
    for ($x = 0; $x -lt $Length; $x++) {
        $result += $set | Get-Random
    }
    return $result
}

function New-DomainUser {
    param (
        [Parameter(Mandatory=$true)]
        [String]$UserName,
        [Parameter(Mandatory=$true)]
        [System.Security.SecureString]$Password,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$Credential
    )
    if ($Credential) {
        New-ADUser -Name $UserName -Enabled $true -AccountPassword $Password -PasswordNeverExpires $true -Credential $Credential
    } else {
        New-ADUser -Name $UserName -Enabled $true -AccountPassword $Password -PasswordNeverExpires $true
    }
}

for ($i=1; $i -le $NumberOfUsers; $i++) {
    $GeneratedPassword = New-RandomString -Length $PasswordLength
    $SecureGeneratedPassword = ConvertTo-SecureString $GeneratedPassword -AsPlainText -Force
    New-DomainUser -UserName "$UserNameBase$i" -Password $SecureGeneratedPassword -Credential $Credential
    if ($LogCreatedUsers) {
        Out-File -InputObject "$UserNameBase$i, $GeneratedPassword" -Append -NoClobber -FilePath output.csv
    } 
}
if ($LogCreatedUsers) {
    Write-Output "Usernames and passwords are logged in output.csv"
}
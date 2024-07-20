function New-HashPassword {
    param (
        [Parameter(Mandatory=$true)]
        [SecureString]$Password
    )

    # Convert SecureString to plain text
    $PasswordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    )

    try {
        # Generate a random salt
        $SaltBytes = [byte[]]::new(16)
        [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($SaltBytes)
        $SaltBase64 = [Convert]::ToBase64String($SaltBytes)

        # Convert the password to a byte array
        $PasswordBytes = [System.Text.Encoding]::UTF8.GetBytes($PasswordText)

        # Combine the password and salt
        $PasswordWithSalt = $PasswordBytes + $SaltBytes

        # Generate the SHA-512 hash
        $SHA512 = [System.Security.Cryptography.SHA512]::Create()
        $HashBytes = $SHA512.ComputeHash($PasswordWithSalt)
        $HashBase64 = [Convert]::ToBase64String($HashBytes)

        # Output the salt and hash in the format: salt$hash
        $FinalPassword = "$6$SaltBase64$HashBase64"
        return $FinalPassword
    }
    finally {
        # Zero out the password text for security
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
    }
}

# Read password securely
$Password = Read-Host "Enter your password to encrypt" -AsSecureString
$HashedPassword = New-HashPassword -Password $Password
Write-Host "The generated password:"
Write-Output `n$HashedPassword`n
function New-HashPassword {
    param (
        [Parameter(Mandatory=$true)]
        [SecureString]$Password,
        [int]$IterationCount = 10000
    )

    # Convert SecureString to plain text
    $PasswordBSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $PasswordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordBSTR)

    try {
        # Generate a random salt (16 bytes, 128 bits) using a secure random number generator
        $RNG = [System.Security.Cryptography.RandomNumberGenerator]::Create("System.Security.Cryptography.RandomNumberGenerator")
        $SaltBytes = New-Object byte[] 16
        $RNG.GetBytes($SaltBytes)
        $SaltBase64 = [Convert]::ToBase64String($SaltBytes)

        # Generate the hash using PBKDF2 with HMACSHA256 (32 bytes, 256 bits)
        $HashAlgorithm = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($PasswordText, $SaltBytes, $IterationCount, [System.Security.Cryptography.HashAlgorithmName]::SHA256)
        $HashBytes = $HashAlgorithm.GetBytes(32)
        $HashBase64 = [Convert]::ToBase64String($HashBytes)

        # Output the salt and hash in the format: salt$hash (e.g., "salt$hash")
        $FinalPassword = "$SaltBase64`$$HashBase64"
        return $FinalPassword
    }
    catch {
        Write-Error "Error generating password hash: $_"
    }
    finally {
        # Zero out the password text for security (important to prevent sensitive data from being exposed)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordBSTR)
    }
}

# Read password securely using Read-Host with -AsSecureString
$Password = Read-Host "Enter your password to encrypt" -AsSecureString
$HashedPassword = New-HashPassword -Password $Password
Write-Host "The generated password:"
Write-Output $HashedPassword
function Get-WindowsKey {
    try {
        # Retrieve the product key from the registry
        $Key = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform').BackupProductKeyDefault
        if ($Key) {
            # Return the product key if found
            return $Key
        } else {
            # Output a message if the product key is not found
            Write-Output "Product key not found in BackupProductKeyDefault." -ForegroundColor Red
            return $null
        }
    } 
    catch {
        Write-Host "An error occurred while retrieving the product key." -ForegroundColor Red
        Write-Host "$($_.Exception.Message)"
        return $null
    }
}

try {
    # Call the function to get the Windows product key and store it in $ProductKey
    $ProductKey = Get-WindowsKey
    if ($ProductKey) {
        # Display the product key to the user
        Write-Output "Your Windows Product Key is: $ProductKey"
    }

    # Execute the slmgr.vbs /dlv command and capture its output
    $Output = & slmgr.vbs /dlv

    # Display the output of the slmgr.vbs /dlv command
    Write-Output $Output
} 
catch {
    Write-Host "An error occurred and the process was not completed." -ForegroundColor Red
    Write-Host "$($_.Exception.Message)"  
}

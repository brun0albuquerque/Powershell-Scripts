while ($true) {
    try {
        Write-Host "Select a file to calculate the hash..."

        # Create an instance of the file dialog
        Add-Type -AssemblyName System.Windows.Forms
        $FileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $FileDialog.Title = "Select a file to calculate the hash"

        # Open the dialog
        $Result = $FileDialog.ShowDialog()

        # Check if the user selected a file
        if ($Result -eq [System.Windows.Forms.DialogResult]::OK) {
            $FilePath = $FileDialog.FileName
            Write-Output "Selected file: $FilePath"

            # Calculate the hash of the selected file
            $Hash = Get-FileHash -Path $FilePath -Algorithm SHA256
            Write-Output "`nFile hash (SHA256): $($Hash.Hash)"
        } else {
            Write-Output "No file was selected."
        }
    }
    finally {
        # Compare the calculated hash with the hash provided by the official documentation
        $CalculatedHash = $($Hash.Hash);
        $OriginalHash = Read-Host "Enter the provided hash code to compare"

        # Informs that the hashes are different
        if ($CalculatedHash -eq $OriginalHash) {
            Write-Host "The hash codes are equal."
        } else {
            Write-Host "The hash codes are different."
        }
    }
    
    # Ask if the user want to calculate another file hash
    $DoItAgain = Read-Host "`nWant to calculate another file hash? (y/n)"
    if ($DoItAgain -eq 'n') {return}

    Clear-Host
}
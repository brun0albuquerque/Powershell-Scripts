function Install-Maven {
    try {
        # URL of the Maven source zip file
        $Source = "https://dlcdn.apache.org/maven/maven-3/3.9.8/binaries/apache-maven-3.9.8-bin.zip"

        # Create directory if it doesn't exist
        New-Item C:\Maven -ItemType Directory -ErrorAction SilentlyContinue

        # Destination path for downloaded zip file
        $DestinationPath = "C:\Maven"

        # Path to the downloaded zip file
        $ZipFilePath = "$DestinationPath\apache-maven-3.9.8-bin.zip"

        # Download Maven zip file from source URL
        Invoke-WebRequest -Uri $Source -OutFile $ZipFilePath

        # Extract Maven archive to destination path
        Expand-Archive -Path $ZipFilePath -DestinationPath $DestinationPath

        # Delete the .zip file
        Remove-Item -Path "C:\Maven\apache-maven-3.9.8-bin.zip"
    }
    catch {
        # Catch any errors that occur during download or extraction
        Write-Host "Error occurred during Maven download or extraction: $_.Exception.Message" -ForegroundColor Red
    }
}

# Function to set environment path for Maven
function Set-Path {
    try {
        # Path to the bin directory within the extracted Maven folder
        $NewPath = "C:\Maven\apache-maven-3.9.8\bin"

        # Destination path where Maven is extracted
        $DestinationPath = "C:\Maven"

        # Get current system path
        $CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")

        # Write current path to a file (optional step, not typically needed)
        $CurrentPath | Out-File -FilePath "$DestinationPath\EnvironmentVariables.txt" -Encoding UTF8

        # Append Maven bin directory to the current path
        $NewPath = $CurrentPath + ";" + $NewPath

        # Set the updated path in system environment variables
        [System.Environment]::SetEnvironmentVariable("Path", $NewPath, "Machine")
    }   
    catch {
        # Catch any errors that occur during path setting
        Write-Host "Error occurred while setting Maven path: $_.Exception.Message" -ForegroundColor Red
    }
}

try {
    Write-Host "Download and installing version 3.9.8 of Maven..."
    Install-Maven
    Set-Path
}   
finally {
    # Start a new Powershell sesion to output the Maven version
    pwsh.exe -Command "mvn --version"
}
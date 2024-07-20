function Install-Pwsh {
    try {
        Write-Host "Searching and installing the latest version of Powershell..."
        
        # Search for the latest version of PowerShell using Windows Package Manager (Winget)
        winget.exe search Microsoft.PowerShell

        # Install the stable and preview versions of Powershell
        winget.exe install --id Microsoft.Powershell --source winget
        winget.exe install --id Microsoft.Powershell.Preview --source winget

        # Display the PowerShell version after installation
        $PSVersionTable.PSVersion
    } 
    catch {
        Write-Host "Powershell could not be installed" -ForegroundColor Red
        Write-Host "$($_.Exception.Message)"
    }
}

function Install-Git {
    try {
        Write-Host "Installing git..."
        
        # Install git using winget
        winget.exe install --id Git.Git -e --source winget
        
        # Shows the installed version of git
        git --version
    } 
    catch {
        if (Get-Command winget.exe -ErrorAction SilentlyContinue) {
            Write-Host "The process could not been completed" -ForegroundColor Red
        } else {
            Write-Host "Winget is not installed" -ForegroundColor Red
        }
        Write-Host "$($_.Exception.Message)"
    }
}

function Install-GitHubCli {
    try {
        Write-Host "Downloading and installing GitHub CLI..."
         
        # Install the GitHub CLI 
        winget.exe install --id github.cli
        
        # Search for GitHub CLI updates and install if there is any pendent update.
        winget.exe upgrade --id github.cli
    } 
    catch {
        if (Get-Command winget.exe -ErrorAction SilentlyContinue) {
            Write-Host "The process could not been completed" -ForegroundColor Red
        } else {
            Write-Host "Winget is not installed" -ForegroundColor Red
        }
        Write-Host "$($_.Exception.Message)"
    }
}

while ($true) {
    Write-Host "Welcome to PowerShell tools panel.`n"
    $Option = Read-Host "Choose the tool to install:`n1. Powershell`n2. Git`n3. GitHub CLI`n4. Close the program`nOption"
    switch ($Option) {
        '1' {Clear-Host; Install-Pwsh; break}
        '2' {Clear-Host; Install-Git; break}
        '3' {Clear-Host; Install-GitHubCli; break} 
        '4' {Write-Host "`nClosing the program..."; return} 
        Default {Clear-Host; Write-Host "`nInvalid Input."; break}
    }
}
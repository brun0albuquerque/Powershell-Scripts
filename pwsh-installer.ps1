function Install-WinGet {
    try {
        Write-Host "Downloading WinGet and it's dependencies..."

        # Download WinGet MSIX bundle
        Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

        # Download Microsoft Visual C++ Libraries appx package
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx

        # Download Microsoft UI XAML appx package
        Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx
        
        # Install Microsoft Visual C++ Libraries, Microsoft UI XAML and install WinGet
        Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
        Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx
        Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

        # Remove the installers files
        Remove-Item Microsoft.VCLibs.x64.14.00.Desktop.appx
        Remove-Item Microsoft.UI.Xaml.2.8.x64.appx
        Remove-Item Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

        # Show the installed version of winget
        winget.exe --version
    } 
    catch {
        # Print a error message if Powershell is not installed or if an error occurred
        if (Test-Path "HKLM:\SOFTWARE\Microsoft\PowerShell\1\") {
            Write-Host "An error occurred: the proccess could not been completed" -ForegroundColor Red
        }
        Write-Host "$($_.Exception.Message)"
    }
}

function Install-Chocolatey {
    try {
        Write-Host "Downloading and installing Chocolatey and it's dependencies..."

        # Set the execution policy to Bypass for the current process to allow script execution
        Set-ExecutionPolicy Bypass -Scope Process

        # Define the URL for the Chocolatey installation script
        $Url = "https://community.chocolatey.org/install.ps1"

        # Set the security protocol to TLS 1.2 (3072) to ensure compatibility with the Chocolatey website 
        [System.Net.ServicePointManager]::SecurityProtocol = 3072

        # Download and execute the Chocolatey isntalation script
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString($Url)
        
        # Add the Chocolatey bin to the system PATH variable
        $env:Path += ";$env:ProgramData\chocolatey\bin"
    } 
    catch {
        Write-Host "The proccess could not been completed" -ForegroundColor Red
        Write-Host "$($_.Exception.Message)"
    }
}

function Install-Wsl {
    try {
        Write-Host "Installing WSL and its dependencies..."

        # Ask user if they want to install another Linux distribution
        $Option = Read-Host "The standard operating system kernel is Ubuntu. Do you want to install another Linux distribution? (Y/N)"
        if ($Option -eq 'y' -or $Option -eq 'Y') {

            # If the user chooses to install another Linux distribution, list the available distributions
            Write-Host "Available Linux distributions:"
            wsl --list --online
            $Distro = Read-Host "Enter the distribution" 
            wsl --install --distribution $Distro # Install the chosen distribution
        } elseif ($Option -eq 'n' -or $Option -eq 'N') {

            # Install Ubuntu distribution if the user chooses not to install another distribution
            Write-Host "Installing the Ubuntu distribution..."
            wsl --install
            Write-Host "Updating the WSL system:`n'sudo apt update && sudo apt upgrade'"
        } else {
            Write-Host "Enter a valid option."
        }
    } 
    catch {
        Write-Host "The proccess could not been completed" -ForegroundColor Red
        Write-Host "$($_.Exception.Message)"
    }
}

function Install-OpenSSH {
    try {
        Write-Host "Installing OpenSSH..."

        # Check if the user has administrator permissions
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Host "You do not have the necessary permissions. Run this script as Administrator."
            return
        }
        # Install OpenSSH client and server
        $OpenSSHClientCapability = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
        $OpenSSHServerCapability = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

        if (-not $OpenSSHClientCapability) {
            Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
        }   if (-not $OpenSSHServerCapability) {
            Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
        }
        # Check and create Firewall rule if it doesn't exist
        $FirewallRule = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue
        if (-not $FirewallRule) {
            Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
            New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
        } else {
            Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' already exists."
        }
        Write-Host "OpenSSH installation and configuration completed." 
    } 
    catch {
        Write-Host "The proccess could not been completed" -ForegroundColor Red
        Write-Host "$($_.Exception.Message)"
    }
}

while ($true) {
    Write-Host "Welcome to PowerShell tools panel.`n"
    $Option = Read-Host "Choose the tool to install:`n1. WinGet`n2. Chocolatey`n3. WSL`n4. OpenSSH`n5. Close the program`nOption"
    switch ($Option) {
        '1' {Clear-Host; Install-WinGet; break}
        '2' {Clear-Host; Install-Chocolatey; break}
        '3' {Clear-Host; Install-Wsl; break}
        '4' {Clear-Host; Install-OpenSSH; break} 
        '5' {Write-Host "`nClosing the program..."; return} 
        Default {Clear-Host; Write-Host "`nInvalid Input."; break}
    }
}
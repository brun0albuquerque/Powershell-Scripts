while($true) {
    # Prompt the user to enter the range of hostnames
    [int]$Range = Read-Host "Enter the range of hostnames"

    # Prompt the user to enter the hostname constant
    [string]$ConstantName = Read-Host "Enter the hostname constant"

    # Create a new file named "hosts.txt" forcefully, if it doesn't exist already
    New-Item -Path "hosts.txt" -ItemType "file" -Force

    # Iterate over the range of hostnames
    for ($i = 1; $i -le $Range; $i++) {
        # Construct the hostname by appending the constant name with the current index
        $Hostname = "$constantName$i"

        # Display a message indicating pinging of the hostname
        Write-Host "Pinging $Hostname..."

        # Ping the hostname and store the result
        $Result = Test-Connection -ComputerName $Hostname -Count 1 -Quiet

        try {
            # Get the IP address corresponding to the hostname
            $Ip = [System.Net.Dns]::GetHostAddresses($Hostname).IPAddressToString
        } 
        catch {
            # If unable to retrieve the IP address, catch the exception and display an error message
            Write-Host "Error: $_"
        }

        # Display the IP address of the hostname
        Write-Host "$Hostname IP address is: $Ip"

        # Check if the hostname is reachable
        if ($Result) {
            # Display a message indicating the hostname is reachable
            Write-Host "$Hostname is reachable."

            # Append the hostname and its IP address to the "hosts.txt" file
            Add-Content -Path "hosts.txt" -Value "$Hostname($ip)" -Force
        } else {
            # Display a message indicating no response for the hostname
            Write-Host "No response for $Hostname."
        }
    }

    # Read the content of the "hosts.txt" file into the $computers variable
    $Computers = Get-Content -Path hosts.txt

    # Iterate over and display each line in the "hosts.txt" file
    foreach ($computer in $Computers) {
        Write-Host "Computer host: $Computers"
    }

    # Prompt the user if they want to do another search
    [string]$Repeat = Read-Host "Do another search? (Y/N)"

    # Check if the user wants to repeat the search
    if ($Repeat -ne "Y") {
        break; # Exit the loop if the user does not want to repeat the search
    }
}
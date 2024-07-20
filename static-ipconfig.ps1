try {
    # Prompt the user to enter the network interface alias (name)
    $InterfaceName = Read-Host "Enter the interface alias"

    # Retrieve the network interface configuration information for the specified alias
    $InterfaceInfo = Get-NetIPConfiguration -InterfaceAlias $InterfaceName

    # Extract the current IPv4 address, prefix length, default gateway, and DNS server addresses
    $CurrentIpAddress = $InterfaceInfo.IPv4Address.IPAddress
    $PrefixLength = $InterfaceInfo.IPv4Address.PrefixLength
    $CurrentGateway = $InterfaceInfo.IPv4DefaultGateway.NextHop
    $CurrentDnsServers = $InterfaceInfo.DnsServer.ServerAddresses

    # Display the current network configuration information to the user
    Write-Host "Current IP Address: $CurrentIpAddress"
    Write-Host "Prefix Length: $PrefixLength"
    Write-Host "Current Gateway: $CurrentGateway"
    Write-Host "Current DNS Servers: $CurrentDnsServers"

    # Remove any existing IP configuration from the network interface without user confirmation
    Remove-NetIPAddress -InterfaceAlias $InterfaceName -Confirm:$false

    # Configure the IP address as static using the previously retrieved IP address, prefix length, and default gateway
    New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $CurrentIpAddress -PrefixLength $PrefixLength -DefaultGateway $CurrentGateway -Confirm:$false

    # Configure the DNS servers using the previously retrieved DNS server addresses
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $CurrentDnsServers

    # Verify and display the new network configuration
    Get-NetIPConfiguration -InterfaceAlias $InterfaceName

    # Clean the terminal
    Clear-Host
} 
catch {
    # In case of an error, remove all existing IP addresses associated with the network interface
    Get-NetIPAddress -InterfaceAlias $InterfaceName | ForEach-Object {
        Remove-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $_.IPAddress -Confirm:$false
    }

    # Reset the DNS server addresses to the default (usually automatic configuration)
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ResetServerAddresses

    # Re-enable DHCP on the network interface to automatically obtain an IP address and DNS server addresses
    Set-NetIPInterface -InterfaceAlias $InterfaceName -Dhcp Enabled

    # Restart the network interfaces
    Restart-NetAdapter -Name "*"

    # Clean the terminal
    Clear-Host
}
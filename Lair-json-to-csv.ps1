# Set the file path and name
$filepath = (pwd).Path
$filename = "lair.json"

# Get the Lair json export
$jsonFile = ((Get-Content -Raw -Path "$filepath\$filename") -replace ',\n            "webdirectories": \[\],',',') -replace ',\n    "authinterfaces": \[\],',',' | ConvertFrom-Json

# Create empty lists
$ports = @()
$hosts = @()

# Loop through all of the hosts in the json file
foreach ($lairHost in $jsonFile.hosts){

    # Loop through all of the services
    foreach ($service in $lairHost.services){

        # Add the port to the port list
        $ports += $service.port
    }
}

# Get the unique ports
$ports = $ports | Select-Object -Unique | Sort-Object

# Loop through all of the hosts in the json file
foreach ($lairHost in $jsonFile.hosts){

    # Create a temporary object
    $newHost = New-Object PSObject

    # Add the IP address
    Add-Member -InputObject $newHost -MemberType NoteProperty -Name IP -Value $lairHost.ipv4

    # Loop through all of the ports
    foreach ($port in $ports){

        # Add field for port and service
        Add-Member -InputObject $newHost -MemberType NoteProperty -Name $port -Value ""
        Add-Member -InputObject $newHost -MemberType NoteProperty -Name "$port Service" -Value ""
    }

    # Loop through all of the services
    foreach ($service in $lairHost.services){

        # Set the port and product
        $port = [string]$service.port
        $product = [string]$service.product

        # Add the port and product
        $newHost.($port) = $port
        $newHost.("$port Service") = $product
    }

    # Add the new host to the list
    $hosts += $newHost
}

# Export results to a csv file
$hosts | Export-Csv -Path "$filepath\Lair.csv" -NoTypeInformation
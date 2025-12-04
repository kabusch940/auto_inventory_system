$inventoryExists = Test-Path -Path ".\inventory.json"


## Initialize Arrays

$ips = [System.Collections.ArrayList]@()
$hostnames = [System.Collections.ArrayList]@()
$osVersions = @()
$online = [System.Collections.ArrayList]@()
$offline = [System.Collections.ArrayList]@()
$lastPing = [System.Collections.ArrayList]@()
$duplicates = @()


## Check JSON File

$wd = Get-Location


## Create new File and Set Content

if($inventoryExists -eq $false){
    $inventoryObject = @{
    IPs         = @()
    hostnames   = @()
    osVersions  = @()
    Online      = @()
    Offline     = @()
    lastPing    = @()
    LastUpdated = Get-Date
    }
    $inventoryObject | ConvertTo-Json -Depth 5 | Set-Content ".\inventory.json"
    $newInventory = Read-Host "Inventory was created in current Path. Please Add The IP Adresses of the hosts you want to check. (Comma seperated)"
    $newInventory = $newInventory-split "," | ForEach-Object { $_.Trim()} | Where-Object { $_ -ne "" }
    if ($newInventory -eq "") {
        Write-Host "Please enter some input."
    } else {
        foreach($newHost in $newInventory){
            if([ipaddress]::TryParse($newHost, [ref]$null)){
                $ips.Add($newHost) | Out-Null
            } else{
                Write-Host $newHost "is not a valid IP-Adress."
            }
        }
        
    }
} 


## Convert JSON to Object if File exists


if($inventoryExists){
    $jsonData = Get-Content -Path ".\inventory.json" -Raw
    $inventoryObject = $jsonData | ConvertFrom-Json
    foreach($ip in $inventoryObject.IPs){
    $ips.Add($ip) | Out-Null}
    Write-Host "Inventory loaded."
    $newInventory = Read-Host "Please Add The IP Adresses of the hosts you want to check. (Comma seperated)"
    $newInventory = $newInventory-split "," | ForEach-Object { $_.Trim()} | Where-Object { $_ -ne "" }
    if ($newInventory -eq "") {
        Write-Host "Please enter some input."
    } else {
        foreach($newHost in $newInventory){
            if([ipaddress]::TryParse($newHost, [ref]$null)){
                $ips.Add($newHost) | Out-Null
            } else{
                Write-Host $newHost "is not a valid IP-Adress."
            }
        }
        
    }
} 




## Input Validation (duplicates)

foreach($addedIP in $newInventory){
    if($inventoryObject.IPs -contains $addedIP){
        $duplicates += $addedIP
    }
}

if($duplicates.Count -gt 0){
    $inputValidation = Read-Host "Some IPs already exist $($duplicates -join ","). Should they be checked again? (J/N)"
}


## Check Online Status

if($newInventory){
    foreach($ip in $newInventory){
    $onlinestatus = Test-Connection -Ping $ip -Count 1 -TimeoutSeconds 1
    $pingtime = Get-Date
    if($onlinestatus.Status -eq "Success"){
        $online.Add($ip) | Out-Null
        $lastPing.Add($pingtime) | Out-Null
        Write-Host "Host" $ip "is online."
    } else {
        $offline.Add($ip) | Out-Null
        $lastPing.Add($pingtime) | Out-Null
        Write-Host "Host" $ip "is offline."
    }
    }
    
}


## Get Hostname via DNS Resolution Function

function Get-HostName {
    param(
        [string[]]$ip
    )

    $resolved = @()

    foreach($address in $ip){
        try {
            $hostname = [System.Net.Dns]::GetHostEntry($address).HostName
            $resolved += [PSCustomObject]@{
                IP       = $address
                Hostname = $hostname
            }
            Write-Host "$address was resolved to $hostname."
            $addedHostname = $results.Hostname
            try {
            $hostnames.Add($results.Hostname) | Out-Null
            Write-Host "$hostname was added to Inventory"
                }
            catch {
            Write-Host "$results could not be added."
}

        }
        catch {
            Write-Host "No DNS record was found for $address."
        }
    }

    return $resolved
}



## Check Host Name

foreach($ip in $newInventory){
    Get-HostName -ip $ip | Out-Null
}



## Inventory Object

$inventoryObject.IPs       = $ips | Select-Object -Unique
$inventoryObject.Online    = $online
$inventoryObject.Offline   = $offline      
$inventoryObject.LastUpdated = Get-Date
$inventoryObject.Hostname   = $hostnames

$inventoryObject |
    ConvertTo-Json -Depth 5 |
    Set-Content ".\inventory.json"

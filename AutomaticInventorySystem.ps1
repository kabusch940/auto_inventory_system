$inventoryExists = Test-Path -Path ".\inventory.json"


## Initialize Arrays

$ips = [System.Collections.ArrayList]@()
$hostnames = @()
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
                $ips.Add($newHost)
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


## Inventory Object

$inventoryObject.IPs       = $ips | Select-Object -Unique
$inventoryObject.Online    = $online
$inventoryObject.Offline   = $offline      
$inventoryObject.LastUpdated = Get-Date

$inventoryObject |
    ConvertTo-Json -Depth 5 |
    Set-Content ".\inventory.json"

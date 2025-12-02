$inventoryJSON = @{
    "Hosts" = $hosts
    "IPs" = $ips
    "osVersions" = $osVersions
}

## Initialize Arrays

$ips = @()
$hostnames = @()
$osVersions = @()



## Check JSON File

$wd = Get-Location

$inventoryExists = Test-Path -Path ".\inventory.json"


if($inventoryExists -eq $false){
    New-Item -Path ".\" -Name "inventory.json" -ItemType File
    $inventoryObject | ConvertTo-Json -Depth 5 | Set-Content ".\inventory.json"
    $newInventory = Read-Host "Inventory was created in current Path. Please Add The IP Adresses of the hosts you want to check. (Comma seperated)"
    $newInventory = $newInventory.Trim()
    $newInventory = $newInventory-split "," | | ForEach-Object { $_.Trim()} | Where-Object { $_ -ne "" } 
    if ($newInventory -eq "") {
        Write-Host "Please enter some input."
    } else {
        foreach($input in $newInventory){
            if([ipaddress]::TryParse($input, [ref]$null)){
                $input += $ips
            } else{
                Write-Host $input "is not a valid IP-Adress."
            }
        }
        
    }
} 



if($inventoryExists){
    $jsonData = Get-Content -Path ".\inventory.json" -Raw
    $inventoryObject = $jsonData | ConvertFrom-Json -Depth 5
    Write-Host "Inventory loaded."
    $newInventory = Read-Host "Please Add The IP Adresses of the hosts you want to check. (Comma seperated)"
    $newInventory = $newInventory.Trim()
    $newInventory = $newInventory-split "," | ForEach-Object { $_.Trim()} | Where-Object { $_ -ne "" }
    $newInventory
    if ($newInventory -eq "") {
        Write-Host "Please enter some input."
    } else {
        foreach($input in $newInventory){
            if([ipaddress]::TryParse($input, [ref]$null)){
                $input += $ips
            } else{
                Write-Host $input "is not a valid IP-Adress."
            }
        }
        
    }
} 


## Save IP to JSON

foreach($newIP in $newInventory){
    $inventoryObject.IPs += $newIP
}

$inventoryObject | ConvertTo-Json -Depth 5 | Set-Content .\inventory.json
Write-Host "Inventory Updated."

## Inventory Object

$inventoryObject = @{
    IPs         = $ips
    osVersions           = $osVersions
    hostnames             = $hostnames
    LastUpdated         = (Get-Date)
}



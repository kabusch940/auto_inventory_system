$inventoryJSON = @{
    "Hosts" = $hosts
    "IPs" = $ips
}

## Initialize Arrays

$ips = @()
$hostnames = @()
$osVersions
$


## Check JSON File

$wd = Get-Location

$inventoryExists = Test-Path -Path ".\auto_inventory_system\inventory.json"


if($inventoryExists -eq $false){
    New-Item -Path ".\auto_inventory_system" -Name "inventory.json" -ItemType File
    $newInventory = Read-Host "You don't have an inventory yet. Please Add The IP Adresses of the hosts you want to check. (Comma seperated)"
    $newInventory = $newInventory.Trim()
    $newInventory = $newInventory-split "," | Where-Object { $_ -ne "" }
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
    Write-Host "Inventory found."
    $newInventory = Read-Host "Please Add The IP Adresses of the hosts you want to check. (Comma seperated)"
    $newInventory = $newInventory.Trim()
    $newInventory = $newInventory-split "," | Where-Object { $_ -ne "" }
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

$inventoryJSON.IPs

$inventoryJSON | ConvertTo-Json -Depth 5 | Set-Content -Path ".\auto_inventory_system\inventory.json"
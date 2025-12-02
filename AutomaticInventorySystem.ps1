## Initialize Arrays

$ips = @()
$hostnames = @()
$osVersions = @()
$online = [System.Collections.ArrayList]@()
$offline = [System.Collections.ArrayList]@()
$LastPing = [System.Collections.ArrayList]@()


## Check JSON File

$wd = Get-Location

$inventoryExists = Test-Path -Path ".\inventory.json"


## Create new File and Set Content

if($inventoryExists -eq $false){
    $createdInventory = New-Item -Path ".\" -Name "inventory.json" -ItemType File
    $inventoryObject | ConvertTo-Json | Set-Content $createdInventory
    $newInventory = Read-Host "Inventory was created in current Path. Please Add The IP Adresses of the hosts you want to check. (Comma seperated)"
    $newInventory = $newInventory.Trim()
    $newInventory = $newInventory-split "," | ForEach-Object { $_.Trim()} | Where-Object { $_ -ne "" } 
    if ($newInventory -eq "") {
        Write-Host "Please enter some input."
    } else {
        foreach($newHost in $newInventory){
            if([ipaddress]::TryParse($newHost, [ref]$null)){
                $ips += $newHost
            } else{
                Write-Host $newHost "is not a valid IP-Adress."
            }
        }
        
    }
} 


## Convert JSON to Object if File exists

if($inventoryExists){
    $jsonData = Get-Content -Path ".\inventory.json" -Raw
    $inventoryObject = $jsonData | ConvertFrom-Json -Depth 5
    $ips += $inventoryObject.IPs
    Write-Host "Inventory loaded."
    $newInventory = Read-Host "Please Add The IP Adresses of the hosts you want to check. (Comma seperated)"
    $newInventory = $newInventory.Trim()
    $newInventory = $newInventory-split "," | ForEach-Object { $_.Trim()} | Where-Object { $_ -ne "" }
    if ($newInventory -eq "") {
        Write-Host "Please enter some input."
    } else {
        foreach($newHost in $newInventory){
            if([ipaddress]::TryParse($newHost, [ref]$null)){
                $ips += $newHost
            } else{
                Write-Host $newHost "is not a valid IP-Adress."
            }
        }
        
    }
} 



## Input Validation (duplicates)

foreach($addedIP in $newInventory){
    if($inventoryObject.IPs -contains $addedIP){
        $inputValidation = Read-Host "IP already exists. Should the status be checked? (J/N)"
    }
}

if($inputValidation -match "^[Jj]$"){
    foreach($addedIP in $newInventory){
        $ips = $ips | Where-Object { $_ -ne $addedIP }
        ## function placeholder for WinRM check
    }
}




## Inventory Object

$inventoryObject        = @{
    IPs                 = $ips
    osVersions          = $osVersions
    hostnames           = $hostnames
    LastUpdated         = (Get-Date)
    Online =            = $online
    Offline =           = $offline
    lastPing =          = $lastPing
}

$inventoryObject | ConvertTo-Json -Depth 5 | Set-Content .\inventory.json
Write-Host "Inventory Updated."


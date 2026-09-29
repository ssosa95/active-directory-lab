<#
.SYNOPSIS
Creates Active Directory users from a CSV file and then logs the results to a text file.

.DESCRIPTION
Reads user information from a CSV and creates accounts in the specified OU. 
Also provides a summary of created, skipped, and failed accounts and logs the results to a text file.

.PARAMETER CsvPath
Path to the CSV file containing user data. Edit the script to change the default path if needed.

.PARAMETER ouPath
The distinguished name of the OU where users will be created. Edit the script to change the default OU if needed.

.PARAMETER securePassword
The temporary password to assign to new users. Edit the script to change the default password if needed.

.EXAMPLE
.\New-EmployeeAccounts.ps1

.NOTES
Author: Samuel Sosa Perez
Version: 1.0
#>

#Requires -Modules ActiveDirectory

param(
    [string]$CsvPath = "C:\newusers.csv",
    [string]$ouPath = "OU=TestGroup,DC=lab,DC=local",
    [securestring]$securePassword = (ConvertTo-SecureString "TempPass123!" -AsPlainText -Force)
)

$createdCount = 0
$skippedCount = 0
$failedCount = 0


Import-Csv -Path $CsvPath | ForEach-Object {

    $currentUser = $_

    if ([string]::IsNullOrWhiteSpace($currentUser.Username)) {
        Write-Host "FAILED: '$($currentUser.Name)' - missing username" -ForegroundColor Red
        "$(Get-Date): Failed - missing username for $($currentUser.Name)" | Out-File -FilePath "C:\ad_import_log.txt" -Append
        $failedCount++
        return
    }
    
    $baseUsername = $currentUser.Username.Trim()

    try {
        $existingMatch = $null
        try {
           $existingMatch = Get-ADUser -Identity $baseUsername -ErrorAction Stop
        } catch {
            # If the user does not exist, we can proceed to create it
            $existingMatch = $null
        }

        if ($existingMatch -and $existingMatch.Name -eq $currentUser.Name) {
        # Same person, same username —> this really is a re-import, skip it
            Write-Host "SKIPPED (already exists): $baseUsername" -ForegroundColor Yellow
        "$(Get-Date): Skipped $baseUsername" | Out-File -FilePath "C:\ad_import_log.txt" -Append
        $skippedCount++
    }    else {
            # Either no collision at all, or a collision with a genuinely different person
            $finalUsername = $baseUsername
            $suffix = 1
            $stillTaken = $true
            while ($stillTaken) {
                try {
                    Get-ADUser -Identity $finalUsername -ErrorAction Stop | Out-Null
                    # If the user exists, we need to try a new username
                    $finalUsername = "$baseUsername$suffix"
                    $suffix++
                } catch {
                    # If the user does not exist, we can proceed to create it
                    $stillTaken = $false
                }
                
            }
            Write-Host "Creating Name='$($currentUser.Name)' Sam='$finalUsername'"
            New-ADUser -Name $finalUsername -SamAccountName $finalUsername -DisplayName $currentUser.Name -UserPrincipalName "$finalUsername@lab.local" -Path $ouPath -Enabled $true -AccountPassword $securePassword -ChangePasswordAtLogon $true
            Write-Host "Created: $finalUsername (requested: $baseUsername)" -ForegroundColor Green
            "$(Get-Date): Created $finalUsername (requested: $baseUsername)" | Out-File -FilePath "C:\ad_import_log.txt" -Append
            $createdCount++
        }
    } catch {
        Write-Host "FAILED: $baseUsername - $($_.Exception.Message)" -ForegroundColor Red
        "$(Get-Date): Failed to process $baseUsername" | Out-File -FilePath "C:\ad_import_log.txt" -Append
        $failedCount++
    }
}

Write-Host "Summary: Created: $createdCount, Skipped: $skippedCount, Failed: $failedCount" -ForegroundColor Cyan

<#

This script is used to restore an AD User that's still in the Deleted Objects OU.
This script validates that the ID entered is indeed in the Delted Objects OU.
If the script finds more than one ID with the same name in the Delted Objects OU, the script shows the ObjectGUID and other details 
of each one of them and gives the option to enter the ObjectID of the ID we want to restore.
The script also generates a log file stating: 
    -Who used the script.
    -The name and ObjectGUID of the ID restored.
    -The date when it was restored.

#>


Write-Host @"
	
	
	WARNING!!
	
	THIS SCRIPT WILL RESTORE THE ID YOU ENTER. USE WITH CAUTION.
	MAKE SURE YOU TYPE THE ID CORRECTLY.
  	
	
"@
Pause
Write-Host "`n`n"

$currentUser = whoami
$date = (Get-Date).ToString('MM-dd-yyyy hh:mm:ss')
$LogaDate = (Get-Date).ToString('MM-dd-yyyy')
$counter = 0


$ID = Read-Host "Enter the ID to be restored"
Write-Host "`n"

$ExistanceValidation = Get-ADObject -Filter {samaccountname -eq $ID -and deleted -eq $true -and objectClass -eq 'user'} -IncludeDeletedObjects | Select-Object -ExpandProperty name


foreach ($line in $ExistanceValidation){
    $counter++
    }


if($counter -eq 0){
    $MainOUCheck = Get-ADUser $ID | Select-Object -ExpandProperty name
    $ObjectClassCheck = Get-ADUser $ID | Select-Object -ExpandProperty ObjectClass
        
    if($ObjectClassCheck -ne 'user'){
    Write-Host "$ID is not a user object"
        }
elseif($MainOUCheck -eq $null){
    Write-Host "$ID could not be found on local AD"
        }
    }
elseif($counter -eq 1){
        
    #We ask to enter the credentials of an account with enough privileges to restore an ID from Deleted Objects.
    $credential = Get-Credential "Domain\AdminAccount"
    Get-ADObject -Filter {samaccountname -eq $ID} -IncludeDeletedObjects | Restore-ADObject -Credential $credential

    #We give it a 5 seconds delay to give AD time to show it restored.
    Start-Sleep -Seconds 5

    $RestoreValidation = Get-ADUser $ID | Select-Object -ExpandProperty name
    if ($RestoreValidation -eq $Null){
           
        #We advise the user to check again later, in case the ID was restored but the time we gave it wasn't enough.
        Write-Host "An error occurred. Check again later if the object was restored.`n"
        Write-Host "$currentUser tried to restore $ID on $date. Check again later if the object was restored" | Add-Content ".\logs\$LogaDate.txt"
        Pause        
        }
    elseif ($RestoreValidation -ne $null){
        Write-Host "$ID was restored successfully`n"
        Write-Host "$ID was restored by $currentUser on $date"  | Add-Content ".\logs\$LogaDate.txt"
        Pause
        }
    }
elseif($counter -ge 2){
    Write-Host "More than one object with the same name were found in the Deleted Objects OU:`n"
    Get-ADObject -Filter {samaccountname -eq $ID -and deleted -eq $true -and objectclass -eq 'user'} -IncludeDeletedObjects -Properties * | Select ObjectGUID, name, whencreated, whenchanged

    $ObjectGUID1 = "`nEnter the Object GUID of the ID to be restored"
    $ObjectGUID = $ObjectGUID1 -replace ' ', ''
    Write-Host "`n"
    $credential = Get-Credential "Domain\AdminAccount"
    Get-ADObject -Filter {samaccountname -eq $ID} -IncludeDeletedObjects | Restore-ADObject -Credential $credential

    Start-Sleep -Seconds 5

    $RestoreValidation = Get-ADUser $ID | Select-Object -ExpandProperty name
    if ($RestoreValidation -eq $Null){
        Write-Host "An error occurred. Check again later if the object was restored.`n"
        Write-Host "$currentUser tried to restore $ID ($ObjectGUID) on $date. Check again later if the object was restored" | Add-Content ".\logs\$LogaDate.txt"
        Pause
        }

    elseif ($RestoreValidation -ne $null){
        Write-Host "$ID ($ObjectGUID) was restored successfully`n"
        Write-Host "$ID ($ObjectGUID) was restored by $currentUser on $date"  | Add-Content ".\logs\$LogaDate.txt"
        Pause
        }
    }

<#

•This script updates the Global Address List of cloud-only room mailboxes details by updating the necessary Azure AD attributes.
•The script also makes all the necessary validations to check if:
    -The credentials used don't have the User Admin role activated in Azure.
    -The credentials used don't belong to an admin account.
    -There is a problem connecting to Azure AD.
    -Something is missing in the input file.
•The company in this example will be Contoso, and it's primary domain will be @contoso.com.
•The requestor fills an Excel file template with the following columns: ID, Primary Domain, Alias 1, Alias 2, Alias 3. This information is used to validate what is to be replicated.
•The content of the excel file must be copied and pasted into the input.txt file.
•The input file must be correctly filled. If a field is empty, the corresponding attribute will be set to NULL if possible (this is to allow the end user to remove a detail if needed).

#>


Write-Host @"


    WARNING!!

    This script requires that you activate the Azure User Admin role
    in the Azure Portal first.

    If you haven't activated it yet, close the script and try again
    later.


"@
Pause

#The account used in $AzureID can be any account with read privileges on Azure AD.
    
$AzureID = 'credentials@contoso.com'
$Password = "TypeThePasswordHere"
$SecureString = ConvertTo-SecureString -AsPlainText $Password -Force
$SecuredCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AzureID,$SecureString


$AzureADAdminAccount = Connect-AzureAD | Select-Object -ExpandProperty Account

#Exit the script if you didn't enter admin credentials.
#This validation is useful if this role is only assigned to admin accounts (which is highly recommendable).
#This validation check must be updated according to the naming convention of the company for admin accounts (in this case, admin accounts start with 'admin.').

if ($AzureADAdminAccount -notlike 'admin.*'){

    Write-Host "`nYou didn't enter admin credentials. Try again later`n"

    Pause
    Exit
    }

#Exit the script if Connect-AzureAD is not successfull.

if ($AzureADAdminAccount -eq $Null){
    Write-Host @"

    An error occurred while trying to connect to Azure AD.
    Please try again later.
    
"@
    Pause
    Exit
    }

#Exit the script if the entered credentials don't have the User Admin role activated.

#'3505gd80-dbdd-5195-a21b-3d217c93gf9c' is the User Administrator role's Object ID in this case.
#This Object ID must be updated according to the User Administrator role's Object ID of the tenant where it's intended to be used.

$RoleCheck = Get-AzureADDirectoryRoleMember -ObjectId '3505gd80-dbdd-5195-a21b-3d217c93gf9c' | Select-Object -ExpandProperty userPrincipalName

if ($RoleCheck -notcontains $AzureADAdminAccount){
    Write-Host @"

    ERROR: The credentials you entered do not 
    have the Azure User Admin role activated.
    Please activate your role and try again later.

"@
    Pause
    Exit
    }


#Removing the old output file in case it exists.

Remove-Item ".\output.txt" -ErrorAction SilentlyContinue


#Assign a name to each extracted value from the input file.

foreach ($line2 in Get-Content '.\input.txt'){
    
    #This validation is to allow the user to paste the content of the input file with or without the headers (the line with the headers is ignored).
    if ($line2 -notlike "Name	Location	Address*"){
    
        $Counter = 0

        #To avoid conflicts with any special character the user might have used in the input file, I recommend using rare characters like ♣ to split lines, which are highly unlikely to be used in any input file.
        #If this is not an issue for you, you can simply use special characters like ";" instead.

        $line1 = $line2 -replace '\t', '♣'
        $line = $line1.split('♣')

        foreach ($a in $line){
            $Counter++
            }
        if ($Counter -ne 15){
            $Name = $line[0]
            Write-Host "$name : Something is missing in the input file for this mailbox. Please fix it and try again later." | Add-Content '.\output.txt'
            Continue
            }
        Else{

            $Name = $line[0]
            $PhysicalDeliveryOfficeName = $line[1]
            $StreetAddress = $line[2]
            $City = $line[3]

            if ($line[4] -eq ""){
                $State = $NULL
                }
            else{
                $State = $line[4]
            }

            $PostalCode = $line[5]
            $Country = $line[6]

            if ($line[7] -eq ""){
                $TelephoneNumber = $NULL
                }
            else{
            $TelephoneNumber = $line[7]
                }

            if ($line[8] -eq ""){
                $Capacity = $NULL
                }
            else{
                $Capacity = $line[8]
                } 
    
            $JobTitle = $line[9]
            $Mail = $line[10]
            $DisplayName = $line[11]
            $Department = $line[12]
            $CountryCode = $line[13]  
            $GeographicUnit = $line[14]

            $ObjectID = Get-AzureADUser -SearchString $Name | Select-Object -ExpandProperty ObjectID


            #Since this script is exclusively for cloud-only accounts, hybrid accounts must be rejected and processed with a different script that works with the on-prem directory.
            #Also, for the purposes of this script, the mail attribute cannot be updated and is to be removed as an option from the input file.

            $CheckOnPrem = Get-ADUser -Filter {name -eq $Name} | Select-Object -ExpandProperty name
        
            If ($CheckOnPrem -ne $Null){
                Write-Host "$Name is not a Cloud Only Account. Use the normal GAL Update script for this mailbox." | Add-Content ".\output.txt"
                Continue
                }
            elseif ($Mail -notlike "$Name@contoso.com"){
                Write-Host "$Name Failure: Email address cannot be changed and must match the ID" | Add-Content ".\output.txt"
                Continue
                }

 
            else{
        
                #Set the Azure AD default attributes.
                #The Try-catch will abort the script if it can't process the first line
                Try{
                    Set-AzureADUser -ObjectId $ObjectID -PhysicalDeliveryOfficeName $PhysicalDeliveryOfficeName -StreetAddress $StreetAddress -City $city -State $State -PostalCode $PostalCode -Country $Country -UsageLocation $CountryCode -TelephoneNumber $TelephoneNumber -JobTitle $JobTitle -DisplayName $DisplayName -Department $Department
                    
                    #Set the Azure ad extension attributes.
                    #'b4ge315071f53ceeb84g8272784bd349' is a unique identifier and is part of the extension attributes names on Azure AD. These attribute names will variate from tenant to tenant.

                    Set-AzureADUserExtension -ObjectId $ObjectID -ExtensionName 'extension_b4ge315071f53ceeb84g8272784bd349_countryCode' -ExtensionValue $CountryCode
                    Set-AzureADUserExtension -ObjectId $ObjectID -ExtensionName 'extension_b4ge315071f53ceeb84g8272784bd349_geographicUnitCode' -ExtensionValue $GeographicUnit
                    }

                catch{
                    Write-Host "$Name Failure: Couldn't process the input file. Check the entered data." | Add-Content ".\output.txt"
                    continue
                    }

                Try{
                    Set-Mailbox $name -ResourceCapacity $Capacity
                    }
                Catch{
                    Write-Host "$Name Failure: Capacity couldn't be updated on Exchange Online." | Add-Content ".\output.txt"
                    }


                Write-Host "$Name Success: Mailbox was updated successfully" | Add-Content ".\output.txt"
                }
            }
        }
    }
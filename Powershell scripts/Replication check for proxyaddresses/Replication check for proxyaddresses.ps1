<#

•This script validates that all the changes on proxyaddresses get processed correctly and validates the replication to Azure AD as well.
•The company in this example will be Contoso, and it's primary domain will be @contoso.com. It can be requested to change this primary domain for ID objects, but not for distribution lists.
•The requestor fills an Excel file template with the following columns: ID, Primary Domain, Alias 1, Alias 2, Alias 3. This information is used to validate what is to be replicated.
•The content of the excel file must be copied and pasted into the input.txt file.

#>

#Pre-requisites and counters
#Remove the old output files in case they exist.

Remove-Item '.\output\Not on-Prem.txt' -ErrorAction SilentlyContinue
Remove-Item '.\output\Not on Azure.txt' -ErrorAction SilentlyContinue
Remove-Item '.\output\No errors found.txt' -ErrorAction SilentlyContinue
Remove-Item '.\output\Not on-Prem (primary).txt' -ErrorAction SilentlyContinue
Remove-Item '.\output\Not on Azure (primary).txt' -ErrorAction SilentlyContinue


#Auxiliar counters and arrays that will be used in the script.

$AzureCounter = 0
$AzureCounterPrimary = 0
$onPremCounter = 0
$onPremCounterPrimary = 0
$totalCounter = 0
$totalCounterPrimary = 0
$NotOnPrem = @()
$NotOnPremPrimary = @()
$NotOnAzure = @()
$NotOnAzurePrimary = @()
$Errors = @()

foreach ($line1 in Get-Content '.\input.txt'){
    $line = $line1 -replace '\t', ';'
    $array = $line.Split(';')
foreach ($alias in $array | select -Skip 2){
    if ($alias -ne ""){
        $totalCounter++
        }
    }
}

foreach ($line1 in Get-Content '.\input.txt'){
    $line = $line1 -replace '\t', ';'
    $array = $line.Split(';')
    if ($array[1] -notlike "contoso.com"){
        $totalCounterPrimary++
        }
}

#Spliting the line

foreach ($line1 in Get-Content '.\input.txt'){
    if ($line1 -notmatch '\w' -or $line1 -like "Name	Primary Domain	Alias 1*"){}
    else{

        $line = $line1 -replace '\t', ';'
        $array = $line.Split(';')
        $ID = $array[0]
        $PrimaryDomain = $array[1]

#Detecting if it's a group or a user

        $objectType = Get-ADObject -Filter {name -eq $ID} | Select-Object -ExpandProperty objectClass

        switch($objectType){
            'group'{

            foreach ($alias in $array | select -skip 2){
                if ($alias -match '\w'){
                    $AzureGroup = Get-AzureADGroup -Filter "mailnickname eq '$ID'" | Select-Object -ExpandProperty proxyaddresses
                    if ($AzureGroup -notcontains "smtp:$alias"){
                        $NotOnAzure += "$ID;$alias"
                        $AzureCounter++
                        }
                }

                if ($PrimaryDomain -notlike 'contoso.com' -or $PrimaryDomain -notlike '@contoso.com'){
                    $Errors += "$ID : Groups can only have contoso.com as primary smtp"
                    }
                }
        }
    

            'user'{


                $TestFormer = get-aduser $ID | Select-Object -ExpandProperty distinguishedname
                $TestDisabled = get-aduser $ID | Select-Object -ExpandProperty enabled

                if ($TestFormer -notmatch 'OU=Former' -and $TestDisabled -notlike 'False'){



                    if ($PrimaryDomain -eq 'contoso.com' -or $PrimaryDomain -eq '@contoso.com'){}
                    else{
                        $PrimarySMTPOnPrem = get-aduser $ID -Properties proxyaddresses | Select-Object -ExpandProperty proxyaddresses
                        if ($PrimarySMTPOnPrem -notcontains "$ID@$PrimaryDomain*"){
                            $NotOnPremPrimary += $ID
                            $onPremCounterPrimary++
                            }

                        $PrimarySMTPOnAzure = Get-AzureADUser -filter "mailnickname eq '$ID'" | Select-Object -ExpandProperty proxyaddresses
                        if ($PrimarySMTPOnAzure -notcontains "$ID@$PrimaryDomain*"){
                            $NotOnAzurePrimary += "$ID;$alias"
                            $AzureCounterPrimary++
                            }


                        foreach ($alias in $array | select -skip 2){
                            if ($alias -ne ""){
                                $onPremUser = Get-ADUser $ID -Properties proxyaddresses | Select-Object -ExpandProperty proxyaddresses
                                $AzureUser = Get-AzureADUser -filter "mailnickname eq '$ID'" | Select-Object -ExpandProperty proxyaddresses

                                if ($onPremUser -notcontains "smtp:$alias"){
                                    $NotOnPrem += "$ID;$alias"
                                    $onPremCounter++
                                }


                            if ($AzureUser -notcontains "smtp:$alias"){
                                $NotOnAzure += "$ID;$alias"
                                $AzureCounter++
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

if ($onPremCounter -ne '0'){
    Write-Host "Number of users that haven't replicated on-prem: $onPremCounter" | Add-Content '.\output\Not on-Prem.txt'
    $onPremDone = $totalCounter - $onPremCounter
    Write-Host "$onPremDone out of $totalCounter have replicated on prem `n`n" | Add-Content '.\output\Not on-Prem.txt'
    Write-Host "Users that haven't replicated on prem: " | Add-Content '.\output\Not on-Prem.txt'
    foreach ($line in $NotOnPrem){
        Write-Host "$line" | Add-Content '.\output\Not on-Prem.txt'
        }
    }


#Creating the output files with the results

if ($AzureCounter -ne '0'){
    Write-Host "Number of users that haven't replicated to Azure: $AzureCounter" | Add-Content '.\output\Not on Azure.txt'
    $AzureDone = $totalCounter - $AzureCounter
    Write-Host "$AzureDone out of $totalCounter have replicated to Azure n`n" | Add-Content '.\output\Not on Azure.txt'

    Write-Host "Users that haven't replicated to Azure yet:" | Add-Content '.\output\Not on Azure.txt'
    foreach ($line in $NotOnAzure){
        Write-Host "$line" | Add-Content '.\output\Not on Azure.txt'
        }
    }

if ($AzureCounter -eq '0' -and $onPremCounter -eq '0'){
    Write-Host "All the aliases have replicated successfully. 0 errors found" | Add-Content '.\output\No errors found.txt'
    }

if ($onPremCounterPrimary -ne '0'){
    Write-Host "Number of users that haven't replicated on-prem: $onPremCounterPrimary" | Add-Content '.\output\Not on-Prem (Primary).txt'
    $onPremDonePrimary = $totalCounterPrimary - $onPremCounterPrimary
    Write-Host "$onPremDonePrimary out of $totalCounterPrimary have replicated on prem `n`n" | Add-Content '.\output\Not on-Prem (Primary).txt'

    Write-Host "Users that haven't replicated on prem: " | Add-Content '.\output\Not on-Prem (Primary).txt'
    foreach ($line in $NotOnPremPrimary){
        Write-Host "$line" | Add-Content '.\output\Not on-Prem (Primary).txt'
        }
    }


if ($AzureCounterPrimary -ne '0'){
    Write-Host "Number of users that haven't replicated on Azure: $AzureCounterPrimary" | Add-Content '.\output\Not on Azure (Primary).txt'
    $AzureDonePrimary = $totalCounterPrimary - $AzureCounterPrimary
    Write-Host "$AzureDonePrimary out of $totalCounterPrimary have replicated on prem `n`n" | Add-Content '.\output\Not on Azure (Primary).txt'
    Write-Host "Users that haven't replicated on prem: " | Add-Content '.\output\Not on Azure (Primary).txt'
    foreach ($line in $NotOnAzurePrimary){
        Write-Host "$line" | Add-Content '.\output\Not on Azure (Primary).txt'
        }
    }
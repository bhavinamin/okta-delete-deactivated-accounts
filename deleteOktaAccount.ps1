#Okta Account Deletion for those older than X amount of days
#Author: Bhavin Amin
#For sys admins only. Ensure tokens are active and correctly scoped.

#Account age (90 days in this case)
$dayThreshold = 90

#Okta Auth
$oktaBaseURL = "https://###.okta.com/api/v1"
$oktaApiKey = "00yu9#######################"
$oktaHeaders = @{
    "Authorization" = "SSWS $oktaApiKey"}
$type = "application/json"

#Get deprovisioned accounts
$status = "DEPROVISIONED"
$oktaSearchURL = "/users?search=status eq `"$status`""
$requestURL = $oktaBaseURL + $oktaSearchURL
$result = Invoke-WebRequest -Uri $requestURL -Headers $oktaHeaders -ContentType $type -Method Get 
$resultParsed = ($result.Content | ConvertFrom-Json) | select id, statusChanged, profile


#DateDiff the statusChanged and add them to pool of accounts to delete (those older than 90 days)
$accountsToDelete=@()
$resultParsed | foreach {
    $date = [datetime]::Parse($_.statusChanged)
    $now = Get-Date
    $datediff = ($now - $date).Days
    
    if ($datediff -gt $dayThreshold){
        $accountsToDelete+=($_)
    }
   
}


#Delete 'em!
$accountsToDelete | foreach {
    $id = $_.id 
    $firstName = $_.profile.firstName
    $lastName = $_.profile.lastName 
    Write-Host "Deleting account: $firstName $lastName with id $id" -ForegroundColor Gray
    $oktaUserUrl = "/users/$id"
    $requestURL = $oktaBaseURL + $oktaUserUrl
    $result = Invoke-WebRequest -Uri $requestURL -Headers $oktaHeaders -ContentType $type -Method Delete
    $result.StatusCode
}

 




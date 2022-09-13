Function getListOfSites([String]$identity_code){
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Token "+$identity_code)
    
    $body = "{`"query`":`"{`\n  authorizedSites {`\n    sites {`\n      id`\n      name`\n    }`\n  }`\n}`",`"variables`":{}}"
    
    $response = Invoke-RestMethod 'https://api.lansweeper.com/api/v2/graphql' -Method 'POST' -Headers $headers -Body $body
    $response | ConvertTo-Json -Depth 9
    $response
}
function getListOfReports([String]$identity_code,[String]$site_id){
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Token "+$identity_code)

    $body = "{`"query`":`"{`\n  site(id: `\`""+$site_id+"`\`") {`\n    authorizedReports {`\n      id`\n      name`\n      isDefault`\n      description`\n      category`\n      subcategory`\n    }`\n  }`\n}`",`"variables`":{}}"

    $response = Invoke-RestMethod 'https://api.lansweeper.com/api/v2/graphql' -Method 'POST' -Headers $headers -Body $body
    $response | ConvertTo-Json -Depth 9
   
    $response
}
function getReportUrl([String]$identity_code,[String]$site_id,[String]$report_id){
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Token "+$identity_code)
    
    $body = "{`"query`":`"{`\n  site(id: `\`""+$site_id+"`\`") {`\n    id`\n    name`\n    reportExecutionResults(reportId: `\`""+$report_id+"`\`") {`\n      url`\n    }`\n  }`\n}`",`"variables`":{}}"
    
    $response = Invoke-RestMethod 'https://api.lansweeper.com/api/v2/graphql' -Method 'POST' -Headers $headers -Body $body
    $response | ConvertTo-Json -Depth 9   
    $response
}

function getListOfAllReportsFromAllSites([String]$identity_code){
    $sites = getListOfSites $identity_code
    $sites = $sites.data.authorizedSites.sites
    for (($i = 0); $i -lt $sites.length; $i++)
    {
        Write-Host "*** Available reports in site: " $sites[$i].name "`n"
        $reports= getListOfReports $identity_code $sites[$i].id
        $reports = $reports.data.site.authorizedReports
        for (($j = 0); $j -lt $reports.length; $j++)
        {
            Write-Host $reports[$j].name
            Write-Host $reports[$j].id "`n"

        }
    }

}

function getReportData([String]$URL){
    $response = Invoke-RestMethod -Uri $URL
    $data = $response.Split([Environment]::NewLine)
    $numberoflines = $data.length
    $numberoflines
}

Write-Host "Lansweeper Reporting API integration `nFor more about information about API please reach https://docs.lansweeper.com/ `n `n"
if ($args.Count -eq 1) {
	Write-Host "Found a single argument. Trying to use it as Identity Code..."
    getListOfAllReportsFromAllSites $args[0]
}

elseif ($args.Count -eq 3) {
	Write-Host "Found a three arguments. Trying to get number of lines in the report."
    $url= getReportUrl $args[0] $args[1] $args[2]
    $url = $url.data.site.reportExecutionResults.url
    $lines=getReportData $url
    $lines
}
else{
    Write-Host "Wrong number of arguments"
}



#getListOfSites("lsp_5/sN8ooJAxGas+HrTlYF0XIwuPCGXS01701462587")
#getListOfReports "lsp_5/sN8ooJAxGas+HrTlYF0XIwuPCGXS01701462587" "1610fb57-ea49-4a54-9ef9-e61e2c6253a5"
#getReportUrl "lsp_5/sN8ooJAxGas+HrTlYF0XIwuPCGXS01701462587" "1610fb57-ea49-4a54-9ef9-e61e2c6253a5" "60c1b60ac9b03d809d1a1ce7"
#getListOfAllReportsFromAllSites "lsp_5/sN8ooJAxGas+HrTlYF0XIwuPCGXS01701462587"
#getReportData "https://lec-reports-execution-production.s3.eu-west-1.amazonaws.com/1610fb57-ea49-4a54-9ef9-e61e2c6253a5/old/ba220236-3234-4a53-9a81-290e4a58489a.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAUBYNJ2KCHUXT2CWL%2F20220913%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20220913T084810Z&X-Amz-Expires=3600&X-Amz-Security-Token=FwoGZXIvYXdzEBoaDM2ObAs%2BHcJfISM%2BOiKbBFOJMuLr%2FBJnAqYnSsDbFvQjfFh1ZlUPsv5aDwcRIUNFMKyH7%2F7g8XveXTPD8CtICednM4T3iPHIwZCRY1FzT9eXIhRn98dxhoqXeoaDKlrE7vIa0hS5tRQl61DArwMwpLO4eH%2F5AoEu66aHaYhrdJQfhQs9ovJOtGKq3N7D5ZaWkwOSfMhOjrLpGly2LeEToHn7a9GWF8FuENiYptFhO3sbb7DLuc69AJM6bWVGOJros2OX0Ghh03YKPO8MGE2YjVWm8TJztdo9lhdPLPh0%2BS4xGqVrQ7vOCU2Pyns3iDyG%2FPMDlVjQNEJKtT1dg1lF%2BCzR7yBQQt0h7YZ8PytMXMhWdnQIdWq0LwOMHKA7OJgFzq00jXW8%2B3KorVoqd85l7Ru8keD2B%2Bloff6A3QYnC4%2FxUbr9agpjQBBrGcxGw6ZCuqDZkXDCJHaSd%2FU7cUNY9LG8UYRuMP941GZ2di3xeOa9k2e9X31dYeG6yNXHxqt5KE5efT0QcCUpVaOXEitjZy1%2Fu078S%2FLoApm2VW73a5M3oqIe3iJSQWzzDhXtoVq%2Fp5og5uWjYEVYN%2B7AkmjpePMXxmVr1xWfNj8AlBEsI03eGvEdpm%2F7uXrI37M9vDOiZWPLNpAU2LLMpi9FhTRcd8A4SHJ5lSrB6WApeb8zQeWaymfGj%2BEsFbvQ5TA6nqvPGTDa40Bi1yUZkGHJ9PDMQrd%2FEVDHFIX7oJKWKMqHgZkGMit%2FEBo21EewKy5le13U%2B64Ul8mD4tUujoTbca5b8cVasBDl%2BgUunvc5%2FrT5&X-Amz-Signature=592dedd290c26edd9c3b7ecdcdbc828faa27d1b59fb7e3f6e34129b8f69065e2&X-Amz-SignedHeaders=host"
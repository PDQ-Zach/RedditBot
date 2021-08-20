# # Input bindings are passed in via param block.
# param($Timer)

# # Get the current universal time in the default string format.
# $currentUTCtime = (Get-Date).ToUniversalTime()

# # The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
# if ($Timer.IsPastDue) {
#     Write-Host "PowerShell timer is running late!"
# }

# # Write an information log with the current time.
# Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

#Set variables
# $resourceGroupName = $env:FUNC_STOR_RGName
# $storageAccountName = $env:FUNC_STOR_ActName
# $tableName = $env:FUNC_STOR_TblName
# $URI = $env:SlackURI
# $channel = $env:channel

# #Store previously viewed articles
# try {
#     $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName `
#         -Name $storageAccountName
#     $storageContext = $storageAccount.Context
#     $cloudTable = (Get-AzStorageTable –Name $tableName –Context $storageContext).CloudTable

#     #Read the items for the sessionID
#     $records = Get-AzTableRow `
#         -table $cloudTable `
#         -PartitionKey "partition1"
# }
# catch {
#     Write-Error "Failure connecting to table for state data, $_"
#     exit
# }

#Subs to get all posts from
$Feeds = @(
    'PDQ',
    'PDQDeploy'   
)
#Keywords to check for in Filtered subs
$Keywords = @(
    'PDQ Deploy'
    'PDQDeploy'
    'PDQ Inventory'
    'PDQInventory'
    'PDQ Link'
    'PDQLink'
    'PDQ.com'
)
#Properties to select when getting comments
$commentProps = @(
'id'
'subreddit'
'subreddit_id'
'body'
'createdUTC'
'permalink'
)
#Properties to select when getting submissions
$SubmissionProps = @(
'id'
'subreddit'
'subreddit_id'
'created_utc'
'selftext'
'title'
'url'
)
#Create an arraylist to store data
$FeedData = [System.Collections.ArrayList]::new()
$PoststoPost = [System.Collections.ArrayList]::new()

#Get keywords from all subreddits
foreach ($Keyword in $Keywords){$FeedData += Search-PushShiftSubmissions -SearchTerms $Keywords | Where-Object Author -ne 'PDQIT'
Start-Sleep 5
}
#Get all new posts from selected subreddits
Foreach ($Feed in $Feeds) {
    $FeedData += Get-PSPushShiftSubmissionsBySub -subreddit $feed
    Start-Sleep 5
}
#Get all comments for all keywords
Foreach ($Keyword in $Keywords) {
    $FeedData += Search-PushShiftComments -SearchTerms $Keyword
    Start-Sleep 5
}

# Foreach ($feed in $FeedData) {
#     If ($records.rowkey -notcontains $feed.id) {
#         $Null = $PoststoPost.Add($feed)
#     }
# }
# If ($PoststoPost.Count -lt 1) {
#     Write-Host "There are no new Reddit posts"
#     exit 0
# }

# $PoststoPost | ForEach-Object {
#     $Title = $_.Title -replace [char]8220 -replace [char]8221
#     $Text = $_.selftext -replace [char]8220 -replace [char]8221
#     $Fields = @{
#         Title     = $Title
#         TitleLink = $_.url
#         Text      = Get-AbbreviatedString -text $text -WordCount 25
#         Pretext   = "New Post from r/$($_.subreddit)"
#         Color     = $([System.Drawing.Color]::Blue) 
#         Fallback  = "New Reddit Post: " + $Title
#     }
        
#     try {
#         New-SlackMessageAttachment @Fields |
#         New-SlackMessage -Channel $channel |
#         Send-SlackMessage -Uri $URI
#         $obj = [pscustomobject]@{
#             ID    = $_.id
#             Title = $title
#         }
#     } 
#     catch {
#         Write-Error "Unable to post to slack.  Error $_" 
#     }
#     try {
#         Add-AzTableRow -Table $cloudTable -property @{"Title" = $obj.title } -RowKey ($obj.ID) -PartitionKey "partition1"
#     }
#     catch {
#         Write-Error "Unable to add to Azure table.  Error $_"
#     }
    
#     Start-Sleep 1
# }





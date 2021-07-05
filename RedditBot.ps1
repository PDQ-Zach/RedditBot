#Load functions
(Get-ChildItem -Path "$PWD\Functions").FullName | ForEach-Object { . $_ }
#Set variables
$resourceGroupName = $env:FUNC_STOR_RGName
$storageAccountName = $env:FUNC_STOR_ActName
$tableName = $env:FUNC_STOR_TblName
$URI = $env:Slack_URI
#Store previously viewed articles
try {
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName `
        -Name $storageAccountName
    $storageContext = $storageAccount.Context
    $cloudTable = (Get-AzStorageTable –Name $tableName –Context $storageContext).CloudTable

    #Read the items for the sessionID
    $records = Get-AzTableRow `
                -table $cloudTable `
                -PartitionKey "Partition1"
}
catch {
    Write-Error "Failure connecting to table for state data, $_"
    exit
}

#Subs to get all posts from
$Feeds = @(
    'PDQ',
    'PDQDeploy'   
)
#Subs to get filtered posts from
$FilterFeeds = @(
    'SysAdmin',
    'Powershell',
    'k12sysadmin' 
)
#Keywords to check for in Filtered subs
$Keywords = @(
    'PDQ',
    'PDQ.com'
)

#Create an arraylist to store data
$FeedData = [System.Collections.ArrayList]::new()
$PoststoPost = [System.Collections.ArrayList]::new()

#Get all new posts from the unfiltered feeds
Foreach ($Feed in $Feeds) {
    $FeedData += Get-RedditPosts -SubName $feed | Select-Object id, URL, title, selftext, subreddit
}

#Get all posts from filtered feeds
Foreach ($Filfeed in $FilterFeeds) {
    $FeedData += Get-RedditPosts -SubName $Filfeed -IncludeKeywords $Keywords | Select-Object id, URL, title, selftext, subreddit
}

Foreach ($feed in $FeedData) {
    If ($records.rowid -notcontains $feed.id) {
        $Null = $PoststoPost.Add($feed)
    }
}
If ($PoststoPost.Count -lt 1) {
    Write-Host "There are no new Reddit posts"
    exit 0
}

$PoststoPost | ForEach-Object {
    $Title = $_.Title -replace [char]8220 -replace [char]8221
    $Text = $_.selftext -replace [char]8220 -replace [char]8221
    $Fields = @{
        Title     = $Title
        TitleLink = $_.url
        Text      = Get-AbbreviatedString -text $text -WordCount 25
        Pretext   = "New Post from r/$($_.subreddit)"
        Color     = $([System.Drawing.Color]::Blue) 
        Fallback  = "New Reddit Post: " + $Title
    }
        
    try {
        New-SlackMessageAttachment @Fields |
        New-SlackMessage -Channel '@reddit-test' |
        Send-SlackMessage -Uri $URI
        $obj = [pscustomobject]@{
            ID    = $_.id
            Title = $title
        } 
        Add-AzTableRow -Table $table -property @{"Title"=$obj.title} -RowKey ($obj.ID) -PartitionKey "partition1"

    }
    catch {
        Write-Error "Unable to complete post or add to table action.  Please validate and try again" 
    }
    Start-Sleep 1
}





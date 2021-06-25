#Load functions
(Get-ChildItem -Path "$PWD\Functions").FullName | ForEach-Object { . $_ }
#Path to redditbot log
$ENV:log = "C:\windows\Temp\RedditBotLogs\RBLog.log"
#Store previously viewed articles
$DataBasePath = ".\RedditBotDB.CSV"
#Subs to get all posts from
$Feeds = @(
    'PDQ',
    'PDQDeploy'   
)
#Subs to get filtered posts from
$FilterFeeds = @(
    'SysAdmin' 
)
#Keywords to check for in Filtered subs
$Keywords = @(
    'PDQ',
    'PDQ.com'
)

#Create an arraylist to store data
$FeedData = [System.Collections.ArrayList]::new()
$PoststoPost = [System.Collections.ArrayList]::new()

#Create the database if it doesn't exist
IF (!(Test-Path -Path $DataBasePath)) { 
    New-Item -Path $DataBasePath
}
#Import CSV data to check against
$DatabaseData = Import-CSV -Path $DataBasePath

#Get all new posts from the unfiltered feeds
Foreach ($Feed in $Feeds) {
    $FeedData += Get-RedditPosts -SubName $feed | Select-Object id, URL, title, selftext, subreddit
}

#Get all posts from filtered feeds
Foreach ($Filfeed in $FilterFeeds) {
    $FeedData += Get-RedditPosts -SubName $Filfeed -IncludeKeywords $Keywords | Select-Object id, URL, title, selftext, subreddit
}

Foreach ($feed in $FeedData) {
    If ($DatabaseData.ID -notcontains $feed.id) {
        $Null = $PoststoPost.Add($feed)
    }
}
If ($PoststoPost.Count -lt 1) {
    Write-Log "There are no new Reddit posts"
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
        $obj | Export-Csv -Path $DataBasePath -Append -NoTypeInformation
    }
    catch {
        "Unable to complete post or add to CSV action.  Please validate and try again" 
    }
    Start-Sleep 1
}





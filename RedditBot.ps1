#Subs to get all posts from
$DataBasePath = ".\RedditBotDB.CSV"
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
    'CentOS',
    'GIGO'
)
#Create an arraylist to store data
$FeedData = [System.Collections.ArrayList]::new()
$PoststoPost = [System.Collections.ArrayList]::new()
#Create the database if it doesn't exist
IF (!(Test-Path -Path $DataBasePath)) { New-Item -Path $DataBasePath}
$DatabaseData = Import-CSV -Path $DataBasePath
#Make get all new posts from the unfiltered feeds
Foreach ($Feed in $Feeds) {
    $FeedData = (Invoke-Restmethod -Method Get -Uri https://www.reddit.com/r/$feed/new.json).data.children.data | 
    Select-Object id, URL, title, selftext
}

Foreach ($Feed in $FilterFeeds) {
    $FilteredFeedData = (Invoke-Restmethod -Method Get -Uri https://www.reddit.com/r/$FilterFeeds/new.json).data.children.data | 
    Select-Object id, URL, title, selftext
}

Foreach ($keyword in $keywords) {
    $FilteredFeedData| Foreach-Object {
        if ($_.title -match $keyword -or $_.selftest -match $keyword) {
            $FeedData += $_
        }
    }
}

Foreach ($feed in $FeedData) {
    If ($DatabaseData.ID -notcontains $feed.id) {
        $Null = $PoststoPost.Add($feed)
    }
}
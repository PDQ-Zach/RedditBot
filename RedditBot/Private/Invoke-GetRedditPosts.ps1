function Invoke-GetRedditPosts {
    param (
        $Subname
    )
    return (Invoke-Restmethod -Method Get -Uri https://www.reddit.com/r/$Subname/new.json).data.children.data
}
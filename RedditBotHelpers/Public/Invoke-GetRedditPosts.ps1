function Invoke-GetRedditPosts {
    param (
        $Subname
    )
    try {
        return (Invoke-Restmethod -Method Get -Uri https://www.reddit.com/r/$Subname/new.json).data.children.data
    }
    catch {
        Write-Error"Unable to return results from Invoke-Restmethod to https://www.reddit.com/r/$Subname/new.json"
        Write-Error "$(Get-Error -Newest 1).exception.message at line $(Get-Error -Newest 1).exception.line"
    }
}

function Get-RedditPosts {
    [CmdletBinding()]
    param (
        [string]$Subname,
        [string[]]$IncludeKeywords,
        [string[]]$ExcludeKeywords
        
    )
    
    begin {
        Write-Log -Verbose "Starting Get-RedditPosts for r/$subname"
        $ReturnPosts = [Collections.Arraylist]::new()
        $Posts = [Collections.Arraylist]::new()
    }
    
    process {
        $Posts += $Subname | ForEach-Object { Invoke-GetRedditPosts -Subname $_ | Where-Object author -NotLike "PDQit" }
            
        If ($posts.count -gt 0) {
            Write-Log "There are $($Posts.count) posts to check"
            if ($MyInvocation.BoundParameters.Keys.contains('IncludeKeywords')) {
                write-host <#"working"$ReturnPosts += Select-ByIncludedKeyword -keywords $IncludeKeywords -Posts $Posts#>; break
            }
            elseif ($MyInvocation.BoundParameters.Keys.contains('ExcludeKeywords')) {
                $ReturnPosts += Select-ByExcludedKeyword -keywords $ExcludeKeywords -Posts $Posts; break
            }
            else {
                return $posts
            }
        }
        else {
            Write-Log -Level Error "No posts were returned, please try again later"
        }
    }
    
    end {
        Write-Log "Get-RedditPosts complete for $subname"
    }
}
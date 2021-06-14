function Get-RedditPosts {
    [CmdletBinding()]
    param (
        [string[]]$SubName,
        [string[]]$keywords
    )
    
    begin {
        Write-Verbose -Message "Running Get-RedditPosts"
        $FilterFeed = [Collections.Arraylist]::new()
    }
    
    process {
        if ($MyInvocation.BoundParameters.Keys.Contains('keywords')) {
            $subname | ForEach-Object {
                $FilterFeed += Invoke-GetRedditPosts -Subname $_
            }
            Foreach ($keyword in $keywords) {
                $FilteredFeedData | Foreach-Object {
                    if ($_.title -match $keyword -or $_.selftest -match $keyword) {
                        return $_
                    }
                }
            }
        }
        else {
            $subname | ForEach-Object {
                return  Invoke-GetRedditPosts -Subname $_
            }
        }   
    }
    
    end {
     
    }
}
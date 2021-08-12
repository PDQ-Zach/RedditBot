
function Get-AbbreviatedString{
    [CmdletBinding()]
    param (
        [string]$text,
        [int]$WordCount
    )
        Write-Host "Starting Get-AbbreviatedString"
        $SplitString = $text -split " " | Select-Object -First $WordCount
        return ($SplitString -join " ") + "..."
        Write-Host "Get-AbbreviatedString complete"
   
}
function Get-RedditPosts {
    [CmdletBinding()]
    param (
        [string]$Subname,
        [string[]]$IncludeKeywords,
        [string[]]$ExcludeKeywords
        
    )
    
    begin {
        Write-Host "Starting Get-RedditPosts for r/$subname"
        $ReturnPosts = [Collections.Arraylist]::new()
        $Posts = [Collections.Arraylist]::new()
    }
    
    process {
        $Posts += $Subname | ForEach-Object { Invoke-GetRedditPosts -Subname $_ | Where-Object author -NotLike "PDQit" }
            
        If ($posts.count -gt 0) {
            Write-Host "There are $($Posts.count) posts to check"
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
            Write-Host "No posts were returned, please try again later"
        }
    }
    
    end {
        Write-Host "Get-RedditPosts complete for $subname"
    }
}
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
function Select-ByExcludedKeyword {
    [CmdletBinding()]
    param (
        $Keywords,
        $Posts
    )
    
    begin {
        Write-Log "Starting Select-ByExcludedKeyword"
    }
    
    process {
        
        Foreach ($keyword in $keywords) {
            $Posts | Foreach-Object {
                if ($_.title -notmatch $keyword -or $_.selftest -notmatch $keyword) {
                    return $_
                }
            }
        }
    }
    
    end {
        Write-Host "Select-ByExcludedKeyword complete"
    }
}
function Select-ByIncludedKeyword {
    [CmdletBinding()]
    param (
        [string[]]$Keywords,
        $Posts
    )
    
    begin {
        Write-Host "Starting Select-ByIncludedKeyword"
    }
    
    process {
        
        Foreach ($keyword in $keywords) {
            $Posts | Foreach-Object {
                if ($_.title -match $keyword -or $_.selftest -match $keyword) {
                    return $_
                }
            }
        }
    }
    
    end {
    Write-Host "Select-ByIncludedKeyword complete"
    }
}


Function Search-PushShiftComments {
    <#
    .SYNOPSIS
        Returns Hello world
    .DESCRIPTION
        Returns Hello world
    .EXAMPLE
        PS> Get-HelloWorld

        Runs the command
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # Parameter description can go here or above in format: .PARAMETER  <Parameter-Name>
        [Parameter()]
        [string[]]$SearchTerms,
        [Int]$NumberofResults = 500,
        $After,
        $Before
    )

    Begin {
        Write-Verbose -Verbose "Starting execution of SearchPushShiftComments"
        If ($SearchTerms.count -gt 1){
            $SearchTerms = $SearchTerms -join '|'
        }
    }

    Process {
        switch ($MyInvocation.BoundParameters.Keys) {
            {[bool]($_ -match 'After')} { $searchTerms += "&after=$After" }
            {[bool]($_ -match 'Before')} { $searchTerms += "&before=$Before" }
            Default {}
        }
        $SearchTerms += "&size=$NumberofResults"
        try {
            $Data = (Invoke-RestMethod -Uri https://api.pushshift.io/reddit/comment/search/?q=$SearchTerms).data
        }
        catch {
            Write-Error "Unable to complete request to PushShift API.  See error below"
            $_
        }
    }

    End {
        return $Data
    }
}

Function Search-PushShiftSubmissions {
    <#
    .SYNOPSIS
        Returns Hello world
    .DESCRIPTION
        Returns Hello world
    .EXAMPLE
        PS> Get-HelloWorld

        Runs the command
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # Parameter description can go here or above in format: .PARAMETER  <Parameter-Name>
        [Parameter()]
        [string[]]$SearchTerms,
        [Int]$NumberofResults = 500,
        $After,
        $Before
    )

    Begin {
        Write-Verbose -Verbose "Starting execution of SearchPushShiftsubmissions"
        Write-Verbose -Verbose "Search terms request are $($SearchTerms -join ',')"

        If ($SearchTerms.count -gt 1){
            $SearchTerms = $SearchTerms -join '|'
        }
    }

    Process {
        switch ($MyInvocation.BoundParameters.Keys) {
            {[bool]($_ -match 'After')} { $searchTerms += "&after=$After" }
            {[bool]($_ -match 'Before')} { $searchTerms += "&before=$Before" }
            Default {}
        }
        $SearchTerms += "&size=$NumberofResults"
        Write-Verbose "Search string is $SearchTerms" -Verbose
        try {
            Write-Verbose "Making request to PushShift API" -Verbose
            $Data = (Invoke-RestMethod -Uri https://api.pushshift.io/reddit/search/submission/?q=$SearchTerms).data
        }
        catch {
            Write-Error "Unable to complete request please see full error details below"
            $_
        }
        
    }

    End {
        return $Data
    }
}


Export-ModuleMember -Function Get-AbbreviatedString, Get-RedditPosts, Invoke-GetRedditPosts, Select-ByExcludedKeyword, Select-ByIncludedKeyword,Search-PushShiftComments,Search-PushShiftSubmissions
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
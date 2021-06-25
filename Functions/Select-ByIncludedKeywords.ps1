function Select-ByIncludedKeyword {
    [CmdletBinding()]
    param (
        [string[]]$Keywords,
        $Posts
    )
    
    begin {
        Write-Log "Starting Select-ByIncludedKeyword"
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
        Write-Log "Select-ByIncludedKeyword complete"
    }
}
function Get-AbbreviatedString{
    [CmdletBinding()]
    param (
        [string]$text,
        [int]$WordCount
    )
        Write-Log "Starting Get-AbbreviatedString"
        $SplitString = $text -split " " | Select-Object -First $WordCount
        return ($SplitString -join " ") + "..."
        Write-Log "Get-AbbreviatedString complete"
   
}
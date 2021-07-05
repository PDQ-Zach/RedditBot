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
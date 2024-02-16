function ApplyFilter {
    Param (
        [Parameter()]
        [PSObject[]]$Items,
        
        [Parameter(Mandatory = $true)]
        [string]$Property,
        
        [string[]]$Name
    )

    if (-not $Name) { return $Items }
            
    # apply property filter
    $filter = @()
    foreach ($name in $Names) { 
        $filter += '$_.' + $Property + '-like "' + $name + '"' 
    }

    $script = [scriptblock]::Create($filter -join ' -or ')
    return $Items | Where-Object $script
}

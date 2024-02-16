function SendItemsToOutput {
    Param
    (
        [Parameter()]
        [PSObject[]]$Items,

        [Parameter(Mandatory = $true)]
        [string[]]$TypeName
    )

    foreach ($i in $Items) {
        $i.PSObject.TypeNames.Insert(0, $TypeName)
        Write-Output $i
    }
}
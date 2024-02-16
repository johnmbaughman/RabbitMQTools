function NamesToString {
    Param
    (
        [string[]]
        $Name,

        [string]
        $AltText = ""
    )

    if (-not $Name) { return $AltText }

    return $Name -join ';'
}
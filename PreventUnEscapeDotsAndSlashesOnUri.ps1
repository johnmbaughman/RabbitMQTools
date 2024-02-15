function GetUriParserFlags
{

    $getSyntax = [System.UriParser].GetMethod("GetSyntax", 40)
    $fieldName = "m_Flags"
    # Handle PowerShell Core and .Net Core
    if (([System.Environment]::Version).Major -gt 4)
    {
        $fieldName = "_flags"
    }
    $flags = [System.UriParser].GetField($fieldName, 36)

    $parser = $getSyntax.Invoke($null, "http")
    return $flags.GetValue($parser)
}

function SetUriParserFlags([int]$newValue)
{
    $getSyntax = [System.UriParser].GetMethod("GetSyntax", 40)
    $fieldName = "m_Flags"
    # Handle PowerShell Core and .Net Core
    if (([System.Environment]::Version).Major -gt 4)
    {
        $fieldName = "_flags"
    }
    $flags = [System.UriParser].GetField($fieldName, 36)
    
    $parser = $getSyntax.Invoke($null, "http")
    $flags.SetValue($parser, $newValue)
}

function PreventUnEscapeDotsAndSlashesOnUri
{
    if (-not $uriUnEscapesDotsAndSlashes) { return }

    Write-Verbose "Switching off UnEscapesDotsAndSlashes flag on UriParser."

    $newValue = $defaultUriParserFlagsValue -bxor $UnEscapeDotsAndSlashes
    
    SetUriParserFlags $newValue
}

function RestoreUriParserFlags
{
    if (-not $uriUnEscapesDotsAndSlashes) { return }

    Write-Verbose "Restoring UriParser flags - switching on UnEscapesDotsAndSlashes flag."

    try
    {
        SetUriParserFlags $defaultUriParserFlagsValue
    }
    catch [System.Exception]
    {
        Write-Error "Failed to restore UriParser flags. This may cause your scripts to behave unexpectedly. You can find more at get-help about_UnEsapingDotsAndSlashes."
        throw
    }
}
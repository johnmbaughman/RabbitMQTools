function NormaliseCredentials() {
    switch ($PSCmdlet.ParameterSetName) {
        "login" { return New-Object -TypeName PSCredential ($UserName, $Password) }
        "cred" { return $Credentials }
    }
}

function ConvertTo-UnsecureString([securestring]$secureString) {
    if ($IsPowerShellCore -and $PowerShellVersionMajor -ge 7) {
        ConvertFrom-SecureString -SecureString $secureString -AsPlainText
    }
    else {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
        $unsecureString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        $unsecureString
    }
}
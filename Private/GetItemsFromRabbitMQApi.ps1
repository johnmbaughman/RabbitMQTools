function GetItemsFromRabbitMQApi {
    [CmdletBinding()]
    Param
    (
        [alias("ComputerName")]
        [string]$HostName = $DefaultHostName,

        [Parameter(Mandatory = $true, ParameterSetName = 'login')]
        [string]$userName,

        [Parameter(Mandatory = $true, ParameterSetName = 'login')]
        [securestring]$Password,

        [Parameter(Mandatory = $true, ParameterSetName = 'cred')]
        [PSCredential]$Credentials = $DefaultCredentials,
        
        [Parameter(Mandatory = $true)]
        [string]$Function,

        [switch]$UseHttps,

        [int]$Port = 15672,

        [switch]$SkipCertificateCheck
    )

    Add-Type -AssemblyName System.Web
    #Add-Type -AssemblyName System.Net
    
    $Credentials = NormaliseCredentials
        
    $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)$($Function)"
    Write-Verbose -Message "Invoking REST API: $url"
    
    return Invoke-RestMethod -Uri $url -Credential $Credentials -DisableKeepAlive:$InvokeRestMethodKeepAlive -SkipCertificateCheck:$SkipCertificateCheck
}
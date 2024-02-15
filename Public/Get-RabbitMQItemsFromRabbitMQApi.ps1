function GetItemsFromRabbitMQApi
{
    [CmdletBinding(DefaultParameterSetName='login')]
    Param
    (
        [parameter(Mandatory=$true, ParameterSetName='login', Position = 0)]
        [string]$cn,

        [parameter(Mandatory=$true, ParameterSetName='login', Position = 1)]
        [string]$userName,

        # TODO: Convert to secure string
        [parameter(Mandatory=$true, ParameterSetName='login', Position = 2)]
        [string]$password,

        [parameter(Mandatory=$true, ParameterSetName='login', Position = 3)]
        [string]$fn,

        [parameter(Mandatory=$true, ParameterSetName='cred', Position = 0)]
        [string]$HostName,

        [parameter(Mandatory=$true, ParameterSetName='cred', Position = 1)]
        [PSCredential]$cred,
        
        [parameter(Mandatory=$true, ParameterSetName='cred', Position = 2)]
        [string]$function,

        [switch]$useHttps,

        [int]$port = 15672,

        [switch]$skipCertificateCheck
    )

    Add-Type -AssemblyName System.Web
    #Add-Type -AssemblyName System.Net
    
    if ($PsCmdlet.ParameterSetName -eq "login") 
    { 
        $HostName = $cn
        $cred = GetRabbitMqCredentials -userName $userName -password $password 
        $function = $fn
    }
        
    $url = "$(Format-BaseUrl -HostName $HostName -port $port -useHttps:$useHttps)$($function)"
    Write-Verbose "Invoking REST API: $url"
    
    return Invoke-RestMethod $url -Credential $cred -DisableKeepAlive:$InvokeRestMethodKeepAlive -SkipCertificateCheck:$skipCertificateCheck
}
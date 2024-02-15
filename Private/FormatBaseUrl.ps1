function Format-BaseUrl {
    [CmdletBinding()]
    param (
        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [string]$HostName,

        # Sets whether to use HTTPS or HTTP
        [switch]$useHttps,

        # The HTTP/API port to connect to. Default is the RabbitMQ default: 15672.
        [int]$port = 15672
    )

    $protocol = "http"
    if ($useHttps) {
        $protocol = "https"        
    }
    return "$($protocol)://$([System.Web.HttpUtility]::UrlEncode($HostName)):$($port)/api/"
}
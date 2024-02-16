function Format-BaseUrl {
    [CmdletBinding()]
    param (
        # Name of the computer hosting RabbitMQ server. Default value is localhost.
        [string]$HostName,

        # Sets whether to use HTTPS or HTTP
        [switch]$UseHttps,

        # The HTTP/API port to connect to. Default is the RabbitMQ default: 15672.
        [int]$Port = 15672
    )

    $protocol = "http"
    if ($UseHttps) {
        $protocol = "https"        
    }
    return "$($protocol)://$([System.Web.HttpUtility]::UrlEncode($HostName)):$($Port)/api/"
}
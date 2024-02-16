<#
.Synopsis
   Removes binding between two RabbitMQ Exchanges.

.DESCRIPTION
   The Remove-RabbitMQExchangeBinding allows for removing bindings between two RabbitMQ exchanges. This cmdlet is marked with High impact.

   To remove Exchange binding from remote server you need to provide -HostName.

   You may pipe an object with names and, optionally, with computer names to remove multiple Exchange bindings. For more information how to do that see Examples.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Remove-RabbitMQExchangeBinding vh1 e1 e2 'e1-e2'

   This command removes binding "e1-e2" between the source exchange named "e1" and destination exchange named "e2". The operation is performed on local server in virtual host vh1.

.EXAMPLE
   Remove-RabbitMQExchangeBinding vh1 e1 e2 'e1-e2' 127.0.0.1

   This command removes binding "e1-e2" between the source exchange named "e1" and destination exchange named "e2". The operation is performed on server 127.0.0.1 in default virtual host (/).

.EXAMPLE
   Remove-RabbitMQExchangeBinding -HostName 127.0.0.0 -VirtualHost vh1 -ExchangeName e1 -Name e2 -RoutingKey 'e1-e2'

   This command removes binding "e1-e2" between the source exchange named "e1" and destination exchange named "e2". The operation is performed on server 127.0.0.1 in default virtual host (/).

.EXAMPLE

.INPUTS

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Remove-RabbitMQExchangeBinding {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param
    (
        # Name of the virtual host.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Alias("vhost")]
        [string]$VirtualHost = $DefaultVirtualHost,

        # Name of RabbitMQ Exchange.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("SourceExchange")]
        [string]$Source,

        # Name of RabbitMQ Exchange.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("TargetExchange")]
        [string]$Destination,

        # Routing key.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("rk")]
        [string]$RoutingKey,

        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("ComputerName")]
        [string]$HostName = $DefaultHostName,

        # Credentials to use when logging to RabbitMQ server.
        [Parameter(Mandatory = $false)]
        [PSCredential]$Credentials = $DefaultCredentials,

        # Sets whether to use HTTPS or HTTP
        [switch]$UseHttps,

        # The HTTP/API port to connect to. Default is the RabbitMQ default: 15672.
        [int]$Port = 15672,

        # Skips the certificate check, useful for localhost and self-signed certificates.
        [switch]$SkipCertificateCheck
    )

    begin {
        $cnt = 0
    }

    process {
        if ($PSCmdlet.ShouldProcess("$HostName/$VirtualHost", "Remove binding between source exchange $ExchangeName and destination exchange $Name")) {
            $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)bindings/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/e/$([System.Web.HttpUtility]::UrlEncode($Source))/e/$([System.Web.HttpUtility]::UrlEncode($Destination))/$([System.Web.HttpUtility]::UrlEncode($RoutingKey))"
            Write-Verbose "Invoking REST API: $url"
        

            Invoke-RestMethod -Uri $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Delete -SkipCertificateCheck:$SkipCertificateCheck

            Write-Verbose "Removed binding between source exchange $ExchangeName and destination exchange $Name $n on $HostName/$VirtualHost"
            $cnt++
        }
    }

    end {
        if ($cnt -gt 1) { Write-Verbose "Unbound $cnt Exchanges." }
    }
}
﻿<#
.Synopsis
   Adds binding between RabbitMQ exchange and queue.

.DESCRIPTION
   The Add-RabbitMQQueueBinding binds RabbitMQ exchange with queue using RoutingKey

   To add QueueBinding to remote server you need to provide -ComputerName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Add-RabbitMQQueueBinding vh1 e1 q1 'e1-q1'

   This command binds exchange "e1" with queue "q1" using routing key "e1-q1". The operation is performed on local server in virtual host vh1.

.EXAMPLE
   Add-RabbitMQQueueBinding '/' e1 q1 'e1-q1' 127.0.01

   This command binds exchange "e1" with queue "q1" using routing key "e1-q1". The operation is performed on server 127.0.0.1 in default virtual host (/).

.INPUTS

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Add-RabbitMQQueueBinding
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param
    (
        # Name of the virtual host.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("vh", "vhost")]
        [string]$VirtualHost = $defaultVirtualhost,

        # Name of RabbitMQ Exchange.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [Alias("exchange")]
        [string]$ExchangeName,

        # Name of RabbitMQ Queue.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=2)]
        [Alias("queue", "QueueName")]
        [string]$Name,

        # Routing key.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=3)]
        [Alias("rk")]
        [string]$RoutingKey,

        # Name/Value pairs of additional queue features
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [hashtable]$Arguments,

        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [parameter(ValueFromPipelineByPropertyName=$true, Position=4)]
        [Alias("HostName", "hn", "cn")]
        [string]$ComputerName = $defaultComputerName,        
        
        # UserName to use when logging to RabbitMq server.
        [Parameter(Mandatory=$true, ParameterSetName='login')]
        [string]$UserName,

        # Password to use when logging to RabbitMq server.
        [Parameter(Mandatory=$true, ParameterSetName='login')]
        [string]$Password,

        # Credentials to use when logging to RabbitMQ server.
        [Parameter(Mandatory=$true, ParameterSetName='cred')]
        [PSCredential]$Credentials,

        # Sets whether to use HTTPS or HTTP
        [switch]$useHttps,

        # The HTTP/API port to connect to. Default is the RabbitMQ default: 15672.
        [int]$port = 15672,

        # Skips the certificate check, useful for localhost and self-signed certificates.
        [switch]$skipCertificateCheck
    )

    Begin
    {
        $Credentials = NormaliseCredentials
        $cnt = 0
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("$ComputerName/$VirtualHost", "Add queue binding from exchange $ExchangeName to queue $Name with routing key $RoutingKey"))
        {
            foreach($n in $Name)
            {
                $url = "$(Format-BaseUrl -ComputerName $ComputerName -port $port -useHttps:$useHttps)bindings/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/e/$([System.Web.HttpUtility]::UrlEncode($ExchangeName))/q/$([System.Web.HttpUtility]::UrlEncode($Name))"
                Write-Verbose "Invoking REST API: $url"

                $body = @{"routing_key" = $RoutingKey}
                if ($Arguments) { $body.Add("arguments", $Arguments) }

                $bodyJson = $body | ConvertTo-Json
                Invoke-RestMethod $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive -ErrorAction Continue -Method Post -ContentType "application/json" -Body $bodyJson -SkipCertificateCheck:$skipCertificateCheck

                Write-Verbose "Bound exchange $ExchangeName to queue $Name $n on $ComputerName/$VirtualHost"
                $cnt++
            }
        }
    }
    End
    {
        Write-Verbose "Created $cnt Binding(s)."
    }
}

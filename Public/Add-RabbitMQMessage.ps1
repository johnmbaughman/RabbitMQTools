<#
.Synopsis
   Gets messages from RabbitMQ Queue.

.DESCRIPTION
   The Add-RabbitMQMessage cmdlet gets messages from RabbitMQ queue.

   The result may be zero, one or many RabbitMQ.Message objects.

   To get Connections from remote server you need to provide -HostName parameter.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Add-RabbitMQMessage vh1 q1

   This command gets first message from queue "q1" on virtual host "vh1".

.EXAMPLE
   Add-RabbitMQMessage test q1 -Count 10

   This command gets first 10 messages from queue "q1" on virtual host "vh1".

.EXAMPLE
   Add-RabbitMQMessage test q1 127.0.0.1

   This command gets first message from queue "q1" on virtual host "vh1", server 127.0.0.1.

.INPUTS

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.QueueMessage objects which describe connections. 

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Add-RabbitMQMessage
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='None')]
    Param
    (
        # Name of the virtual host to filter channels by.
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [Alias("vhost")]
        [string]$VirtualHost = $DefaultVirtualHost,

        # Name of RabbitMQ Exchange.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias("exchange")]
        [string]$ExchangeName,

        # Routing key to be used when publishing message.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias("rk")]
        [string]$RoutingKey,
        
        # Massage's payload
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Payload,

        # Array with message properties.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $Properties,

        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias("ComputerName")]
        [string]$HostName = $DefaultHostName,
        
        
        # UserName to use when logging to RabbitMq server.
        [Parameter(Mandatory=$true, ParameterSetName='login')]
        [string]$UserName,

        # Password to use when logging to RabbitMq server.
        [Parameter(Mandatory=$true, ParameterSetName='login')]
        [securestring]$Password,

        # Credentials to use when logging to RabbitMQ server.
        [Parameter(Mandatory=$true, ParameterSetName='cred')]
        [PSCredential]$Credentials = $DefaultCredentials,

        # Sets whether to use HTTPS or HTTP
        [switch]$UseHttps,

        # The HTTP/API port to connect to. Default is the RabbitMQ default: 15672.
        [int]$Port = 15672,

        # Skips the certificate check, useful for localhost and self-signed certificates.
        [switch]$SkipCertificateCheck
    )

    Begin
    {
        $Credentials = NormaliseCredentials

        if ($null -eq $Properties) { $Properties = @{} }
    }
    
    Process
    {
        if ($PSCmdlet.ShouldProcess("server: $HostName/$VirtualHost", "Publish message to exchange $ExchangeName with routing key $RoutingKey"))
        {
            $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)exchanges/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($ExchangeName))/publish"
            Write-Verbose "Invoking REST API: $url"

            $body = @{
                routing_key = $RoutingKey
                payload_encoding = "string"
                payload = $Payload
                properties = $Properties
            }

            $bodyJson = $body | ConvertTo-Json

            
            $retryCounter = 0

            while ($retryCounter -lt 3)
            {
                $result = Invoke-RestMethod -Uri $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Post -ContentType "application/json" -Body $bodyJson -SkipCertificateCheck:$SkipCertificateCheck

                if ($result.routed -ne $true)
                {
                    Write-Warning "Message was no routed. Operation will be retried. URI: $url"
                    $retryCounter++
                }
                else
                {
                    break
                }
            }
        }
    }

    End
    {
    }
}

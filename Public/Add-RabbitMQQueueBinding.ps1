<#
.Synopsis
   Adds binding between RabbitMQ exchange and queue.

.DESCRIPTION
   The Add-RabbitMQQueueBinding binds RabbitMQ exchange with queue using RoutingKey

   To add QueueBinding to remote server you need to provide -HostName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Add-RabbitMQQueueBinding -VirtualHost vh1 -ExchangeName e1 -Name q1 -RoutingKey 'e1-q1'

   This command binds exchange "e1" with queue "q1" using routing key "e1-q1". The operation is performed on local server in virtual host vh1.

.EXAMPLE
   Add-RabbitMQQueueBinding -VirtualHost '/' -ExchangeName e1 -Name q1 -RoutingKey 'e1-q1' -BaseUri 127.0.0.1

   This command binds exchange "e1" with queue "q1" using routing key "e1-q1". The operation is performed on server 127.0.0.1 in default virtual host (/).

.EXAMPLE
   Add-RabbitMQQueueBinding -VirtualHost '/' -ExchangeName e1 -Name q1 -Headers @{FirstHeaderKey='FirstHeaderValue'; SecondHeaderKey='SecondHeaderValue'} -BaseUri 127.0.0.1

   This command binds exchange "e1" with queue "q1" using the headers argument @{FirstHeaderKey='FirstHeaderValue'; SecondHeaderKey='SecondHeaderValue'}. The operation is performed on server 127.0.0.1 in default virtual host (/).

.EXAMPLE
   Add-RabbitMQExchangeBinding -VirtualHost '/' -DontEscape -ExchangeName e1 -Name q1 -Headers @{rjms_erlang_selector="{'=',{'ident',<<"HeadersPropertyName">>},<<"PropertyValue">>}."} -BaseUri 127.0.0.1

   This command binds exchange "e1" with queue "q1" using the headers argument @{rjms_erlang_selector="{'=',{'ident',<<"HeadersPropertyName">>},<<"PropertyValue">>}."}. The operation is performed on server 127.0.0.1 in default virtual host (/).

   The DontEscape option is required for X-JMS-TOPIC exchanges. The above example will filter for messages which have a header key HeadersPropertyName="PropertyValue".

.INPUTS

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Add-RabbitMQQueueBinding {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
    Param
    (
        # Name of RabbitMQ Exchange.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("exchange")]
        [string]$ExchangeName,

        # Name of the virtual host.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("vhost")]
        [string]$VirtualHost = $DefaultVirtualHost,        

        # Name of RabbitMQ Queue.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("queue")]
        [string]$Name,

        # Routing key.
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'login')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'cred')]        
        [string]$RoutingKey,

        # Headers hashtable
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'login')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'cred')]
        [Hashtable]$Headers = @{},

        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("ComputerName")]
        [string]$HostName = $DefaultHostName,        
        
        # UserName to use when logging to RabbitMq server.
        [Parameter(Mandatory = $true, ParameterSetName = 'login')]
        [string]$UserName,

        # Password to use when logging to RabbitMq server.
        [Parameter(Mandatory = $true, ParameterSetName = 'login')]
        [securestring]$Password,

        # Credentials to use when logging to RabbitMQ server.
        [Parameter(Mandatory = $true, ParameterSetName = 'cred')]
        [PSCredential]$Credentials = $DefaultCredentials,

        # Sets whether to use HTTPS or HTTP
        [switch]$UseHttps,

        # The HTTP/API port to connect to. Default is the RabbitMQ default: 15672.
        [int]$Port = 15672,

        # Skips the certificate check, useful for localhost and self-signed certificates.
        [switch]$SkipCertificateCheck
    )

    Begin {
        $Credentials = NormaliseCredentials
    }

    Process {
        if ($PSCmdlet.ShouldProcess("$HostName/$VirtualHost", "Add queue binding from exchange $ExchangeName to queue $Name with routing key $RoutingKey")) {
            
            $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)bindings/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/e/$([System.Web.HttpUtility]::UrlEncode($ExchangeName))/q/$([System.Web.HttpUtility]::UrlEncode($Name))"
            Write-Verbose "Invoking REST API: $url"

            $body = @{
                "routing_key" = $RoutingKey
                "arguments"   = $headers
            }

            $bodyJson = $body | ConvertTo-Json
            Write-Verbose $bodyJson

            Invoke-RestMethod -Uri $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Post -ContentType "application/json" -Body $bodyJson -SkipCertificateCheck:$SkipCertificateCheck

            Write-Verbose "Bound exchange $ExchangeName to queue $N on $HostName/$VirtualHost"         
        }
    }
    
    End {
        Write-Verbose "Created binding."
    }
}

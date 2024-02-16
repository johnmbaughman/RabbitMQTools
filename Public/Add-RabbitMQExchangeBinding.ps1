<#
.Synopsis
   Adds binding between RabbitMQ exchange and exchange.

.DESCRIPTION
   The Add-RabbitMQExchangeBinding binds RabbitMQ exchange with exchange using RoutingKey

   To add ExchangeBinding to remote server you need to provide -HostName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Add-RabbitMQExchangeBinding -VirtualHost vh1 -ExchangeName e1 -Name e2 -RoutingKey 'e1-e2'

   This command binds exchange "e1" with exchange "e2" using routing key "e1-e2". The operation is performed on local server in virtual host vh1.

.EXAMPLE
   Add-RabbitMQExchangeBinding -VirtualHost '/' -ExchangeName e1 -Name e2 -RoutingKey 'e1-e2' -BaseUri 127.0.0.1

   This command binds exchange "e1" with exchange "e2" using routing key "e1-e2". The operation is performed on server 127.0.0.1 in default virtual host (/).

.EXAMPLE
   Add-RabbitMQExchangeBinding -VirtualHost '/' -ExchangeName e1 -Name e2 -Headers @{FirstHeaderKey='FirstHeaderValue'; SecondHeaderKey='SecondHeaderValue'} -BaseUri 127.0.0.1

   This command binds exchange "e1" with exchange "e2" using the headers argument @{FirstHeaderKey='FirstHeaderValue'; SecondHeaderKey='SecondHeaderValue'}. The operation is performed on server 127.0.0.1 in default virtual host (/).

.EXAMPLE
   Add-RabbitMQExchangeBinding -VirtualHost '/' -DontEscape -ExchangeName e1 -Name e2 -Headers @{rjms_erlang_selector="{'=',{'ident',<<"HeadersPropertyName">>},<<"PropertyValue">>}."} -BaseUri 127.0.0.1

   This command binds exchange "e1" with exchange "e2" using the headers argument @{rjms_erlang_selector="{'=',{'ident',<<"HeadersPropertyName">>},<<"PropertyValue">>}."}. The operation is performed on server 127.0.0.1 in default virtual host (/).

   The DontEscape option is required for X-JMS-TOPIC exchanges. The above example will filter for messages which have a header key HeadersPropertyName="PropertyValue".

.INPUTS

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Add-RabbitMQExchangeBinding {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
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
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'login')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'cred')]
        [string]$RoutingKey,

        # Headers hashtable
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'login')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'cred')]
        [Hashtable]$Headers = @{},

        # Name of the computer hosting RabbitMQ server. Default value is localhost.
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
        if ($PSCmdlet.ShouldProcess("$HostName/$VirtualHost", "Add exchange binding from exchange $Source to exchange $Destination with $($PSCmdlet.ParameterSetName)")) {
            
            $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)bindings/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/e/$([System.Web.HttpUtility]::UrlEncode($Source))/e/$([System.Web.HttpUtility]::UrlEncode($Destination))"
            Write-Verbose "Invoking REST API: $url"

            $body = @{
                "routing_key" = $RoutingKey
                "arguments"   = $headers
            }

            $bodyJson = $body | ConvertTo-Json -Depth 3 -Compress
            Invoke-RestMethod -Uri $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Post -ContentType "application/json" -Body $bodyJson  -SkipCertificateCheck:$SkipCertificateCheck

            Write-Verbose "Bound exchange $Source to exchange $Destination on $HostName/$VirtualHost"
            $cnt++
        }
    }

    End {
        Write-Verbose "Created binding."
    }
}
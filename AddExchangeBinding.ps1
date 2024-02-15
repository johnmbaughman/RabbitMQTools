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
function Add-RabbitMQExchangeBinding
{
    [CmdletBinding(DefaultParameterSetName='RoutingKey', SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param
    (
        # Name of the virtual host.
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("vh", "vhost")]
        [string]$VirtualHost = $defaultVirtualhost,

        # Name of RabbitMQ Exchange.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [Alias("exchange", "source")]
        [string]$ExchangeName,

        # Name of RabbitMQ Exchange.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=2)]
        [Alias("targetexchange", "TargetExchangeName", "destination")]
        [string]$Name,

        # Routing key.
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=3, ParameterSetName='RoutingKey')]
        [Alias("rk", "routing_key")]
        [string]$RoutingKey,

        # Headers hashtable
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=3, ParameterSetName='Headers')]
        [Hashtable]$Headers = @{},

        # Name of the computer hosting RabbitMQ server. Default value is localhost.
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
        [Parameter(Mandatory=$false)]
        [PSCredential]$Credentials = $defaultCredentials,

        # Sets whether to use HTTPS or HTTP
        [switch]$useHttps,

        # The HTTP/API port to connect to. Default is the RabbitMQ default: 15672.
        [int]$port = 15672,

        # Skips the certificate check, useful for localhost and self-signed certificates.
        [switch]$skipCertificateCheck
    )

    Begin
    {
        $cnt = 0
    }
    
    Process
    {
        if ($pscmdlet.ShouldProcess("$ComputerName/$VirtualHost", "Add exchange binding from exchange $ExchangeName to exchange $Name with $($PSCmdlet.ParameterSetName)"))
        {
            foreach($n in $Name)
            {
                $url = "$(Format-BaseUrl -ComputerName $ComputerName -port -useHttps:$useHttps)bindings/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/e/$([System.Web.HttpUtility]::UrlEncode($ExchangeName))/e/$([System.Web.HttpUtility]::UrlEncode($Name))"
                Write-Verbose "Invoking REST API: $url"

                $body = @{
                    "routing_key" = $RoutingKey
		            "arguments" = $headers
                }

                $bodyJson = $body | ConvertTo-Json -Depth 3 -Compress
				Invoke-RestMethod $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Post -ContentType "application/json" -Body $bodyJson  -SkipCertificateCheck:$skipCertificateCheck

                Write-Verbose "Bound exchange $ExchangeName to exchange $Name $n on $ComputerName/$VirtualHost"
                $cnt++
            }
        }
    }

    End
    {
        Write-Verbose "Created $cnt Binding(s)."
    }
}
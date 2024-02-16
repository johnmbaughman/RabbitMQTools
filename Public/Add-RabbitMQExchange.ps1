<#
.Synopsis
   Adds Exchange to RabbitMQ server.

.DESCRIPTION
   The Add-RabbitMQExchange allows for creating new Exchanges in given RabbitMQ server.

   To add Exchange to remote server you need to provide -HostName

   You may pipe an object with names and parameters, including HostName, to create multiple Exchanges. For more information how to do that see Examples.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Add-RabbitMQExchange -Type direct TestExchange

   Creates direct exchange named TestExchange in the local RabbitMQ server.

.EXAMPLE
   Add-RabbitMQExchange -Type direct TestExchange -Durable -AutoDelete -Internal -AlternateExchange e2

   Creates direct exchange named TestExchange in the local RabbitMQ server and sets its properties to be Durable, AutoDelete, Internal and to use alternate exchange called e2.

.EXAMPLE
   Add-RabbitMQExchange -Type fanout TestExchange, ProdExchange

      Creates in the local RabbitMQ server two fanout exchanges named TestExchange and ProdExchange.

.EXAMPLE
   Add-RabbitMQExchange -Type direct TestExchange -HostName myrabbitmq.servers.com

   Creates direct exchange named TestExchange in the myrabbitmq.servers.com server.

.EXAMPLE
   @("e1", "e2") | Add-RabbitMQExchange -Type direct

   This command pipes list of exchanges to add to the RabbitMQ server. In the above example two new Exchanges named "e1" and "e2" will be created in local RabbitMQ server.

.EXAMPLE
    $a = $(
        New-Object -TypeName psobject -Prop @{"HostName" = "localhost"; "Name" = "e1", "Type"="direct"}
        New-Object -TypeName psobject -Prop @{"HostName" = "localhost"; "Name" = "e2", "Type"="fanout"}
        New-Object -TypeName psobject -Prop @{"HostName" = "127.0.0.1"; "Name" = "e3", "Type"="topic", Durable=$true, $Internal=$true}
    )

   $a | Add-RabbitMQExchange

   Above example shows how to pipe parameters for creating new exchanges.
   
   In the above example three new exchanges will be created with different parameters.

.INPUTS
   You can pipe Name, Type, Durable, AutoDelete, Internal, AlternateExchange, VirtualHost and HostName to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Add-RabbitMQExchange {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param
    (
        # Name of RabbitMQ Exchange.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Exchange")]
        [string[]]$Name,

        # Type of the Exchange to create.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("topic", "fanout", "direct", "headers")]
        [string]$Type,

        # Determines whether the exchange should be Durable.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]$Durable,
        
        # Determines whether the exchange will be deleted once all queues have finished using it.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]$AutoDelete,
        
        # Determines whether the exchange should be Internal.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]$Internal,

        # Allows to set alternate exchange to which all messages which cannot be routed will be send.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("alt")]
        [string]$AlternateExchange,

        # Name of RabbitMQ Virtual Host.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("vhost")]
        [string]$VirtualHost = $DefaultVirtualHost,

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

    begin {
        $Credentials = NormaliseCredentials
    }

    process {
        if ($PSCmdlet.ShouldProcess("server: $HostName, vhost: $VirtualHost", "Add exchange(s): $(NamesToString -Name $Name -AltText '(all)')")) {
            
            $body = @{ type = $Type }

            if ($Durable) { $body.Add("durable", $true) }
            if ($AutoDelete) { $body.Add("auto_delete", $true) }
            if ($Internal) { $body.Add("internal", $true) }
            if ($AlternateExchange) { $body.Add("arguments", @{ "alternate-exchange" = $AlternateExchange }) }

            $bodyJson = $body | ConvertTo-Json

            foreach ($n in $Name) {
                $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)exchanges/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($n))"
                Write-Verbose -Message "Invoking REST API: $url"
        
                Invoke-RestMethod -Uri $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Put -ContentType "application/json" -Body $bodyJson -SkipCertificateCheck:$SkipCertificateCheck

                Write-Verbose -Message "Created Exchange $n on server $HostName, Virtual Host $VirtualHost"
                $cnt++
            }
        }
    }
    
    end {
        if ($cnt -gt 1) { Write-Verbose -Message "Created $cnt Exchange(s)." }
    }
}

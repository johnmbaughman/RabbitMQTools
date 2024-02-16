<#
.Synopsis
   Removes Exchange from RabbitMQ server.

.DESCRIPTION
   The Remove-RabbitMQExchange allows for removing exchanges in given RabbitMQ server. This cmdlet is marked with High impact.

   To remove Exchange from remote server you need to provide -HostName.

   You may pipe an object with names and, optionally, with computer names to remove multiple Exchanges. For more information how to do that see Examples.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Remove-RabbitMQExchange test

   This command removes Exchange named "test" from local RabbitMQ server.

.EXAMPLE
   Remove-RabbitMQExchange e1, e2

   This command removes Exchanges named "e1" and "e2" from local RabbitMQ server.

.EXAMPLE
   Remove-RabbitMQExchange test -HostName myrabbitmq.servers.com

   This command removes Exchange named "test" from myrabbitmq.servers.com server.

.EXAMPLE
   @("e1", "e2") | Remove-RabbitMQExchange

   This command pipes list of Exchanges to be removed from the RabbitMQ server. In the above example two Exchanges named "e1" and "e2" will be removed from local RabbitMQ server.

.EXAMPLE
    $a = $(
        New-Object -TypeName psobject -Prop @{"HostName" = "localhost"; "Name" = "e1"}
        New-Object -TypeName psobject -Prop @{"HostName" = "localhost"; "Name" = "e2"}
        New-Object -TypeName psobject -Prop @{"HostName" = "127.0.0.1"; "Name" = "e3"}
    )


   $a | Remove-RabbitMQExchange

   Above example shows how to pipe both Exchange name and Computer Name to specify server from which the Exchange should be removed.
   
   In the above example two Exchanges named "e1" and "e2" will be removed from RabbitMQ local server, and one Exchange named "e3" will be removed from the server 127.0.0.1.

.INPUTS
   You can pipe Exchange names and optionally HostNames to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Remove-RabbitMQExchange {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param
    (
        # Name of RabbitMQ Exchange.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Exchange")]
        [string[]]$Name,

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
        $cnt = 0
    }
    process {
        if ($PSCmdlet.ShouldProcess("server: $HostName, vhost: $VirtualHost", "Remove exchange(s): $(NamesToString -Name $Name -AltText '(all)')")) {
            foreach ($n in $Name) {
                $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)exchanges/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($n))"
        
                Invoke-RestMethod -Uri $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Delete -SkipCertificateCheck:$SkipCertificateCheck

                Write-Verbose "Deleted Exchange $n on server $HostName, Virtual Host $VirtualHost"
                $cnt++
            }
        }
    }
    end {
        if ($cnt -gt 1) { Write-Verbose "Deleted $cnt Exchange(s)." }
    }
}

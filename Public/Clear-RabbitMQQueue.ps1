<#
.Synopsis
   Purges all messages from RabbitMQ Queue.

.DESCRIPTION
    The Clear-RabbitMQQueue removes all messages from given RabbitMQ queue.

   To remove message from Queue on remote server you need to provide -HostName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Clear-RabbitMQQueue vh1 q1

   Removes all messages from queue "q1" in Virtual Host "vh1" on local computer.

.EXAMPLE
   Clear-RabbitMQQueue -VirtualHost vh1 -Name q1

   Removes all messages from queue "q1" in Virtual Host "vh1" on local computer.

.EXAMPLE
   Clear-RabbitMQQueue -VirtualHost vh1 -Name q1 -HostName rabbitmq.server.com

   Removes all messages from queue "q1" in Virtual Host "vh1" on "rabbitmq.server.com" server.
#>
function Clear-RabbitMQQueue {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param
    (
        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("ComputerName")]
        [string]$HostName = $DefaultHostName,

        # The name of the queue from which to receive messages
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("queue")]
        [string]$Name,        
        
        # Name of RabbitMQ Virtual Host.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Alias("vhost")]
        [string]$VirtualHost = $DefaultVirtualHost,        
        
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
        if ($PSCmdlet.ShouldProcess("server: $HostName/$VirtualHost", "purge queue $Name")) {
            $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)queues/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($Name))/contents"
            Write-Verbose "Invoking REST API: $url"

            Invoke-RestMethod -Uri $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Delete -SkipCertificateCheck:$SkipCertificateCheck
        }
    }

    end {
    }
}

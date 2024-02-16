<#
.Synopsis
   Adds Queue to RabbitMQ server.

.DESCRIPTION
   The Add-RabbitMQQueue allows for creating new queues in RabbitMQ server.

   To add Queue to remote server you need to provide -HostName.

   You may pipe an object with Name, Queue parameters, VirtualHost and HostName to create multiple queues. For more information how to do that see Examples.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Add-RabbitMQQueue queue1

   This command adds new Queue named "queue1" to local RabbitMQ server.

.EXAMPLE
   Add-RabbitMQQueue queue1, queue2

   This command adds two new queues named "queue1" and "queue2" to local RabbitMQ server.

.EXAMPLE
   Add-RabbitMQQueue queue1 -HostName myrabbitmq.servers.com

   This command adds new queue named "queue1" to myrabbitmq.servers.com server.

.EXAMPLE
   @("queue1", "queue2") | Add-RabbitMQQueue

   This command pipes list of Queues to add to the RabbitMQ server. In the above example two new queues named "queue1" and "queue2" will be created in local RabbitMQ server.

.EXAMPLE
    $a = $(
        New-Object -TypeName psobject -Prop @{"HostName" = "localhost"; "Name" = "vh1"}
        New-Object -TypeName psobject -Prop @{"HostName" = "localhost"; "Name" = "vh2"}
        New-Object -TypeName psobject -Prop @{"HostName" = "127.0.0.1"; "Name" = "vh3"}
    )


   $a | Add-RabbitMQQueue

   Above example shows how to pipe queue definitions to Add-RabbitMQQueue cmdlet.

.EXAMPLE
   Add-RabbitMQQueue -Name 'queue-with-ttl' -Arguments @{'x-message-ttl' = 60000}

   This command will create a new queue and set message TTL to 60 seconds.

.INPUTS
   You can pipe VirtualHost names and optionally HostNames to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Add-RabbitMQQueue
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
    Param
    (
        # Name of RabbitMQ Queue.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("queue")]
        [string[]]$Name,

        # Name of the virtual host to filter channels by.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Alias("vhost")]
        [string]$VirtualHost = $DefaultVirtualHost,

        # Determines whether the queue should be durable.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]$Durable = $false,
        
        # Determines whether the queue should be deleted automatically after all consumers have finished using it.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]$AutoDelete = $false,

        # Name/Value pairs of additional queue features
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [hashtable]$Arguments,

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

    Begin
    {
        $Credentials = NormaliseCredentials
        $cnt = 0
    }
    
    Process
    {
        if ($PSCmdlet.ShouldProcess("server: $HostName/$VirtualHost", "Add queue(s): $(NamesToString -Name $Name -AltText '(all)'); Durable=$Durable, AutoDelete=$AutoDelete"))
        {
            foreach($n in $Name)
            {
                $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)queues/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($n))"
                Write-Verbose "Invoking REST API: $url"

                $body = @{}
                if ($Durable) { $body.Add("durable", $true) }
                if ($AutoDelete) { $body.Add("auto_delete", $true) }
                if ($Arguments -ne $null -and $Arguments.Count -gt 0) { $body.Add("arguments", $Arguments) }

                $bodyJson = $body | ConvertTo-Json
                Invoke-RestMethod -Uri $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Put -ContentType "application/json" -Body $bodyJson -SkipCertificateCheck:$SkipCertificateCheck

                Write-Verbose "Created Queue $n on $HostName/$VirtualHost"
                $cnt++
            }
        }
    }

    End
    {
        Write-Verbose "Created $cnt Queue(s)."
    }
}

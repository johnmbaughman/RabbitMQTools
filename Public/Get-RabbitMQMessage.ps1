<#
.Synopsis
   Gets messages from RabbitMQ Queue.

.DESCRIPTION
   The Get-RabbitMQMessage cmdlet gets messages from RabbitMQ queue.

   The result may be zero, one or many RabbitMQ.Message objects.

   To get Connections from remote server you need to provide -HostName parameter.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Get-RabbitMQMessage vh1 q1

   This command gets first message from queue "q1" on virtual host "vh1".

.EXAMPLE
   Get-RabbitMQMessage test q1 -Count 10

   This command gets first 10 messages from queue "q1" on virtual host "vh1".

.EXAMPLE
   Get-RabbitMQMessage test q1 127.0.0.1

   This command gets first message from queue "q1" on virtual host "vh1", server 127.0.0.1.

.INPUTS

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.QueueMessage objects which describe connections. 

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Get-RabbitMQMessage {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'None')]
    Param
    (
        # Name of RabbitMQ Queue.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("queue")]
        [string]$Name,

        # Name of the virtual host to filter channels by.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("vhost")]
        [string]$VirtualHost,
        
        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("ComputerName")]
        [string]$HostName = $DefaultHostName,

        # Number of messages to get. Default value is 1.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [int]$Count = 1,

        # Indicates whether messages should be removed from the queue. Default setting is to not remove messages.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]$Remove,

        # Determines message body encoding.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("auto", "base64")]
        [string]$Encoding = "auto",

        # Indicates whether messages body should be truncated to given size (in bytes).
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [int]$Truncate,

        # Indicates what view should be used to present the data.
        [ValidateSet("Default", "Payload", "Details")]
        [string]$View = "Default",        
        
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
        if (-not $VirtualHost) {
            # figure out the Virtual Host value
            $p = @{}
            $p.Add("Credentials", $Credentials)
            if ($HostName) { $p.Add("HostName", $HostName) }
            
            $queues = Get-RabbitMQQueue @p | Where-Object Name -EQ $Name

            if (-not $queues) { return; }

            if (-not $queues.GetType().IsArray) {
                $VirtualHost = $queues.vhost
            }
            else {
                $vhosts = $queues | Select-Object vhost
                $s = $vhosts -join ','
                Write-Error "Queue $Name exists in multiple Virtual Hosts: $($queues.vhost -join ', '). Please specify Virtual Host to use."
            }
        }


        [string]$s = ""
        if ([bool]$Remove) { $s = "Messages will be removed from the queue." } else { $s = "Messages will be requeued." }
        if ($PSCmdlet.ShouldProcess("server: $HostName/$VirtualHost", "Get $Count message(s) from queue $Name. $s")) {
            $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)queues/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($Name))/get"
            Write-Verbose "Invoking REST API: $url"

            $body = @{
                "count"    = $Count
                "requeue"  = -not [bool]$Remove
                "encoding" = $Encoding
                "ackmode"  = @("ack_requeue_true", "ack_requeue_false")[[bool]$Remove]
            }
            if ($Truncate) { $body.Add("truncate", $Truncate) }

            $bodyJson = $body | ConvertTo-Json

            Write-Debug "body: $bodyJson"

            $result = Invoke-RestMethod -Uri $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Post -ContentType "application/json" -Body $bodyJson -SkipCertificateCheck:$SkipCertificateCheck

            $result | Add-Member -NotePropertyName "QueueName" -NotePropertyValue $Name

            foreach ($item in $result) {
                $cnt++
                $item | Add-Member -NotePropertyName "no" -NotePropertyValue $cnt
                $item | Add-Member -NotePropertyName "HostName" -NotePropertyValue $HostName
                $item | Add-Member -NotePropertyName "VirtualHost" -NotePropertyValue $VirtualHost
            }

            if ($View) {
                switch ($View.ToLower()) {
                    'payload' {
                        SendItemsToOutput -Items $result -TypeName "RabbitMQ.QueueMessage" | Format-Custom
                    }

                    'details' {
                        SendItemsToOutput -Items $result -TypeName "RabbitMQ.QueueMessage" | Format-Table -View Details
                    }
                    
                    Default { SendItemsToOutput -Items $result -TypeName "RabbitMQ.QueueMessage" }
                }
            }
        }
    }
    end {
        Write-Verbose "`r`nGot $cnt messages from queue $Name, vhost $VirtualHost, server: $HostName."
    }
}


﻿<#
.Synopsis
   Copies messages from one RabbitMQ Queue to another.

.DESCRIPTION
   The Copy-RabbitMQMessage cmdlet allows to copy messages from one RabbitMQ queue to another.
   Both source and destination queues must be in the same Virtual Host.
   The "exchange" and "routing_key" properties on copied messages will ba changed.

   Copying messages is done by creating new exchange, binding both from and to queues to it and republishing messages from source queue. 
   
   The cmdlet is not designed to be used on sensitive data.

   WARNING
     This operation is not transactional and may result in not all messages being copied or some messages being duplicated. 
     Also, if there are new messages published to the source queue or messages are consumed, then the operation may fail with unexpected result.
     Because of the nature of copying messages, this operation may change order of messages in the source queue.
     

   To copy messages on remote server you need to provide -HostName parameter.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Copy-RabbitMQMessage vh1 q1 q2

   Copy all messages from q1 to q2 on Virtual Host vh1.

.EXAMPLE
   Copy-RabbitMQMessage vh1 q1 q2 5

   Copy first 5 messages from q1 to q2 on Virtual Host vh1.

.EXAMPLE
   Copy-RabbitMQMessage -VirtualHost vh1 -$SourceQueueName q1 -$DestinationQueueName q2 -Count 5

   Copy first 5 messages from q1 to q2 on Virtual Host vh1.

.INPUTS

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.QueueMessage objects which describe connections. 

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Copy-RabbitMQMessage {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param
    (
        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias("ComputerName")]
        [string]$HostName = $DefaultHostName,        

        # Name of RabbitMQ Queue from which messages should be copied.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("from", "fromQueue")]
        [string]$SourceQueueName,
      
        # Name of RabbitMQ Queue to which messages should be copied.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("to", "toQueue")]
        [string]$DestinationQueueName,

        # Name of the virtual host to filter channels by.
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Alias("vhost")]
        [string]$VirtualHost = $DefaultVirtualHost,

        # If specified, gives the number of messages to copy.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [int]$Count,                
        
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
        $requiresMessageRemoval = $SourceQueueName -ne $DestinationQueueName
    }
    
    process {
        $s = @{$true = $Count; $false = 'all' }[$Count -gt 0]
        if ($PSCmdlet.ShouldProcess("server: $HostName/$VirtualHost", "Copy $s messages from queue $SourceQueueName to queue $DestinationQueueName.")) {
            $ename = "RabbitMQTools_copy"
            $routingKey = "RabbitMQTools_copy"
            Add-RabbitMQExchange -HostName $HostName -VirtualHost $VirtualHost -Type fanout -AutoDelete -Name $ename -Credentials $Credentials -port $Port -UseHttps:$UseHttps -SkipCertificateCheck:$SkipCertificateCheck
            Add-RabbitMQQueueBinding -HostName $HostName -VirtualHost $VirtualHost -ExchangeName $ename -Name $SourceQueueName  -RoutingKey $routingKey -Credentials $Credentials -port $Port -UseHttps:$UseHttps -SkipCertificateCheck:$SkipCertificateCheck
            Add-RabbitMQQueueBinding -HostName $HostName -VirtualHost $VirtualHost -ExchangeName $ename -Name $DestinationQueueName -RoutingKey $routingKey -Credentials $Credentials -port $Port -UseHttps:$UseHttps -SkipCertificateCheck:$SkipCertificateCheck

            try {
                $m = Get-RabbitMQMessage -Credentials $Credentials -HostName $HostName -VirtualHost $VirtualHost -Name $SourceQueueName -port $Port -UseHttps:$UseHttps -SkipCertificateCheck:$SkipCertificateCheck
                $c = $m.message_count + 1

                if ($Count -eq 0 -or $Count -gt $c ) { $Count = $c }
                Write-Verbose "There are $Count messages to be copied."

                for ($i = 1; $i -le $Count; $i++) {
                    # get message to be copies, but do not remove it from the server yet.
                    $m = Get-RabbitMQMessage -Credentials $Credentials -HostName $HostName -VirtualHost $VirtualHost -Name $SourceQueueName -port $Port -UseHttps:$UseHttps -SkipCertificateCheck:$SkipCertificateCheck

                    # publish message to copying exchange, this will publish it onto dest queue as well as src queue.
                    Add-RabbitMQMessage -Credentials $Credentials -HostName $HostName -VirtualHost $VirtualHost -ExchangeName $ename -RoutingKey $routingKey -Payload $m.payload -Properties $m.properties -port $Port -UseHttps:$UseHttps -SkipCertificateCheck:$SkipCertificateCheck

                    # remove message from src queue. It has been published step earlier.
                    if ($requiresMessageRemoval) { $m = Get-RabbitMQMessage -Credentials $Credentials -HostName $HostName -VirtualHost $VirtualHost -Name $SourceQueueName -Remove -port $Port -UseHttps:$UseHttps -SkipCertificateCheck:$SkipCertificateCheck }

                    [int]$p = ($i * 100) / $Count
                    if ($p -gt 100) { $p = 100 }
                    Write-Progress -Activity "Copying messages from $SourceQueueName to $DestinationQueueName" -Status "Copying message $i out of $Count" -PercentComplete $p

                    Write-Verbose "published message $i out of $Count"
                    $cnt++
                }
            }
            finally {
                Remove-RabbitMQExchange -Credentials $Credentials -HostName $HostName -VirtualHost $VirtualHost -Name $ename -Confirm:$false -port $Port -UseHttps:$UseHttps -SkipCertificateCheck:$SkipCertificateCheck
            }
        }
    }

    end {
        Write-Verbose "`r`nCopied $cnt messages from queue $SourceQueueName to queue $DestinationQueueName."
    }
}

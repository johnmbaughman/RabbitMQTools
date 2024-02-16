<#
.Synopsis
   Gets bindings for given RabbitMQ Queue.

.DESCRIPTION
   The Get-RabbitMQQueueBinding cmdlet gets bindings for given RabbitMQ Queue.

   The cmdlet allows you to show all Bindings for given RabbitMQ Queue.
   The result may be zero, one or many RabbitMQ.Connection objects.

   To get Connections from remote server you need to provide -HostName parameter.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Get-RabbitMQQueueBinding vh1 q1

   This command gets a list of bindings for queue named "q1" on virtual host "vh1".

.EXAMPLE
   Get-RabbitMQQueueBinding -VirtualHost vh1 -Name q1 -HostName myrabbitmq.servers.com

   This command gets a list of bindings for queue named "q1" on virtual host "vh1" and server myrabbitmq.servers.com.

.EXAMPLE
   Get-RabbitMQQueueBinding vh1 q1,q2,q3

   This command gets a list of bindings for queues named "q1", "q2" and "q3" on virtual host "vh1".

.INPUTS
   You can pipe Name, VirtualHost and HostName to this cmdlet.

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.QueueBinding objects which describe connections. 

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Get-RabbitMQQueueBinding {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'None')]
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
                Write-Error "Queue $Name exists in multiple Virtual Hosts: $($queues.vhost -join ', '). Please specify Virtual Host to use."
            }
        }

        # TODO: Revisit to get Exchange bindings
        if ($PSCmdlet.ShouldProcess("server $HostName", "Get bindings for queue(s): $(NamesToString -Name $Name -AltText '(all)')")) {
            foreach ($n in $Name) {
                $result = GetItemsFromRabbitMQApi -HostName $HostName -Credentials $Credentials -Function "queues/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($n))/bindings" -UseHttps:$UseHttps -port:$Port -SkipCertificateCheck:$SkipCertificateCheck

                $result | Add-Member -NotePropertyName "HostName" -NotePropertyValue $HostName

                SendItemsToOutput -Items $result -TypeName "RabbitMQ.QueueBinding"
            }
        }
    }
    
    end {
    }
}


# > Get-RabbitMQQueueBinding -Credentials $creds -UseHttps -SkipCertificateCheck -Name "PSQueue"
# Invoke-RestMethod: C:\Personal\source\repos\RabbitMQTools\Private\GetItemsFromRabbitMQApi.ps1:35
# Line |
#   35 |      return Invoke-RestMethod -Uri $url -Credential $Credentials -Disa …
#      |             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#      | Received an invalid status line: '§♥☺☻☻'.
# Add-Member: C:\Personal\source\repos\RabbitMQTools\Public\Get-RabbitMQQueue.ps1:128
# Line |
#  128 |  …   $result | Add-Member -NotePropertyName "HostName" -NotePropertyValu …
#      |                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#      | Cannot bind argument to parameter 'InputObject' because it is null.
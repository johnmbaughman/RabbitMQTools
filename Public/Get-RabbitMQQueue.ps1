<#
.Synopsis
   Gets open RabbitMQ Channels.

.DESCRIPTION
   The Get-RabbitMQQueue cmdlet gets queues registered with RabbitMQ server.

   The cmdlet allows you to show list of all queues or filter them by name using wildcards.
   The result may be zero, one or many RabbitMQ.Queue objects.

   To get Queues from remote server you need to provide -HostName parameter.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Get-RabbitMQQueue

   This command gets a list of all queues reigsters with local RabbitMQ server.

.EXAMPLE
   Get-RabbitMQQueue -HostName myrabbitmq.servers.com

   This command gets a list of all queues registerd with myrabbitmq.servers.com server.

.EXAMPLE
   Get-RabbitMQQueue services*

   This command gets a list of all queues which name starts with "services".

.EXAMPLE
   Get-RabbitMQQueue -VirtualHost vhost1

   This command gets a list of all queues in Virtual Host "vhost1".

.EXAMPLE
   Get-RabbitMQQueue -NotEmpty

   This command gets a list of all queues having messages.

.EXAMPLE
   Get-RabbitMQQueue -ShowStats

   This command shows queue statistics.
   It is equivalent to running Get-RabbitMQQueue | Format-Table -View Stats

.EXAMPLE
   @("services*", "posion*") | Get-RabbitMQQueue

   This command pipes queue name filters to Get-RabbitMQQueue cmdlet.

.INPUTS
   You can pipe queue Name, VirtualHost and HostName to filter the results.

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.Queue objects which describe RabbitMQ queue.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Get-RabbitMQQueue {
   [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'None')]
   Param
   (
      # Name of RabbitMQ queue.
      [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
      [Alias("queue")]
      [string[]]$Name = "",
               
      # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
      [Parameter(ValueFromPipelineByPropertyName = $true)]
      [Alias("ComputerName")]
      [string]$HostName = $DefaultHostName,

      # Name of the virtual host to filter channels by.
      [Parameter(ValueFromPipelineByPropertyName = $true)]
      [Alias("vhost")]
      [string]$VirtualHost,

      # When set then returns only queues which have messages.
      [switch]$NotEmpty,

      # When set then displays queue statistics.
      [switch]$ShowStats,

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
      if ($PSCmdlet.ShouldProcess("server $HostName", "Get queues(s): $(NamesToString -Name $Name -AltText '(all)')")) {
         $result = GetItemsFromRabbitMQApi -HostName $HostName -Credentials $Credentials -Function "queues" -UseHttps:$UseHttps -port:$Port -SkipCertificateCheck:$SkipCertificateCheck
            
         $result = ApplyFilter $result 'name' $Name
         if ($VirtualHost) { $result = ApplyFilter $result 'vhost' $VirtualHost }
            
         foreach ($item in $result) {
            if ($null -eq $item.messages) { $item | Add-Member -MemberType NoteProperty -Name messages -Value 0 }
            if ($null -eq $item.messages_ready) { $item | Add-Member -MemberType NoteProperty -Name messages_ready -Value 0 }
            if ($null -eq $item.messages_unacknowledged) { $item | Add-Member -MemberType NoteProperty -Name messages_unacknowledged -Value 0 }
         }

         if ($NotEmpty) { 
            $result = $result | Where-Object messages -NE 0 
         }

         $result | Add-Member -NotePropertyName "HostName" -NotePropertyValue $HostName

         if ($ShowStats) {
            SendItemsToOutput -Items $result -TypeName "RabbitMQ.Queue" | Format-Table -View Stats
         }
         else {
            SendItemsToOutput -Items $result -TypeName "RabbitMQ.Queue"
         }
      }
   }
    
   end {
   }
}

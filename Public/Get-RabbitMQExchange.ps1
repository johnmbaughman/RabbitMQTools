﻿<#
.Synopsis
   Gets Virtual Hosts registered with the server.

.DESCRIPTION
   The Get-RabbitMQVirtualHost gets Virtual Hosts registered with RabbitMQ server.

   The cmdlet allows you to show all Virtual Hosts or filter them by name using wildcards.
   The result may be zero, one or many RabbitMQ.VirtualHost objects.

   To get Virtual Hosts from remote server you need to provide -HostName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Get-RabbitMQVirtualHost

   This command gets a list of all Virtual Hosts registered with RabbitMQ on local server.

.EXAMPLE
   Get-RabbitMQVirtualHost -HostName myrabbitmq.servers.com

   This command gets a list of all Virtual Hosts registered with RabbitMQ on myrabbitmq.servers.com server.

.EXAMPLE
   Get-RabbitMQVirtualHost private*

   This command gets a list of all Virtual Hosts which name starts with "private".

.EXAMPLE
   Get-RabbitMQVirtualHost private*, public*

   This command gets a list of all Virtual Hosts which name starts with "private" or "public".

.EXAMPLE
   Get-RabbitMQVirtualHost private*, public*

   This command gets a list of all Virtual Hosts which name starts with "private" or "public".

.EXAMPLE 
    Get-RabbitMQVirtualHost marketing_private | select *

    This command selects all properties for given Virtual Host.

.EXAMPLE
   @("private*", "*public") | Get-RabbitMQVirtualHost

   This command pipes name filters to Get-RabbitMQVirtualHost cmdlet.

.INPUTS
   You can pipe Virtual Host names to filter results.

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.VirtualHost objects which describe Virtual Hosts. 

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Get-RabbitMQExchange {
   [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'None')]
   Param
   (
      # Name of RabbitMQ Exchange.
      [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
      [Alias("Exchange")]
      [string[]]$Name = "",

      # Name of RabbitMQ Virtual Host.
      [Parameter(ValueFromPipelineByPropertyName = $true)]
      [Alias("vhost")]
      [string]$VirtualHost = "",
        
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
      if ($PSCmdlet.ShouldProcess("server $HostName", "Get exchange(s): $(NamesToString -Name $Name -AltText '(all)')")) {
         $exchanges = GetItemsFromRabbitMQApi -HostName $HostName -Credentials $Credentials -Function "exchanges" -UseHttps:$UseHttps -port:$Port -SkipCertificateCheck:$SkipCertificateCheck
            
         $result = ApplyFilter $exchanges 'vhost' $VirtualHost
         $result = ApplyFilter $result 'name' $Name

         $result | Add-Member -NotePropertyName "HostName" -NotePropertyValue $HostName

         SendItemsToOutput -Items $result -TypeName "RabbitMQ.Exchange"
      }
   }
    
   end {
   }
}

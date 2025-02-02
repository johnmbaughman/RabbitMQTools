﻿<#
.Synopsis
   Gets RabbitMQ Nodes.

.DESCRIPTION
   The Get-RabbitMQNode cmdlet gets nodes in RabbitMQ cluster.

   The cmdlet allows you to show list of cluster nodes or filter them by name using wildcards.
   The result may be zero, one or many RabbitMQ.Node objects.

   To get Nodes from remote server you need to provide -HostName parameter.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Get-RabbitMQNode

   This command gets a list of nodes in RabbitMQ cluster.

.EXAMPLE
   Get-RabbitMQNode -HostName myrabbitmq.servers.com

   This command gets a list of nodes in the cluster on myrabbitmq.servers.com server.

.EXAMPLE
   Get-RabbitMQNode second*

   This command gets a list of nodes in a cluster which name starts with "second".

.EXAMPLE
   Get-RabbitMQNode secondary*, primary

   This command gets cluster nodes which name is either "primary" or starts with "secondary".

.EXAMPLE
   @("primary", "secondary") | Get-RabbitMQNode

   This command pipes node name filters to Get-RabbitMQNode cmdlet.

.INPUTS
   You can pipe Name to filter the results.

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.Node objects which describe cluster nodes.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Get-RabbitMQNode {
   [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'None')]
   Param
   (
      # Name of RabbitMQ Node.
      [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
      [Alias("Node", "NodeName")]
      [string[]]$Name = "",
               
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
      if ($PSCmdlet.ShouldProcess("server $HostName", "Get node(s): $(NamesToString -Name $Name -AltText '(all)')")) {
         $result = GetItemsFromRabbitMQApi -HostName $HostName -Credentials $Credentials -Function "nodes" -UseHttps:$UseHttps -port:$Port -SkipCertificateCheck:$SkipCertificateCheck
            
         $result = ApplyFilter $result 'name' $Name

         $result | Add-Member -NotePropertyName "HostName" -NotePropertyValue $HostName

         SendItemsToOutput -Items $result -TypeName "RabbitMQ.Node"
      }
   }
    
   end {
   }
}

<#
.Synopsis
   Gets list of users.

.DESCRIPTION
   The Get-RabbitMQUser gets list of users registered in RabbitMQ server.

   The result may be zero, one or many RabbitMQ.User objects.

   To get users from remote server you need to provide -HostName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Get-RabbitMQUser

   Gets list of all users in local RabbitMQ server.

.EXAMPLE
   Get-RabbitMQUser -HostName myrabbitmq.servers.com

   Gets list of all users in myrabbitmq.servers.com server.

.EXAMPLE
   Get-RabbitMQUser gu*

   Gets list of all users whose name starts with "gu".

.EXAMPLE
   Get-RabbitMQUser guest, admin

   Gets data for users guest and admin.

.EXAMPLE
   Get-RabbitMQUser -View Flat

   Gets flat list of all users. This view doesn't group users by HostName as the default view do.

.INPUTS
   You can pipe Names and HostNames to filter results.

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.User objects which describe user. 

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Get-RabbitMQUser {
   [CmdletBinding(SupportsShouldProcess = $true, PositionalBinding = $false)]
   Param
   (
       # Name of user.
       [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
       [string[]]$User = "",

      # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
      [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
      [Alias(, "ComputerName")]
      [string]$HostName = $DefaultHostName,
        
      [ValidateSet("Default", "Flat")]
      [string]$View,

      # UserName to use when logging to RabbitMq server. Default value is guest.
      [Parameter(Mandatory = $true, ParameterSetName = 'login')]
      [string]$UserName,

      # Password to use when logging to RabbitMq server. Default value is guest.
      [Parameter(Mandatory = $true, ParameterSetName = 'login')]
      [securestring]$Password,

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
      if ($PSCmdlet.ShouldProcess("server $HostName", "Get user(s)")) {
         $result = GetItemsFromRabbitMQApi -HostName $HostName -Credentials $Credentials -Function "users" -UseHttps:$UseHttps -port:$Port -SkipCertificateCheck:$SkipCertificateCheck
         $result = ApplyFilter $result 'name' $User
         $result | Add-Member -NotePropertyName "HostName" -NotePropertyValue $HostName
 
         if (-not $View) { SendItemsToOutput -Items $result -TypeName "RabbitMQ.User" }
         else { SendItemsToOutput -Items $result -TypeName "RabbitMQ.User" | Format-Table -View $View }
      }
   }
    
   end {
   }
}
<#
.Synopsis
   Gets Permissions for VirtualHost and/or user.

.DESCRIPTION
   The Get-RabbitMQPermission cmdlet shows permissions users have to work with virtual hosts.

   The cmdlet allows you to show all permissions or filter them by VirtualHost and/or User using wildcards.
   The result may be zero, one or many RabbitMQ.Permission objects.

   To get permissions from remote server you need to provide -HostName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Get-RabbitMQPermission

   Show permissions of all users and all virtual hosts from the local RabbitMQ server.

.EXAMPLE
   Get-RabbitMQPermission -HostName myrabbitmq.servers.com

   Show permissions of all users and all virtual hosts from the myrabbitmq.servers.com server RabbitMQ server.

.EXAMPLE
    Get-RabbitMQPermission -VirtualHost / -User guest

    List user guest permissions to virtual host /.

.EXAMPLE
   Get-RabbitMQPermission private*

   Show permissions of all users in virtual hosts which name starts with "private".

.EXAMPLE
   Get-RabbitMQPermission private*, public*

   This command gets a list of all Virtual Hosts which name starts with "private" or "public".

.INPUTS
   You can pipe Virtual Host and User names to filter results.

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.Permission objects. 

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Get-RabbitMQPermission {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'None')]
    Param
    (
        # Name of RabbitMQ Virtual Host.
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("vhost")]
        [string[]]$VirtualHost = "",

        # Name of user.
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$User = "",

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
        if ($PSCmdlet.ShouldProcess("server $HostName", "Get permission(s) for VirtualHost = $(NamesToString -Name $VirtualHost -AltText '(all)') and User = $(NamesToString -Name $User -AltText '(all)')")) {
            $result = GetItemsFromRabbitMQApi -HostName $HostName -Credentials $Credentials -Function "permissions" -UseHttps:$UseHttps -port:$Port -SkipCertificateCheck:$SkipCertificateCheck
            $result = ApplyFilter $result "vhost" $VirtualHost
            $result = ApplyFilter $result "user" $User


            foreach ($i in $result) {
                $i | Add-Member -NotePropertyName "HostName" -NotePropertyValue $HostName
            }

            SendItemsToOutput -Items $result -TypeName "RabbitMQ.Permission"
        }
    }
    
    end {
    }
}

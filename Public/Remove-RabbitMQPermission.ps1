<#
.Synopsis
   Removes permissions to virtual host for a user.

.DESCRIPTION
   The Remove-RabbitMQPermission cmdlet allows to remove user permissions to virtual host.

   To remove permissions to remote server you need to provide -HostName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Remove-RabbitMQPermission -VirtualHost '/' -User Admin

   Removes permissions for user Admin to default virtual host (/) on local RabbitMQ server.

.EXAMPLE
   Remove-RabbitMQPermission -HostName rabbitmq.server.com '/' Admin

   Removes permissions for user Admin to default virtual host (/) on remote RabbitMQ rabbitmq.server.com.

.INPUTS
   You can pipe VirtualHost, User and HostName to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Remove-RabbitMQPermission {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param
    (
        # Virtual host to set permission for.
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("vhost")]
        [string]$VirtualHost = $DefaultVirtualHost,

        # Name of user to set permission for.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$User,

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

        $p = Get-RabbitMQPermission -HostName $HostName -Credentials $Credentials -VirtualHost $VirtualHost -User $User -port $Port -UseHttps:$UseHttps -SkipCertificateCheck:$SkipCertificateCheck
        if (-not $p) { throw "Permissions to virtual host $VirtualHost for user $User do not exist. To create permissions use Add-RabbitMQPermission cmdlet." }
        
        $cnt = 0
    }
    process {
        if ($PSCmdlet.ShouldProcess("server: $HostName", "Remove permissions to virtual host $VirtualHost for user $User : $Configure, $Read $Write")) {
            $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)permissions/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($User))"
            Invoke-RestMethod -Uri $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Delete -SkipCertificateCheck:$SkipCertificateCheck

            Write-Verbose "Removed permissions to $VirtualHost for $User : $Configure, $Read, $Write"
            $cnt++
        }
    }
    end {
        if ($cnt -gt 1) { Write-Verbose "Removed $cnt permissions." }
    }
}

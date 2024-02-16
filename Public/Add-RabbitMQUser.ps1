<#
.Synopsis
   Adds user to RabbitMQ server.

.DESCRIPTION
   The Add-RabbitMQUser cmdlet allows to create new users in RabbitMQ server.

   To add a user to remote server you need to provide -HostName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Add-RabbitMQUser -Name Admin -NewPassword p4ssw0rd -Tag administrator

   Create new user with name Admin having administrator tags set. User is added to local RabbitMQ server.

.EXAMPLE
   Add-RabbitMQUser -HostName rabbitmq.server.com Admin p4ssw0rd administrator

   Create new user with name "Admin", password "p4ssw0rd" having "administrator" tags set. User is added to rabbitmq.server.com server. This command uses positional parameters.
   Note that password for new user is specified as -NewPassword parameter and not -Password parameter, which is used for authorisation to the server.

.INPUTS
   You can pipe Name, NewPassword, Tags and HostName to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Add-RabbitMQUser
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
    Param
    (
        # Name of user to create.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        # Password for new user.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [securestring]$NewPassword,

        # Comma-separated list of user tags.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("administrator","monitoring","policymaker","management","impersonator","none")]
        [string[]]$Tag,

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
    }

    Process
    {
        if ($PSCmdlet.ShouldProcess("server: $HostName", "Add user $Name with tag: $Tag"))
        {
            $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)users/$([System.Web.HttpUtility]::UrlEncode($Name))"
            $body = @{
                'password' = ConvertFrom-SecureString -SecureString $NewPassword -AsPlainText
                'tags' = $Tag -join ','
            } | ConvertTo-Json

            Write-Verbose $url
            Write-Verbose $body

            Invoke-RestMethod -Uri $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Put -ContentType "application/json" -Body $body -SkipCertificateCheck:$SkipCertificateCheck

            Write-Verbose "Created user $User with tags $Tag"            
        }
    }
    
    End
    {
        Write-Verbose "Created new user."
    }
}

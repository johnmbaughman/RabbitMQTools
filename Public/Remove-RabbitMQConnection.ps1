<#
.Synopsis
   Closes connection to RabbitMQ server.

.DESCRIPTION
   The Remove-RabbitMQConnection allows for closing connection to the RabbitMQ server. This cmdlet is marked with High impact.

   To close connections to the remote server you need to provide -HostName parameter.

   You may pipe an object with names and, optionally, with computer names to close multiple connection. For more information how to do that see Examples.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Remove-RabbitMQConnection conn1

   This command closes connection  to local RabbitMQ server named "conn1".

.EXAMPLE
   Remove-RabbitMQConnection c1, c1

   This command closes connections  to local RabbitMQ server named "c1" and "c2".

.EXAMPLE
   Remove-RabbitMQConnection c1 -HostName myrabbitmq.servers.com

   This command closes connection c1 to myrabbitmq.servers.com server.

.EXAMPLE
   @("c1", "c2") | Remove-RabbitMQConnection

   This command pipes list of connection to be closed. In the above example two connections named "c1" and "c2" will be closed.

.EXAMPLE
    $a = $(
        New-Object -TypeName psobject -Prop @{"HostName" = "localhost"; "Name" = "c1"}
        New-Object -TypeName psobject -Prop @{"HostName" = "localhost"; "Name" = "c2"}
        New-Object -TypeName psobject -Prop @{"HostName" = "127.0.0.1"; "Name" = "c3"}
    )


   $a | Remove-RabbitMQConnection

   Above example shows how to pipe both connection name and Computer Name to specify server.
   
   The above example will close two connection named "c1" and "c2" to local server, and one connection named "c3" to the server 127.0.0.1.

.INPUTS
   You can pipe connection names and optionally HostNames to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Remove-RabbitMQConnection {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    Param
    (
        # Name of RabbitMQ connection.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("ConnectionName")]
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
        $cnt = 0
    }
    process {
        if (-not $PSCmdlet.ShouldProcess("server: $HostName", "Close connection(s): $(NamesToString -Name $Name -AltText '(all)')")) {
            foreach ($qn in $Name) { 
                Write-Output "Closing connection $qn to server=$HostName"
                $cnt++
            }
            return
        }

        foreach ($n in $Name) {
            $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)connections/$([System.Web.HttpUtility]::UrlEncode($n))"
            Invoke-RestMethod -Uri $url -Credential $Credentials -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Delete -SkipCertificateCheck:$SkipCertificateCheck

            Write-Verbose "Closed connection $n to server $HostName"
            $cnt++
        }
    }
    end {
        if ($cnt -gt 1) { Write-Verbose "Closed $cnt connection(s)." }
    }
}

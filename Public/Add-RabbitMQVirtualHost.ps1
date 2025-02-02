﻿<#
.Synopsis
   Adds Virtual Hosts to RabbitMQ server.

.DESCRIPTION
   The Add-RabbitMQVirtualHost allows for creating new Virtual Hosts in given RabbitMQ server.

   To add Virtual Hosts to remote server you need to provide -HostName.

   You may pipe an object with names and, optionally, with computer names to create multiple VirtualHosts. For more information how to do that see Examples.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Add-RabbitMQVirtualHost testHost

   This command adds new Virtual Host named "testHost" to local RabbitMQ server.

.EXAMPLE
   Add-RabbitMQVirtualHost VHost1, VHost2

   This command adds two new Virtual Hosts named "VHost1" and "VHost2" to local RabbitMQ server.

.EXAMPLE
   Add-RabbitMQVirtualHost testHost -HostName myrabbitmq.servers.com

   This command adds new Virtual Host named "testHost" to myrabbitmq.servers.com server.

.EXAMPLE
   @("VHost1", "VHost2") | Add-RabbitMQVirtualHost

   This command pipes list of Virtual Hosts to add to the RabbitMQ server. In the above example two new Virtual Hosts named "VHost1" and "VHost2" will be created in local RabbitMQ server.

.EXAMPLE
    $a = $(
        New-Object -TypeName psobject -Prop @{"HostName" = "localhost"; "Name" = "vh1"}
        New-Object -TypeName psobject -Prop @{"HostName" = "localhost"; "Name" = "vh2"}
        New-Object -TypeName psobject -Prop @{"HostName" = "127.0.0.1"; "Name" = "vh3"}
    )


   $a | Add-RabbitMQVirtualHost

   Above example shows how to pipe both Virtual Host name and Computer Name to specify server on which the Virtual Host should be created.
   
   In the above example two new Virtual Hosts named "vh1" and "vh1" will be created in RabbitMQ local server, and one Virtual Host named "vh3" will be created on the server 127.0.0.1.

.INPUTS
   You can pipe VirtualHost names and optionally HostNames to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Add-RabbitMQVirtualHost {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
    Param
    (
        # Name of RabbitMQ Virtual Host.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("VirtualHost")]
        [string[]]$Name,

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
        if (-not $PSCmdlet.ShouldProcess("server: $HostName", "Add vhost(s): $(NamesToString -Name $Name -AltText '(all)')")) {
            foreach ($qn in $Name) { 
                Write-Output "Creating new Virtual Host $qn on server $HostName" 
                $cnt++
            }

            return
        }

        foreach ($n in $Name) {
            $url = "$(Format-BaseUrl -HostName $HostName -port $Port -UseHttps:$UseHttps)vhosts/$([System.Web.HttpUtility]::UrlEncode($n))"
            Invoke-RestMethod -Uri $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive:$InvokeRestMethodKeepAlive -ErrorAction Continue -Method Put -ContentType "application/json" -SkipCertificateCheck:$SkipCertificateCheck

            Write-Verbose "Created Virtual Host $n on server $HostName"
            $cnt++
        }
    }

    end {
        Write-Verbose "Created $cnt Virtual Host(s)."
    }
}

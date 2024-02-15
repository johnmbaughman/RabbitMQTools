$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestSetup.ps1"
. "$here\..\Public\Remove-RabbitMQVirtualHost.ps1"

function SetUpTest($vhosts = ("vh1","vh2")) {
    
    Add-RabbitMQVirtualHost -HostName $server -Name $vhosts

}

function TearDownTest($vhosts = ("vh1","vh2")) {
    
    foreach($vhost in $vhosts){
        Remove-RabbitMQVirtualHost -HostName $server -Name $vhost -ErrorAction Continue -Confirm:$false
    }
}

Describe -Tags "Example" "Remove-RabbitMQVirtualHost" {
    It "should remove existing Virtual Host" {

        SetUpTest

        Add-RabbitMQVirtualHost -HostName $server "vh3"
        Remove-RabbitMQVirtualHost -HostName $server "vh3" -Confirm:$false
        
        $actual = Get-RabbitMQVirtualHost -HostName $server "vh*" | select -ExpandProperty name 
        
        $actual | Should Be $("vh1", "vh2")

        TearDownTest
    }
}
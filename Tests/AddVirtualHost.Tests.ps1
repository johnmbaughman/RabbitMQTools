$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestSetup.ps1"
. "$here\..\Public\Add-RabbitMQVirtualHost.ps1"

function TearDownTest() {
    
    $vhosts = Get-RabbitMQVirtualHost -HostName $server -Name vh3, vh4

    ($vhosts) | Remove-RabbitMQVirtualHost -HostName $server -ErrorAction Continue -Confirm:$false
}

Describe -Tags "Example" "Add-RabbitMQVirtualHost" {
    It "should create new Virtual Host" {
    
        Add-RabbitMQVirtualHost -HostName $server -Name "vh3"
        
        $actual = Get-RabbitMQVirtualHost -HostName $server -Name "vh3" | select -ExpandProperty name 
        
        $actual | Should Be "vh3"
    
        TearDownTest
    }
    
    It "should do nothing when VirtualHost already exists" {
    
        Add-RabbitMQVirtualHost -HostName $server "vh3"
        Add-RabbitMQVirtualHost -HostName $server "vh3"
    
        $actual = Get-RabbitMQVirtualHost -HostName $server "vh3" | select -ExpandProperty name 
        
        $actual | Should Be "vh3"
    
        TearDownTest
    }
    
    It "should create many Virtual Hosts" {
    
        Add-RabbitMQVirtualHost -HostName $server "vh3", "vh4"
    
        $actual = Get-RabbitMQVirtualHost -HostName $server "vh3", "vh4" | select -ExpandProperty name 
    
        $expected = $("vh3", "vh4")
    
        AssertAreEqual $actual $expected
    
        TearDownTest
    }
    
    It "should get VirtualHost to be created from the pipe" {
    
        $("vh3", "vh4") | Add-RabbitMQVirtualHost -HostName $server
        
        $actual = $($("vh3", "vh4") | Get-RabbitMQVirtualHost -HostName $server) | select -ExpandProperty name 
    
        $expected = $("vh3", "vh4")
    
        AssertAreEqual $actual $expected
    
        TearDownTest
    }
    
    It "should get VirtualHost with HostName to be created from the pipe" {
    
        $pipe = $(
            New-Object -TypeName psobject -Prop @{"HostName" = $server; "Name" = "vh3" }
            New-Object -TypeName psobject -Prop @{"HostName" = $server; "Name" = "vh4" }
        )
    
        $pipe | Add-RabbitMQVirtualHost
    
        $actual = $($pipe | Get-RabbitMQVirtualHost -HostName $server) | select -ExpandProperty name 
    
        $expected = $("vh3", "vh4")
    
        AssertAreEqual $actual $expected
    
        TearDownTest
    }
}


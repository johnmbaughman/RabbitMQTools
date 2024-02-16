$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestSetup.ps1"
. "$here\..\Public\Get-RabbitMQExchange.ps1"


Describe -Tags "Example" "Get-RabbitMQExchange" {

    It "should get Exchanges registered with the server" {

        $actual = Get-RabbitMQExchange -HostName $server | Select-Object -ExpandProperty name 

        $actual.length | Should Not Be 0
    }

    It "should get Exchanges filtered by name" {
    
        $actual = Get-RabbitMQExchange -HostName $server -Name "amq.*" | Select-Object -ExpandProperty name | Sort-Object | Get-Unique 
    
        $expected = $(
            "amq.direct",
            "amq.fanout",
            "amq.headers",
            "amq.match",
            "amq.rabbitmq.log",
            "amq.rabbitmq.trace",
            "amq.topic"
        )
   
        AssertAreEqual $actual $expected
    }

    It "should get Exchanges filtered by VirtualHost" {
    
        $actual = Get-RabbitMQExchange -HostName $server -VirtualHost /
    
        $actual.length | Should Not Be 0
    }
    
    It "should get Exchange names to filter by from the pipe" {
    
        $actual = $('amq.direct', 'amq.fanout') | Get-RabbitMQExchange -HostName $server | Select-Object -ExpandProperty name | Sort-Object | Get-Unique 
    
        $expected = $('amq.direct', 'amq.fanout')
    
        AssertAreEqual $actual $expected
    }
    
    It "should get VirtualHost and HostName from the pipe" {
    
        $pipe = $(
            New-Object -TypeName psobject -Prop @{"HostName" = $server; "VirtualHost" = "/"; "Name"="amq.direct" }
            New-Object -TypeName psobject -Prop @{"HostName" = $server; "VirtualHost" = "/"; "Name"="amq.fanout" }
        )
    
        $actual = $pipe | Get-RabbitMQExchange | Select-Object -ExpandProperty name 
    
        $expected = $('amq.direct', 'amq.fanout')
    
        AssertAreEqual $actual $expected
    }
    
    #It "should pipe result from itself" {
    #
    #    $actual = Get-RabbitMQExchange -HostName $server | Get-RabbitMQExchange | select -ExpandProperty name 
    #
    #    $expected = Get-RabbitMQExchange -HostName $server | select -ExpandProperty name 
    #
    #    AssertAreEqual $actual $expected
    #}
}


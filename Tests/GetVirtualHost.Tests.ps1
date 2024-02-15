$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestSetup.ps1"
. "$here\..\Public\Get-RabbitMQVirtualHost.ps1"

function SetUpTest($vhosts = ("vh1","vh2")) {
    
    Add-RabbitMQVirtualHost -HostName $server -Name $vhosts

}
function TearDownTest($vhosts = ("vh1","vh2")) {
    
    foreach($vhost in $vhosts){
        Remove-RabbitMQVirtualHost -HostName $server -Name $vhost -ErrorAction Continue -Confirm:$false
    }
}

Describe -Tags "Example" "Get-RabbitMQVirtualHost" {

    It "should get Virtual Hosts registered with the server" {

        SetUpTest

        $actual = Get-RabbitMQVirtualHost -HostName $server | select -ExpandProperty name 

        $expected = $("/", "vh1", "vh2")

        AssertAreEqual $actual $expected

        TearDownTest
    }

    It "should get Virtual Hosts filtered by name" {

        SetUpTest

        $actual = Get-RabbitMQVirtualHost -HostName $server vh* | select -ExpandProperty name 

        $expected = $("vh1", "vh2")

        AssertAreEqual $actual $expected

        TearDownTest
    }

    It "should get VirtualHost names to filter by from the pipe" {

        SetUpTest

        $actual = $('vh1', 'vh2') | Get-RabbitMQVirtualHost -HostName $server | select -ExpandProperty name 

        $expected = $("vh1", "vh2")

        AssertAreEqual $actual $expected

        TearDownTest
    }

    It "should get VirtualHost and HostName from the pipe" {

        SetUpTest

        $pipe = $(
            New-Object -TypeName psobject -Prop @{"ComputerName" = $server; "Name" = "vh1" }
            New-Object -TypeName psobject -Prop @{"ComputerName" = $server; "Name" = "vh2" }
        )

        $actual = $pipe | Get-RabbitMQVirtualHost | select -ExpandProperty name 

        $expected = $("vh1", "vh2")

        AssertAreEqual $actual $expected

        TearDownTest
    }

    It "should pipe result from itself" {

        SetUpTest

        $actual = Get-RabbitMQVirtualHost -HostName $server | Get-RabbitMQVirtualHost | select -ExpandProperty name 

        $expected = Get-RabbitMQVirtualHost -HostName $server | select -ExpandProperty name 

        AssertAreEqual $actual $expected

        TearDownTest
    }
}


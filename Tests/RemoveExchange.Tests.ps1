﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestSetup.ps1"
. "$here\..\Public\Remove-RabbitMQExchange.ps1"

Describe -Tags "Example" "Remove-RabbitMQExchange" {
    It "should remove existing Exchange" {

        Add-RabbitMQExchange -HostName $server -Name "e1" -Type direct
        Remove-RabbitMQExchange -HostName $server -Name "e1" -Confirm:$false
        
        $actual = Get-RabbitMQExchange -HostName $server -Name e1 | select -ExpandProperty name 
        
        $actual | Should Be $()
    }
}
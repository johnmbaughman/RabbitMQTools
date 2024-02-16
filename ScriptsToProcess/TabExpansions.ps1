$hostNameCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $global:RabbitMQServers
}

$virtualHostCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $params = @{}
    if ($fakeBoundParameter.HostName) { $params.Add("HostName", $fakeBoundParameter.HostName) }
    if ($fakeBoundParameter.UserName) { $params.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $params.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQVirtualHost @params | Where-Object name -Like "$wordToComplete*" | Select-Object name | ForEach-Object { 
        $vhname = @{$true = "Default"; $false = $_.name }[$_.name -eq "/"]
        $cname = @{$true = "localhost"; $false = $fakeBoundParameter.HostName }[$fakeBoundParameter.HostName -eq $null]
        $tooltip = "$vhname on $cname."
        
        createCompletionResult $_.name $_.name $tooltip
    }
}

$exchangeCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $params = @{}
    if ($fakeBoundParameter.VirtualHost) { $params.Add("VirtualHost", $fakeBoundParameter.VirtualHost) }
    if ($fakeBoundParameter.HostName) { $params.Add("HostName", $fakeBoundParameter.HostName) }
    if ($fakeBoundParameter.UserName) { $params.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $params.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQExchange @params | Where-Object name -Like "$wordToComplete*" | Select-Object name | ForEach-Object { 
        $ename = @{$true = "(AMQP default)"; $false = $_.name }[$_.name -eq ""]
        $vhname = @{$true = "[default]"; $false = $fakeBoundParameter.VirtualHost }[$fakeBoundParameter.VirtualHost -eq "/"]
        $cname = @{$true = "localhost"; $false = $fakeBoundParameter.HostName }[$fakeBoundParameter.HostName -eq $null]
        $tooltip = "$ename on $cname/$vhname."
        
        createCompletionResult $ename $ename $tooltip
    }
}

$connectionCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $params = @{}
    if ($fakeBoundParameter.HostName) { $params.Add("HostName", $fakeBoundParameter.HostName) }
    if ($fakeBoundParameter.UserName) { $params.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $params.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQConnection @params | Where-Object name -Like "$wordToComplete*" | Select-Object name | ForEach-Object { 
        $cname = @{$true = "localhost"; $false = $fakeBoundParameter.HostName }[$fakeBoundParameter.HostName -eq $null]
        $tooltip = "$_.name on $cname."
        
        createCompletionResult $_.name $_.name $tooltip
    }
}

$nodeCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $params = @{}
    if ($fakeBoundParameter.HostName) { $params.Add("HostName", $fakeBoundParameter.HostName) }
    if ($fakeBoundParameter.UserName) { $params.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $params.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQNode @params | Where-Object name -Like "$wordToComplete*" | Select-Object name | ForEach-Object { 
        $cname = @{$true = "localhost"; $false = $fakeBoundParameter.HostName }[$fakeBoundParameter.HostName -eq $null]
        $tooltip = $_.name + " on " + $cname + "."
        
        createCompletionResult $_.name $_.name $tooltip
    }
}

$channelCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $params = @{}
    if ($fakeBoundParameter.HostName) { $params.Add("HostName", $fakeBoundParameter.HostName) }
    if ($fakeBoundParameter.VirtualHost) { $params.Add("VirtualHost", $fakeBoundParameter.VirtualHost) }
    if ($fakeBoundParameter.UserName) { $params.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $params.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQChannel @params | Where-Object name -Like "$wordToComplete*" | Select-Object name | ForEach-Object { 
        $cname = @{$true = "localhost"; $false = $fakeBoundParameter.HostName }[$fakeBoundParameter.HostName -eq $null]
        $tooltip = $_.name + " on " + $cname + "."
        
        createCompletionResult $_.name $_.name $tooltip
    }
}

$queueCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $params = @{}
    if ($fakeBoundParameter.HostName) { $params.Add("HostName", $fakeBoundParameter.HostName) }
    if ($fakeBoundParameter.VirtualHost) { $params.Add("VirtualHost", $fakeBoundParameter.VirtualHost) }
    if ($fakeBoundParameter.UserName) { $params.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $params.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQQueue @params | Where-Object name -Like "$wordToComplete*" | ForEach-Object { 
        $cname = @{$true = "localhost"; $false = $fakeBoundParameter.HostName }[$fakeBoundParameter.HostName -eq $null]
        $n = "$($_.name) ($($_.messages))"
        $tooltip = "$($_.name) on $cname/$($_.vhost) ($($_.messages) messages)."

        createCompletionResult $n $_.name $tooltip
    }
}

$routingKeyGeneration_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $params = @{}
    if ($fakeBoundParameter.HostName) { $params.Add("HostName", $fakeBoundParameter.HostName) }
    if ($fakeBoundParameter.VirtualHost) { $params.Add("VirtualHost", $fakeBoundParameter.VirtualHost) }
    if ($fakeBoundParameter.UserName) { $params.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $params.Add("Password", $fakeBoundParameter.Password) }

    $tooltip = "Bind exchange " + $fakeBoundParameter.ExchangeName + " to queue " + $fakeBoundParameter.Name + "."
        
    createCompletionResult $fakeBoundParameter.Name $tooltip
    createCompletionResult $($fakeBoundParameter.ExchangeName + "-" + $fakeBoundParameter.Name) $tooltip
    createCompletionResult $($fakeBoundParameter.ExchangeName + "->" + $fakeBoundParameter.Name) $tooltip
    createCompletionResult $($fakeBoundParameter.ExchangeName + ".." + $fakeBoundParameter.Name) $tooltip
}

$routingKeyCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $params = @{}
    if ($fakeBoundParameter.HostName) { $params.Add("HostName", $fakeBoundParameter.HostName) }
    if ($fakeBoundParameter.VirtualHost) { $params.Add("VirtualHost", $fakeBoundParameter.VirtualHost) }
    #if ($fakeBoundParameter.ExchangeName) { $params.Add("ExchangeName", $fakeBoundParameter.ExchangeName) }
    if ($fakeBoundParameter.Name) { $params.Add("Name", $fakeBoundParameter.Name) }
    if ($fakeBoundParameter.UserName) { $params.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $params.Add("Password", $fakeBoundParameter.Password) }

    #Get-RabbitMQQueueBinding @params | where name -like "$wordToComplete*" | select routing_key | ForEach-Object { 
    $a = Get-RabbitMQQueueBinding @params 
    $b = $a | Where-Object source -EQ $fakeBoundParameter.ExchangeName | Select-Object routing_key 

    $b | ForEach-Object { 
        createCompletionResult $_.routing_key $_.routing_key $_.routing_key 
    }
}

$userCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $params = @{}
    if ($fakeBoundParameter.HostName) { $params.Add("HostName", $fakeBoundParameter.HostName) }

    if ($fakeBoundParameter.Credentials) { $params.Add("Credentials", $fakeBoundParameter.Credentials) }
    if ($fakeBoundParameter.UserName) { $params.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $params.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQUser @params | Where-Object name -Like "$wordToComplete*" | ForEach-Object { 
        $tooltip = "$($_.name) [$($_.tags)]"

        createCompletionResult $_.name $_.name $tooltip
    }
}

function createCompletionResult([string]$text, [string]$value, [string]$tooltip) {

    if ([string]::IsNullOrEmpty($value)) { return }
    if ([string]::IsNullOrEmpty($text)) { $text = $value }
    if ([string]::IsNullOrEmpty($tooltip)) { $tooltip = $value }
    
    $completionText = @{$true = "'$value'"; $false = $value }[$value -match "\W"]
    $completionText = $completionText -replace '\[', '``[' -replace '\]', '``]'
    
    return New-Object -TypeName System.Management.Automation.CompletionResult $completionText, $text, 'ParameterValue', $tooltip 
}

if (-not $global:RabbitMqToolsOptions) { $global:RabbitMqToolsOptions = @{CustomArgumentCompleters = @{}; NativeArgumentCompleters = @{} } }

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Test1:Name'] = $testCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQOverview:Name'] = $hostNameCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQVirtualHost:Name'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQVirtualHost:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQVirtualHost:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQVirtualHost:Name'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQVirtualHost:HostName'] = $hostNameCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQExchange:Name'] = $exchangeCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQExchange:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQExchange:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQExchange:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQExchange:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQExchange:Name'] = $exchangeCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQExchange:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQExchange:HostName'] = $hostNameCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQConnection:Name'] = $connectionCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQConnection:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQConnection:Name'] = $connectionCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQConnection:HostName'] = $hostNameCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQNode:Name'] = $nodeCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQNode:HostName'] = $hostNameCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQChannel:Name'] = $channelCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQChannel:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQChannel:HostName'] = $hostNameCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQQueue:Name'] = $queueCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQQueue:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQQueue:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQQueue:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQQueue:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQQueue:Name'] = $queueCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQQueue:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQQueue:HostName'] = $hostNameCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQQueueBinding:Name'] = $queueCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQQueueBinding:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQQueueBinding:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQQueueBinding:Name'] = $queueCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQQueueBinding:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQQueueBinding:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQQueueBinding:ExchangeName'] = $exchangeCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQQueueBinding:RoutingKey'] = $routingKeyGeneration_Process
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQQueueBinding:Name'] = $queueCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQQueueBinding:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQQueueBinding:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQQueueBinding:ExchangeName'] = $exchangeCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQQueueBinding:RoutingKey'] = $routingKeyCompletion_Process

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQMessage:Name'] = $queueCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQMessage:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQMessage:HostName'] = $hostNameCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Clear-RabbitMQQueue:Name'] = $queueCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Clear-RabbitMQQueue:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Clear-RabbitMQQueue:HostName'] = $hostNameCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Copy-RabbitMQMessage:SourceQueueName'] = $queueCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Copy-RabbitMQMessage:DestinationQueueName'] = $queueCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Copy-RabbitMQMessage:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Copy-RabbitMQMessage:HostName'] = $hostNameCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Move-RabbitMQMessage:SourceQueueName'] = $queueCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Move-RabbitMQMessage:DestinationQueueName'] = $queueCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Move-RabbitMQMessage:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Move-RabbitMQMessage:HostName'] = $hostNameCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQUser:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQUser:Name'] = $userCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQUser:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQUser:Name'] = $userCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Set-RabbitMQUser:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Set-RabbitMQUser:Name'] = $userCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQUser:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQUser:Name'] = $userCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQPermission:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQPermission:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Get-RabbitMQPermission:User'] = $userCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQPermission:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQPermission:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Add-RabbitMQPermission:User'] = $userCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Set-RabbitMQPermission:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Set-RabbitMQPermission:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Set-RabbitMQPermission:User'] = $userCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQPermission:HostName'] = $hostNameCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQPermission:VirtualHost'] = $virtualHostCompletion_Process 
$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Remove-RabbitMQPermission:User'] = $userCompletion_Process 

$global:RabbitMqToolsOptions['CustomArgumentCompleters']['Unregister-RabbitMQServer:HostName'] = $hostNameCompletion_Process 

$Function:tabexpansion2 = $Function:tabexpansion2 -replace 'End\r\n{', 'end { if ($null -ne $options) { $options += $global:RabbitMqToolsOptions} else {$options = $global:RabbitMqToolsOptions}'

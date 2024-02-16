# Set Module Variables
Set-Variable -Scope Script -Name InvokeRestMethodKeepAlive -Value $true

# Capture PSEdition
Set-Variable -Scope Script -Name IsPowershellCore -Value ($PSVersiontable.PSEdition -eq 'core')
Set-Variable -Scope Script -Name PowerShellVersionMajor -Value $PSVersionTable.PSVersion.Major

# Defaults
Set-Variable -Scope Script -Name DefaultHostName -Value "localhost"
Set-Variable -Scope Script -Name DefaultVirtualHost -Value "/"
Set-Variable -Scope Script -Name DefaultCredentials -Value (New-Object -TypeName System.Management.Automation.PSCredential ("guest", $(ConvertTo-SecureString -String "guest" -AsPlainText -Force)))

# Get public and private function definition files.
$Public = Get-ChildItem $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue 
$Private = Get-ChildItem $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue 

# Dot source the files
Foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import function $($import.FullName)"
    }
}

# Uri parser variables
if (-not $IsPowershellCore) {
    if (-not $UnEscapeDotsAndSlashes) { Set-Variable -Scope Script -Name UnEscapeDotsAndSlashes -Value 0x2000000 }
    if (-not $DefaultUriParserFlagsValue) { Set-Variable -Scope Script -Name DefaultUriParserFlagsValue -Value (GetUriParserFlags) }
    if (-not $UriUnEscapesDotsAndSlashes) { Set-Variable -Scope Script -Name UriUnEscapesDotsAndSlashes -Value (($DefaultUriParserFlagsValue -band $UnEscapeDotsAndSlashes) -eq $UnEscapeDotsAndSlashes) }
}

# Aliases
New-Alias -Name grvh -Value Get-RabbitMQVirtualHost -Description "Gets RabbitMQ's Virutal Hosts"
New-Alias -Name getvhost -Value Get-RabbitMQVirtualHost -Description "Gets RabbitMQ's Virutal Hosts"
New-Alias -Name arvh -Value Add-RabbitMQVirtualHost -Description "Adds RabbitMQ's Virutal Hosts"
New-Alias -Name addvhost -Value Add-RabbitMQVirtualHost -Description "Adds RabbitMQ's Virutal Hosts"
New-Alias -Name rrvh -Value Remove-RabbitMQVirtualHost -Description "Removes RabbitMQ's Virutal Hosts"
New-Alias -Name delvhost -Value Remove-RabbitMQVirtualHost -Description "Removes RabbitMQ's Virutal Hosts"

New-Alias -Name gre -Value Get-RabbitMQExchange -Description "Gets RabbitMQ's Exchages"
New-Alias -Name addexchangebinding -Value Add-RabbitMQExchangeBinding -Description "Adds bindings between RabbitMQ exchanges"

New-Alias -Name grq -Value Get-RabbitMQQueue -Description "Gets RabbitMQ's Queues"
New-Alias -Name getqueue -Value Get-RabbitMQQueue -Description "Gets RabbitMQ's Queues"
New-Alias -Name arq -Value Add-RabbitMQQueue -Description "Adds RabbitMQ's Queues"
New-Alias -Name addqueue -Value Add-RabbitMQQueue -Description "Adds RabbitMQ's Queues"
New-Alias -Name rrq -Value Remove-RabbitMQQueue -Description "Removes RabbitMQ's Queues"
New-Alias -Name delqueue -Value Remove-RabbitMQQueue -Description "Removes RabbitMQ's Queues"
New-Alias -Name getqueuebinding -Value Get-RabbitMQQueueBinding -Description "Gets bindings for RabbitMQ Queues"
New-Alias -Name addqueuebinding -Value Add-RabbitMQQueueBinding -Description "Adds bindings between RabbitMQ exchange and queue"

New-Alias -Name getmessage -Value Get-RabbitMQMessage -Description "Gets messages from RabbitMQ queue"

# Modules
#Export-ModuleMember -Function $($Public | Select -ExpandProperty BaseName) -Alias *
<#
	.Synopsis
		Скрипт, вызываемый при загрузке модулей ITG. Выполняет подготовку для загрузки модулей ITG.
	.Description
		Скрипт, вызываемый при загрузке модулей ITG. Выполняет подготовку для загрузки модулей ITG.
		На данном этапе:
		- добавляет в $env:PSModulePath каталог загружаемого модуля, чтобы все зависимости могли быть
		импортированы без указания полного пути (то есть - в том числе и из общего репозитория модулей
		powerShell)
	.Link
		описание манифеста модуля: http://get-powershell.com/post/2011/04/04/How-to-Package-and-Distribute-PowerShell-Cmdlets-Functions-and-Scripts.aspx
#>
[CmdletBinding(
)]
param ()

Write-Verbose "Добавляем каталог $( Split-Path -Path ( $myinvocation.mycommand.path ) -Parent ) в `$Env:PSModulePath.";

$Env:PSModulePath = (
	@( $env:psmodulepath -split ';' ) `
	+ ( Split-Path -Path ( $myinvocation.mycommand.path ) -Parent ) `
	| Select-Object -Unique `
) -join ';';

Write-Verbose @"
Изменённое значение `$Env:PSModulePath:
$(
(
	@( $env:psmodulepath -split ';' ) `
	| %{ "`t" + $_ } `
) -join "`n"
)
"@
;
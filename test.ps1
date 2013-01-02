[CmdletBinding(
)]
param (
)

Import-Module `
    (Join-Path `
		-Path ( Split-Path -Path ( $MyInvocation.MyCommand.Path ) ) `
        -ChildPath 'ITG.Yandex' `
    ) `
	-Force `
	-PassThru `
| Get-Readme `
	-OutDefaultFile `
	-ReferencedModules @(
		'ITG.Utils', 'ITG.WinAPI.UrlMon', 'ITG.WinAPI.User32' | Get-Module
	) `
;

# Get-Token -DomainName 'csm.nov.ru';

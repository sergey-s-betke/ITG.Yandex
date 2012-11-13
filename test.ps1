[CmdletBinding(
)]
param (
)

Import-Module `
    (join-path `
        -path ( ( [System.IO.FileInfo] ( $myinvocation.mycommand.path ) ).directory ) `
        -childPath 'ITG.Yandex' `
    ) `
	-Force `
	-PassThru `
| Get-Readme -OutDefaultFile;

Get-Token -DomainName 'csm.nov.ru';

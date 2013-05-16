'ITG.WinAPI.User32' `
, 'ITG.WinAPI.UrlMon' `
, 'ITG.RegExps' `
, 'ITG.Utils' `
| Import-Module;

Set-Variable `
	-Name 'APIRoot' `
	-Option 'Constant' `
	-Value 'https://pddimp.yandex.ru' `
;

Set-Variable `
	-Name 'TokenForDomain' `
	-Value (@{}) `
;

function Get-Token {
	<#
		.Component
			API Яндекс
		.Synopsis
			Метод (обёртка над Яндекс.API get_token) предназначен для получения авторизационного токена.
		.Description
			Метод get_token предназначен для получения авторизационного токена. 
			Авторизационный токен используется для активации API Яндекс.Почты для доменов. Получать токен
			нужно только один раз. Чтобы получить токен, следует иметь подключенный домен, авторизоваться
			его администратором.

			Данная функция возвращает непосредственно токен, либо генерирует исключение.
		.Outputs
			[System.String] - собственно token
		.Link
			[get_token]: http://api.yandex.ru/pdd/doc/api-pdd/reference/get-token.xml#get-token
		.Example
			$token = Get-Token -DomainName 'yourdomain.ru';
			Получение токена для домена yourdomain.ru.
	#>

	[CmdletBinding()]
	
	param (
		# имя домена - любой из доменов, зарегистрированных под Вашей учётной записью на сервисах Яндекса
		[Parameter(
			Mandatory=$true,
			Position=0,
			ValueFromPipeline=$true,
			ValueFromRemainingArguments=$true
		)]
		[string]
		[ValidateScript( { $_ -match "^$($reDomain)$" } )]
		[Alias("domain_name")]
		[Alias("Domain")]
		$DomainName
,
		# данный флаг указывает на необходимость принудительного запроса токена, минуя кеш
		[switch]
		$NoCache
	)

	process {
		if ( -not $NoCache ) {
			if ( $TokenForDomain.ContainsKey( $DomainName ) ) {
				return $TokenForDomain.$DomainName;
			} else {
				return $TokenForDomain.$DomainName = Get-Token -DomainName $DomainName -NoCache;
			};
		} else {
			$get_tokenURI = [System.Uri]"$APIRoot/get_token.xml?domain_name=$( [System.Uri]::EscapeDataString( $DomainName ) )";
			$get_tokenResponseURI = [System.Uri]"$APIRoot/token/get.xml";
			$get_tokenAuthURI = [System.Uri]"https://passport.yandex.ru/passport?mode=auth&msg=pdd&retpath=$( [System.Uri]::EscapeDataString( $get_tokenURI ) )";

			try {
				Write-Verbose 'Создаём экземпляр InternetExplorer.';
                if ( -not ( $ExistsIEProgId = Test-Path 'Registry::HKEY_CLASSES_ROOT\InternetExplorer.Application.Medium' )  ) {
                    $null = New-Item -Path 'HKCU:\Software\Classes' -Name 'InternetExplorer.Application.Medium' -Value 'Internet Explorer';
                    $null = New-Item -Path 'HKCU:\Software\Classes\InternetExplorer.Application.Medium' -Name 'CLSID' -Value '{D5E8041D-920F-45e9-B8FB-B1DEB82C6E5E}';
                };
				$ie = New-Object -Comobject 'InternetExplorer.Application.Medium';
                if ( -not $ExistsIEProgId ) {
                    Remove-Item -Path 'HKCU:\Software\Classes\InternetExplorer.Application.Medium' -Recurse -Force;
                };
				Write-Verbose "Отправляем InternetExplorer на Яндекс.Паспорт ($get_tokenAuthURI).";
				$ie.Navigate( $get_tokenAuthURI );
				$ie.Visible = $True;
				
				$ie `
				| Set-WindowZOrder -ZOrder ( [ITG.WinAPI.User32.HWND]::Top ) -PassThru `
				| Set-WindowForeground -PassThru `
				| Out-Null
				;

				Write-Verbose 'Ждём либо пока Яндекс.Паспорт сработает по cookies, либо пока администратор авторизуется на Яндекс.Паспорт...';
				while ( `
					$ie.Busy `
					-or ( ( [System.Uri]$ie.LocationURL ) -ne $get_tokenResponseURI ) `
				) { Sleep -milliseconds 100; };
				$ie.Visible = $False;

				$res = ( [xml]$ie.document.documentElement.innerhtml );
				Write-Debug "Ответ API get_token: $($ie.document.documentElement.innerhtml).";
				if ( $res.ok ) {
					$token = [System.String]$res.ok.token;
					Write-Verbose "Получили токен для домена $($DomainName): $token.";
					return $token;
				} else {
					$errMsg = $res.error.reason;
					Write-Error `
						-Message "Ответ API get_token для домена $DomainName отрицательный." `
						-Category PermissionDenied `
						-CategoryReason $errMsg `
						-CategoryActivity 'Yandex.API.get_token' `
						-CategoryTargetName $DomainName `
						-RecommendedAction 'Проверьте правильность указания домена и Ваши права на домен.' `
					;
				};
			} finally {
				Write-Verbose 'Уничтожаем экземпляр InternetExplorer.';
				$ie.Quit(); 
				$res = [System.Runtime.InteropServices.Marshal]::ReleaseComObject( $ie );
			};
		};
	}
};

function Invoke-API {
	<#
		.Component
			API Яндекс
		.Synopsis
			Обёртка для вызовов методов API Яндекс. Предназначена для внутреннего использования.
		.Description
			Обёртка для вызовов методов API Яндекс. Предназначена для внутреннего использования.
		.Outputs
			[xml] - Результат, возвращённый API.
	#>

	[CmdletBinding(
		SupportsShouldProcess=$true,
		ConfirmImpact="Medium"
	)]
	
	param (
		# HTTP метод вызова API
		[Parameter(
			Mandatory=$false
		)]
		[string]
		$HttpMethod = [System.Net.WebRequestMethods+HTTP]::Get
	,
		# авторизационный токен, полученный через Get-Token
		[Parameter(
		)]
		[string]
		$Token
	,
		# метод API - компонент url
		[Parameter(
			Mandatory=$true
		)]
		[ValidateNotNullOrEmpty()]
		[string]
		$method
	,
		# имя домена для регистрации на сервисах Яндекса
		[Parameter(
			Mandatory=$true
		)]
		[ValidateNotNullOrEmpty()]
		[string]
		$DomainName
	,
		# коллекция параметров метода API
		[AllowEmptyCollection()]
		[System.Collections.IDictionary]
		$Params = @{}
	,
		# предикат успешного выполнения метода API
		[scriptblock]
		$IsSuccessPredicate = { [bool]$_.action.status.success }
	,
		# предикат ошибки при выполнении метода API. Если ни один из предикатов не вернёт $true - генерируем неизвестную ошибку
		[scriptblock]
		$IsFailurePredicate = { [bool]$_.action.status.error }
	,
		# фильтр обработки результата. Если фильтр не задан - функция не возвращает результат
		[scriptblock]
		$ResultFilter = {}
	,
		# Шаблон сообщения об успешном выполнении API
		[string]
		$SuccessMsg = "Метод API $method успешно выполнен для домена $DomainName."
	,
		# Шаблон сообщения об ошибке вызова API
		[string]
		$FailureMsg = "Ошибка при вызове метода API $method для домена $DomainName"
	,
		# Фильтр обработки результата для выделения сообщения об ошибке
		[scriptblock]
		$FailureMsgFilter = { $_.action.status.error.'#text' }
	,
		# Шаблон сообщения о недиагностируемой ошибке вызова API
		[string]
		$UnknownErrorMsg = "Неизвестная ошибка при вызове метода API $method для домена $DomainName."
	)

	if ( -not $Token ) {
		$Token = Get-Token $DomainName;
	};
	switch ( $HttpMethod ) {
		( [System.Net.WebRequestMethods+HTTP]::Get ) {
			$escapedParams = (
				$Params `
				| Set-ObjectProperty 'token' $Token -PassThru `
				| Set-ObjectProperty 'domain' $DomainName -PassThru `
				| ConvertFrom-Dictionary `
				| % { "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" } `
			) -join '&';
			$apiURI = [System.Uri]"$APIRoot/$method.xml?$escapedParams";
			$wc = New-Object System.Net.WebClient;
			$WebMethodFunctional = {
				$wc.DownloadString( $apiURI );
			};
		}
		( [System.Net.WebRequestMethods+HTTP]::Post ) {
			$apiURI = [System.Uri] ( "$APIRoot/$method.xml" );
			
			$WebMethodFunctional = {
				$wreq = [System.Net.WebRequest]::Create( $apiURI );
				$wreq.Method = $HttpMethod;
				$boundary = "##params-boundary##";
				$wreq.ContentType = "multipart/form-data; boundary=$boundary";
				$reqStream = $wreq.GetRequestStream();
				$writer = New-Object System.IO.StreamWriter( $reqStream );
				$writer.AutoFlush = $true;
				
				$Params `
				| Set-ObjectProperty 'token' $Token -PassThru `
				| Set-ObjectProperty 'domain' $DomainName -PassThru `
				| ConvertFrom-Dictionary `
				| % {
					if ( $_.Value -is [System.IO.FileInfo] ) {
						$writer.Write( @"
--$boundary
Content-Disposition: form-data; name="$($_.Key)"; filename="$($_.Value.Name)"
Content-Type: $(Get-MIME ($_.Value))
Content-Transfer-Encoding: binary


"@
						);
						$fs = New-Object System.IO.FileStream (
							$_.Value.FullName,
							[System.IO.FileMode]::Open,
							[System.IO.FileAccess]::Read,
							[system.IO.FileShare]::Read
						);
						try {
							$fs.CopyTo( $reqStream );
						} finally {
							$fs.Close();
							$fs.Dispose();
						};
						$writer.WriteLine();
					} else {
						$writer.Write( @"
--$boundary
Content-Disposition: form-data; name="$($_.Key)"

$($_.Value)

"@
						);
					};
				};
				$writer.Write( @"
--$boundary--

"@ );
				$writer.Close();
				$reqStream.Close();

				$wres = $wreq.GetResponse();
				$resStream = $wres.GetResponseStream();
				$reader = New-Object System.IO.StreamReader ( $resStream );
				$responseFromServer = [string]( $reader.ReadToEnd() );

				$reader.Close();
				$resStream.Close();
				$wres.Close();				

				$responseFromServer;
			};
		}
	};
	if ( $PSCmdlet.ShouldProcess( $DomainName, "Yandex.API.PDD::$method" ) ) {
		try {
			Write-Debug "Вызов API $method для домена $($DomainName): $($apiURI.AbsoluteUri)";
			$resString = ( [string] ( & $WebMethodFunctional ) );
			Write-Debug @"
Ответ API ${method}:
$($resString)
"@
			$res = [xml] $resString;
		
			if ( (
				Invoke-Command `
					-ScriptBlock { $input | % -Process $IsSuccessPredicate } `
					-InputObject $res `
					-ErrorAction Continue `
			) ) {
				Write-Verbose $SuccessMsg;
				Invoke-Command `
					-ScriptBlock { $input | % -Process $ResultFilter } `
					-InputObject $res `
				;
			} elseif ( (
				Invoke-Command `
					-ScriptBlock { $input | % -Process $IsFailurePredicate } `
					-InputObject $res `
					-ErrorAction Continue `
			) ) {
				Write-Verbose "Ответ API ${method}: $($resString).";
				$ErrorMsg = Invoke-Command `
					-ScriptBlock { $input | % -Process $FailureMsgFilter } `
					-InputObject $res `
					-ErrorAction SilentlyContinue `
				;
				Write-Error `
					-Message "$FailureMsg - ($ErrorMsg)" `
					-Category CloseError `
					-CategoryActivity 'Yandex.API' `
					-RecommendedAction 'Проверьте правильность указания домена и Ваши права на домен.' `
				;
			} else { # недиагностируемая ошибка вызова API
				Write-Verbose "Ответ API ${method}: $($resString).";
				Write-Error `
					-Message $UnknownErrorMsg `
					-Category InvalidResult `
					-CategoryActivity 'Yandex.API' `
					-RecommendedAction 'Проверьте параметры.' `
				;
			};
		} catch {
			Write-Verbose "Ответ API ${method}: $($resString).";
			Write-Error `
				-Message "$UnknownErrorMsg ($($_.Exception.Message))." `
				-Category InvalidOperation `
				-CategoryActivity 'Yandex.API' `
			;
		};
	};
}

function Register-Domain {
	<#
		.Component
			API Яндекс.Почты для доменов
		.Synopsis
			Метод (обёртка над Яндекс.API reg_domain) предназначен для регистрации домена на сервисах Яндекса.
		.Description
			Метод регистрирует домен на сервисах Яндекса.
			Если домен уже подключен, то метод reg_domain не выполняет никаких действий.
		.Link
			[reg_domain]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_reg_domain.xml
		.Example
			$token = Get-Token -DomainName 'maindomain.ru';	'domain1.ru', 'domain2.ru' | Register-Domain -Token $token;
			Регистрация нескольких доменов
	#>

	[CmdletBinding(
		SupportsShouldProcess=$true,
		ConfirmImpact="Medium"
	)]
	
	param (
		# имя домена для регистрации на сервисах Яндекса
		[Parameter(
			Mandatory=$true,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true
		)]
		[string]
		[ValidateScript( { $_ -match "^$($reDomain)$" } )]
		[Alias("domain_name")]
		[Alias("Domain")]
		$DomainName
	,
		# авторизационный токен, полученный через Get-Token, для другого, уже зарегистрированного домена
		[Parameter(
			Mandatory=$true
		)]
		[string]
		[ValidateNotNullOrEmpty()]
		$Token
	)

	process {
		Invoke-API `
			-method 'api/reg_domain' `
			-Token $Token `
			-DomainName $DomainName `
			-SuccessMsg "Домен $($DomainName) успешно подключен." `
			-ResultFilter { 
				$_.action.domains.domain `
				| Select-Object -Property `
					@{Name='DomainName'; Expression={$_.name}}`
					, @{Name='SecretName'; Expression={$_.secret_name.'#text'}} `
					, @{Name='SecretValue'; Expression={$_.secret_value.'#text'}} `
			} `
			-Debug:$DebugPreference `
			-Verbose:$VerbosePreference `
			-Confirm:$VerbosePreference `
			-WhatIf:$WhatIfPreference `
		;
	}
}

function Remove-Domain {
	<#
		.Component
			API Яндекс.Почты для доменов
		.Synopsis
			Метод (обёртка над Яндекс.API del_domain) предназначен для отключения домена от Яндекс.Почта для доменов.
		.Description
			Метод позволяет отключить домен.
			Отключенный домен перестает выводиться в списке доменов. После отключения домен можно подключить заново.
			Отключение домена не влечет за собой изменения MX-записей. MX-записи нужно устанавливать отдельно на
			DNS-серверах, куда делегирован домен.
		.Link
			[del_domain]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_del_domain.xml
		.Example
			Remove-Domain -DomainName 'test.ru';
	#>

	[CmdletBinding(
		SupportsShouldProcess=$true,
		ConfirmImpact="High"
	)]
	
	param (
		# имя домена для регистрации на сервисах Яндекса
		[Parameter(
			Mandatory=$true,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true
		)]
		[string]
		[ValidateScript( { $_ -match "^$($reDomain)$" } )]
		[Alias("domain_name")]
		[Alias("Domain")]
		$DomainName
	,
		# передавать домены далее по конвейеру или нет
		[switch]
		$PassThru
	)

	process {
		Invoke-API `
			-method 'api/del_domain' `
			-DomainName $DomainName `
			-SuccessMsg "Домен $($DomainName) успешно отключен." `
			-Debug:$DebugPreference `
			-Verbose:$VerbosePreference `
			-Confirm:$VerbosePreference `
			-WhatIf:$WhatIfPreference `
		;
		if ( $PassThru ) { $input };
	}
}

function Set-Logo {
	<#
		.Component
			API Яндекс.Почты для доменов
		.Synopsis
			Метод (обёртка над Яндекс.API add_logo) предназначен для установки логотипа для домена.
		.Description
			Метод позволяет установить логотип домена.
			Поддерживаются графические файлы форматов jpg, gif, png размером
			до 2 Мбайт.
		.Link
			[add_logo]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_add_logo.xml
		.Example
			Set-Logo -DomainName 'yourdomain.ru' -Path 'c:\work\logo.png';
			Установка логотипа для домена yourdomain.ru
	#>

	[CmdletBinding(
		SupportsShouldProcess=$true,
		ConfirmImpact="Low"
	)]
	
	param (
		# имя домена - любой из доменов, зарегистрированных под Вашей учётной записью на сервисах Яндекса
		[Parameter(
			Mandatory=$false,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true
		)]
		[string]
		[ValidateScript( { $_ -match "^$($reDomain)$" } )]
		[Alias("domain_name")]
		[Alias("Domain")]
		$DomainName
	,
		# путь к файлу логотипа.
		# Поддерживаются графические файлы форматов jpg, gif, png размером до 2 Мбайт
		[Parameter(
			Mandatory=$true,
			ValueFromPipelineByPropertyName=$true
		)]
		[System.IO.FileInfo]
		$Path
	,
		# передавать домены далее по конвейеру или нет
		[switch]
		$PassThru
	)

	process {
		Invoke-API `
			-HttpMethod 'POST' `
			-method 'api/add_logo' `
			-DomainName $DomainName `
			-Params @{
				file = $Path
			} `
			-IsSuccessPredicate { [bool]$_.action.domains.domain.logo.'action-status'.get_item('success') } `
			-SuccessMsg "Логотип для домена $($DomainName) установлен." `
			-IsFailurePredicate { [bool]$_.action.domains.domain.logo.'action-status'.get_item('error') } `
			-FailureMsgFilter { $_.action.domains.domain.logo.'action-status'.error } `
			-Debug:$DebugPreference `
			-Verbose:$VerbosePreference `
			-Confirm:$VerbosePreference `
			-WhatIf:$WhatIfPreference `
		;
		if ( $PassThru ) { $input };
	}
}

function Remove-Logo {
	<#
		.Component
			API Яндекс.Почты для доменов
		.Synopsis
			Метод (обёртка над Яндекс.API del_logo) предназначен для удаления логотипа домена.
		.Description
			Метод позволяет удалить логотип домена.
		.Link
			[del_logo]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_del_logo.xml#domain-control_del_logo
		.Example
			Remove-Logo -DomainName 'yourdomain.ru';
			Удаление логотипа для домена yourdomain.ru.
		.Example
			'domain1.ru', 'domain2.ru' | Remove-Logo;
			Удаление логотипа для нескольких доменов.
	#>

	[CmdletBinding(
		SupportsShouldProcess=$true,
		ConfirmImpact="Medium"
	)]
	
	param (
		# имя домена - любой из доменов, зарегистрированных под Вашей учётной записью на сервисах Яндекса
		[Parameter(
			Mandatory=$false,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true
		)]
		[string]
		[ValidateScript( { $_ -match "^$($reDomain)$" } )]
		[Alias("domain_name")]
		[Alias("Domain")]
		$DomainName
	,
		# передавать домены далее по конвейеру или нет
		[switch]
		$PassThru
	)

	process {
		Invoke-API `
			-method 'api/del_logo' `
			-DomainName $DomainName `
			-SuccessMsg "Логотип для домена $($DomainName) удалён." `
			-Debug:$DebugPreference `
			-Verbose:$VerbosePreference `
			-Confirm:$VerbosePreference `
			-WhatIf:$WhatIfPreference `
		;
		if ( $PassThru ) { $input };
	}
}

function Register-Admin {
	<#
		.Component
			API Яндекс.Почты для доменов
		.Synopsis
			Метод (обёртка над Яндекс.API set_admin) предназначен для указания логина
			дополнительного администратора домена.
		.Description
			Метод (обёртка над Яндекс.API set_admin) предназначен для указания логина
			дополнительного администратора домена.
			В качестве логина может быть указан только логин на @yandex.ru, но не на домене,
			делегированном на Яндекс.
		.Link
			[set_admin]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_add_admin.xml
		.Example
			Register-Admin -DomainName 'csm.nov.ru' -Credential 'sergei.e.gushchin';
	#>

	[CmdletBinding(
		SupportsShouldProcess=$true,
		ConfirmImpact="High"
	)]
	
	param (
		# имя домена, зарегистрированного на сервисах Яндекса
		[Parameter(
			Mandatory=$false
			, ValueFromPipeline=$true
			, ValueFromPipelineByPropertyName=$true
		)]
		[string]
		[ValidateScript( { $_ -match "^$($reDomain)$" } )]
		[Alias("domain_name")]
		[Alias("Domain")]
		$DomainName
	,
		# Логин дополнительного администратора на @yandex.ru
		[Parameter(
			Mandatory=$true
			, Position=0
			, ValueFromRemainingArguments=$true
		)]
		[string]
		[ValidateNotNullOrEmpty()]
		[Alias("Admin")]
		[Alias("Name")]
		[Alias("Login")]
		$Credential
	,
		# передавать домены далее по конвейеру или нет
		[switch]
		$PassThru
	)

	process {
		Invoke-API `
			-method 'api/multiadmin/add_admin' `
			-DomainName $DomainName `
			-Params @{
				login = $Credential
			} `
			-IsSuccessPredicate { [bool]$_.SelectSingleNode('action/domain/status/success') } `
			-IsFailurePredicate { [bool]$_.SelectSingleNode('action/domain/status/error') } `
			-FailureMsgFilter { $_.action.domain.status.error } `
			-Debug:$DebugPreference `
			-Verbose:$VerbosePreference `
			-Confirm:$VerbosePreference `
			-WhatIf:$WhatIfPreference `
		;
		if ( $PassThru ) { $input };
	}
}

function Remove-Admin {
	<#
		.Component
			API Яндекс.Почты для доменов
		.Synopsis
			Метод (обёртка над Яндекс.API del_admin) предназначен для удаления
			дополнительного администратора домена.
		.Description
			Метод (обёртка над Яндекс.API del_admin) предназначен для удаления
			дополнительного администратора домена.
			В качестве логина может быть указан только логин на @yandex.ru, но
			не на домене, делегированном на Яндекс.
		.Link
			[del_admin]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_del_admin.xml
		.Example
			Remove-Admin -DomainName 'csm.nov.ru' -Credential 'sergei.e.gushchin';
	#>

	[CmdletBinding(
		SupportsShouldProcess=$true,
		ConfirmImpact="High"
	)]
	
	param (
		# имя домена, зарегистрированного на сервисах Яндекса
		[Parameter(
			Mandatory=$false
			, ValueFromPipeline=$true
			, ValueFromPipelineByPropertyName=$true
		)]
		[string]
		[ValidateScript( { $_ -match "^$($reDomain)$" } )]
		[Alias("domain_name")]
		[Alias("Domain")]
		$DomainName
	,
		# Логин дополнительного администратора на @yandex.ru
		[Parameter(
			Mandatory=$true
			, Position=0
			, ValueFromRemainingArguments=$true
		)]
		[string]
		[ValidateNotNullOrEmpty()]
		[Alias("Admin")]
		[Alias("Name")]
		[Alias("Login")]
		$Credential
	,
		# передавать домены далее по конвейеру или нет
		[switch]
		$PassThru
	)

	process {
		Invoke-API `
			-method 'api/multiadmin/del_admin' `
			-DomainName $DomainName `
			-Params @{
				login = $Credential
			} `
			-IsSuccessPredicate { [bool]$_.SelectSingleNode('action/domain/status/success') } `
			-IsFailurePredicate { [bool]$_.SelectSingleNode('action/domain/status/error') } `
			-FailureMsgFilter { $_.action.domain.status.error } `
			-Debug:$DebugPreference `
			-Verbose:$VerbosePreference `
			-Confirm:$VerbosePreference `
			-WhatIf:$WhatIfPreference `
		;
		if ( $PassThru ) { $input };
	}
}

function Get-Admin {
	<#
		.Component
			API Яндекс.Почты для доменов
		.Synopsis
			Метод (обёртка над Яндекс.API get_admins). Метод позволяет получить список
			дополнительных администраторов домена.
		.Description
			Метод (обёртка над Яндекс.API get_admins). Метод позволяет получить список
			дополнительных администраторов домена.
		.Link
			[get_admins]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_get_admins.xml
		.Example
			Get-Admin -DomainName 'csm.nov.ru';
	#>

	[CmdletBinding(
		ConfirmImpact="Low"
	)]
	
	param (
		# имя домена, зарегистрированного на сервисах Яндекса
		[Parameter(
			Mandatory=$false,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true
		)]
		[string]
		[ValidateScript( { $_ -match "^$($reDomain)$" } )]
		[Alias("domain_name")]
		[Alias("Domain")]
		$DomainName
	)

	process {
		Invoke-API `
			-method 'api/multiadmin/get_admins' `
			-DomainName $DomainName `
			-IsSuccessPredicate { [bool]$_.SelectSingleNode('action/domain/status/success') } `
			-IsFailurePredicate { [bool]$_.SelectSingleNode('action/domain/status/error') } `
			-FailureMsgFilter { $_.action.domain.status.error } `
			-ResultFilter { 
				$_.SelectNodes('action/domain/other-admins/login') `
				| %{ $_.'#text'; } `
			} `
			-Debug:$DebugPreference `
			-Verbose:$VerbosePreference `
			-Confirm:$VerbosePreference `
		;
	}
}

Export-ModuleMember `
	Get-Token `
	, Invoke-API `
	, Register-Domain `
	, Remove-Domain `
	, Set-Logo `
	, Remove-Logo `
	, Register-Admin `
	, Remove-Admin `
	, Get-Admin `
;
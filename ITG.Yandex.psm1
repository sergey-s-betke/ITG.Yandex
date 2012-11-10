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
			Синтаксис запроса:
				https://pddimp.yandex.ru/get_token.xml ? domain_name =<имя домена>
			Получение токена для домена yourdomain.ru:
				https://pddimp.yandex.ru/get_token.xml?domain_name=yourdomain.ru
			Формат ответа
			Если ошибок нет, метод возвращает <ok token="..."/>, в противном случае - <error reason='...'/>.
			Но данная функция возвращает непосредственно токен, либо генерирует исключение.
		.Outputs
			[System.String] - собственно token
		.Link
			http://api.yandex.ru/pdd/doc/api-pdd/reference/get-token.xml#get-token
		.Example
			Получение токена для домена yourdomain.ru:
			$token = Get-Token -DomainName 'yourdomain.ru';
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
	)

	process {
		$get_tokenURI = [System.Uri]"$APIRoot/get_token.xml?domain_name=$( [System.Uri]::EscapeDataString( $DomainName ) )";
		$get_tokenAuthURI = [System.Uri]"https://passport.yandex.ru/passport?mode=auth&msg=pdd&retpath=$( [System.Uri]::EscapeDataString( $get_tokenURI ) )";

		try {
			Write-Verbose 'Создаём экземпляр InternetExplorer.';
			$ie = New-Object -Comobject InternetExplorer.application;
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
				-or (-not ([System.Uri]$ie.LocationURL).IsBaseOf( $get_tokenURI ) ) `
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
	}
};

Set-Variable `
	-Name 'TokenForDomain' `
	-Value (@{}) `
;

function Get-CachedToken {
	<#
		.Component
			API Яндекс
		.Synopsis
			Метод - проверяет действительность переданного токена (на самом деле - лишь сравнивает с пустой
			строкой, и в случае недействительности запрашивает его через Get-Token.
		.Description
			Метод - проверяет действительность переданного токена (на самом деле - лишь сравнивает с пустой
			строкой, и в случае недействительности запрашивает его через Get-Token.
		.Outputs
			[System.String] - собственно token
		.Link
			Get-Token
		.Example
			$token = Get-CachedToken -DomainName 'yourdomain.ru';
	#>

	[CmdletBinding()]
	
	param (
		# имя домена - любой из доменов, зарегистрированных под Вашей учётной записью на сервисах Яндекса
		[Parameter(
			Position = 0
		)]
		[string]
		[ValidateScript( { $_ -match "^$($reDomain)$" } )]
		[Alias("domain_name")]
		[Alias("Domain")]
		$DomainName
	)

	if ( $TokenForDomain.ContainsKey( $DomainName ) ) {
		return $TokenForDomain.$DomainName;
	} else {
		return $TokenForDomain.$DomainName = Get-Token -DomainName $DomainName;
	};
};

function Invoke-API {
	<#
		.Component
			API Яндекс
		.Synopsis
			Обёртка для вызовов методов API Яндекс.
		.Description
			Обёртка для вызовов методов API Яндекс.
		.Outputs
			[xml] - Результат, возвращённый API.
	#>

	[CmdletBinding(
		SupportsShouldProcess=$true,
		ConfirmImpact="Medium"
	)]
	
	param (
		# HTTP метод вызова API.
		[Parameter(
			Mandatory=$false
		)]
		[string]
		$HttpMethod = [System.Net.WebRequestMethods+HTTP]::Get
	,
		# авторизационный токен, полученный через Get-Token.
		[Parameter(
		)]
		[string]
		$Token
	,
		# метод API - компонент url.
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
		# фильтр обработки результата. Если фильтр не задан - функция не возвращает результат.
		[scriptblock]
		$ResultFilter = {}
	,
		# Шаблон сообщения об успешном выполнении API.
		[string]
		$SuccessMsg = "Метод API $method успешно выполнен для домена $DomainName."
	,
		# Шаблон сообщения об ошибке вызова API.
		[string]
		$FailureMsg = "Ошибка при вызове метода API $method для домена $DomainName"
	,
		# Фильтр обработки результата для выделения сообщения об ошибке.
		[scriptblock]
		$FailureMsgFilter = { $_.action.status.error.'#text' }
	,
		# Шаблон сообщения о недиагностируемой ошибке вызова API.
		[string]
		$UnknownErrorMsg = "Неизвестная ошибка при вызове метода API $method для домена $DomainName."
	)

	if ( -not $Token ) {
		$Token = Get-CachedToken $DomainName;
	};
	$Params.Add( 'token', $Token );
	$Params.Add( 'domain', $DomainName );
	
	switch ( $HttpMethod ) {
		( [System.Net.WebRequestMethods+HTTP]::Get ) {
			$escapedParams = (
				$Params.keys `
				| % { "$_=$([System.Uri]::EscapeDataString($Params.$_))" } `
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
				
				foreach( $param in $Params.keys ) {
					if ( $Params.$param -is [System.IO.FileInfo] ) {
						$writer.Write( @"
--$boundary
Content-Disposition: form-data; name="$param"; filename="$($Params.$param.Name)"
Content-Type: $(Get-MIME ($Params.$param))
Content-Transfer-Encoding: binary


"@
						);
						$fs = New-Object System.IO.FileStream (
							$Params.$param.FullName,
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
Content-Disposition: form-data; name="$param"

$($Params.$param)

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
			Write-Verbose "Вызов API $method для домена $($DomainName): $apiURI.";
			$resString = ( [string] ( & $WebMethodFunctional ) );
			Write-Debug "Ответ API $method: $($resString).";
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
				Write-Verbose "Ответ API $method: $($resString).";
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
				Write-Verbose "Ответ API $method: $($resString).";
				Write-Error `
					-Message $UnknownErrorMsg `
					-Category InvalidResult `
					-CategoryActivity 'Yandex.API' `
					-RecommendedAction 'Проверьте параметры.' `
				;
			};
		} catch {
			Write-Verbose "Ответ API $method: $($resString).";
			Write-Error `
				-Message "$UnknownErrorMsg ($($_.Exception.Message))." `
				-Category InvalidOperation `
				-CategoryActivity 'Yandex.API' `
			;
		};
	};
}

Export-ModuleMember `
	Get-Token `
	, Get-CachedToken `
	, Invoke-API `
;
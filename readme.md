ITG.Yandex
==========

Обёртки для API Яндекс - базовый модуль для поддержки API различных сервисов Яндекса.

Версия модуля: **1.1.5**

Функции модуля
--------------

### Admin

#### Обзор [Get-Admin][]

Метод (обёртка над Яндекс.API [get_admins][]). Метод позволяет получить список
дополнительных администраторов домена.

	Get-Admin [[-DomainName] <String>] [-WhatIf] [-Confirm] <CommonParameters>

Подробнее - [Get-Admin][].

#### Обзор [Register-Admin][]

Метод (обёртка над Яндекс.API [set_admin][]) предназначен для указания логина
дополнительного администратора домена.

	Register-Admin [-DomainName <String>] [-Credential] <String> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

Подробнее - [Register-Admin][].

#### Обзор [Remove-Admin][]

Метод (обёртка над Яндекс.API [del_admin][]) предназначен для удаления
дополнительного администратора домена.

	Remove-Admin [-DomainName <String>] [-Credential] <String> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

Подробнее - [Remove-Admin][].

### API

#### Обзор [Invoke-API][]

Обёртка для вызовов методов API Яндекс. Предназначена для внутреннего использования.

	Invoke-API [[-HttpMethod] <String>] [[-Token] <String>] [-method] <String> [-DomainName] <String> [[-Params] <IDictionary>] [[-IsSuccessPredicate] <ScriptBlock>] [[-IsFailurePredicate] <ScriptBlock>] [[-ResultFilter] <ScriptBlock>] [[-SuccessMsg] <String>] [[-FailureMsg] <String>] [[-FailureMsgFilter] <ScriptBlock>] [[-UnknownErrorMsg] <String>] [-WhatIf] [-Confirm] <CommonParameters>

Подробнее - [Invoke-API][].

### Domain

#### Обзор [Register-Domain][]

Метод (обёртка над Яндекс.API [reg_domain][]) предназначен для регистрации домена на сервисах Яндекса.

	Register-Domain [-DomainName] <String> [-Token] <String> [-WhatIf] [-Confirm] <CommonParameters>

Подробнее - [Register-Domain][].

#### Обзор [Remove-Domain][]

Метод (обёртка над Яндекс.API [del_domain][]) предназначен для отключения домена от Яндекс.Почта для доменов.

	Remove-Domain [-DomainName] <String> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

Подробнее - [Remove-Domain][].

### Logo

#### Обзор [Remove-Logo][]

Метод (обёртка над Яндекс.API [del_logo][]) предназначен для удаления логотипа домена.

	Remove-Logo [[-DomainName] <String>] [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

Подробнее - [Remove-Logo][].

#### Обзор [Set-Logo][]

Метод (обёртка над Яндекс.API [add_logo][]) предназначен для установки логотипа для домена.

	Set-Logo [[-DomainName] <String>] [-Path] <FileInfo> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

Подробнее - [Set-Logo][].

### Token

#### Обзор [Get-Token][]

Метод (обёртка над Яндекс.API [get_token][]) предназначен для получения авторизационного токена.

	Get-Token [-DomainName] <String> [-NoCache] <CommonParameters>

Подробнее - [Get-Token][].

Подробное описание функций модуля
---------------------------------

#### Get-Admin

Метод (обёртка над Яндекс.API [get_admins][]). Метод позволяет получить список
дополнительных администраторов домена.

##### Синтаксис

	Get-Admin [[-DomainName] <String>] [-WhatIf] [-Confirm] <CommonParameters>

##### Компонент

API Яндекс.Почты для доменов

##### Параметры

- `DomainName <String>`
        имя домена, зарегистрированного на сервисах Яндекса

        Требуется? false
        Позиция? 1
        Значение по умолчанию
        Принимать входные данные конвейера?true (ByValue, ByPropertyName)
        Принимать подстановочные знаки?

- `WhatIf [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `Confirm [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `<CommonParameters>`
        Данный командлет поддерживает общие параметры: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer и OutVariable. Для получения дополнительных сведений введите
        "get-help [about_CommonParameters][]".



##### Примеры использования

1. Пример 1.

		Get-Admin -DomainName 'csm.nov.ru';

##### Связанные ссылки

- [get_admins][]

#### Register-Admin

Метод (обёртка над Яндекс.API [set_admin][]) предназначен для указания логина
дополнительного администратора домена.
В качестве логина может быть указан только логин на @yandex.ru, но не на домене,
делегированном на Яндекс.

##### Синтаксис

	Register-Admin [-DomainName <String>] [-Credential] <String> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

##### Компонент

API Яндекс.Почты для доменов

##### Параметры

- `DomainName <String>`
        имя домена, зарегистрированного на сервисах Яндекса

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?true (ByValue, ByPropertyName)
        Принимать подстановочные знаки?

- `Credential <String>`
        Логин дополнительного администратора на @yandex.ru

        Требуется? true
        Позиция? 1
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `PassThru [<SwitchParameter>]`
        передавать домены далее по конвейеру или нет

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `WhatIf [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `Confirm [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `<CommonParameters>`
        Данный командлет поддерживает общие параметры: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer и OutVariable. Для получения дополнительных сведений введите
        "get-help [about_CommonParameters][]".



##### Примеры использования

1. Пример 1.

		Register-Admin -DomainName 'csm.nov.ru' -Credential 'sergei.e.gushchin';

##### Связанные ссылки

- [set_admin][]

#### Remove-Admin

Метод (обёртка над Яндекс.API [del_admin][]) предназначен для удаления
дополнительного администратора домена.
В качестве логина может быть указан только логин на @yandex.ru, но
не на домене, делегированном на Яндекс.

##### Синтаксис

	Remove-Admin [-DomainName <String>] [-Credential] <String> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

##### Компонент

API Яндекс.Почты для доменов

##### Параметры

- `DomainName <String>`
        имя домена, зарегистрированного на сервисах Яндекса

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?true (ByValue, ByPropertyName)
        Принимать подстановочные знаки?

- `Credential <String>`
        Логин дополнительного администратора на @yandex.ru

        Требуется? true
        Позиция? 1
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `PassThru [<SwitchParameter>]`
        передавать домены далее по конвейеру или нет

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `WhatIf [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `Confirm [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `<CommonParameters>`
        Данный командлет поддерживает общие параметры: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer и OutVariable. Для получения дополнительных сведений введите
        "get-help [about_CommonParameters][]".



##### Примеры использования

1. Пример 1.

		Remove-Admin -DomainName 'csm.nov.ru' -Credential 'sergei.e.gushchin';

##### Связанные ссылки

- [del_admin][]

#### Invoke-API

Обёртка для вызовов методов API Яндекс. Предназначена для внутреннего использования.

##### Синтаксис

	Invoke-API [[-HttpMethod] <String>] [[-Token] <String>] [-method] <String> [-DomainName] <String> [[-Params] <IDictionary>] [[-IsSuccessPredicate] <ScriptBlock>] [[-IsFailurePredicate] <ScriptBlock>] [[-ResultFilter] <ScriptBlock>] [[-SuccessMsg] <String>] [[-FailureMsg] <String>] [[-FailureMsgFilter] <ScriptBlock>] [[-UnknownErrorMsg] <String>] [-WhatIf] [-Confirm] <CommonParameters>

##### Компонент

API Яндекс

##### Передаваемые по конвейеру данные

[xml] - Результат, возвращённый API.

##### Параметры

- `HttpMethod <String>`
        HTTP метод вызова API

        Требуется? false
        Позиция? 1
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `Token <String>`
        авторизационный токен, полученный через [Get-Token][]

        Требуется? false
        Позиция? 2
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `method <String>`
        метод API - компонент url

        Требуется? true
        Позиция? 3
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `DomainName <String>`
        имя домена для регистрации на сервисах Яндекса

        Требуется? true
        Позиция? 4
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `Params <IDictionary>`
        коллекция параметров метода API

        Требуется? false
        Позиция? 5
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `IsSuccessPredicate <ScriptBlock>`
        предикат успешного выполнения метода API

        Требуется? false
        Позиция? 6
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `IsFailurePredicate <ScriptBlock>`
        предикат ошибки при выполнении метода API. Если ни один из предикатов не вернёт $true - генерируем неизвестную оши
        бку

        Требуется? false
        Позиция? 7
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `ResultFilter <ScriptBlock>`
        фильтр обработки результата. Если фильтр не задан - функция не возвращает результат

        Требуется? false
        Позиция? 8
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `SuccessMsg <String>`
        Шаблон сообщения об успешном выполнении API

        Требуется? false
        Позиция? 9
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `FailureMsg <String>`
        Шаблон сообщения об ошибке вызова API

        Требуется? false
        Позиция? 10
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `FailureMsgFilter <ScriptBlock>`
        Фильтр обработки результата для выделения сообщения об ошибке

        Требуется? false
        Позиция? 11
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `UnknownErrorMsg <String>`
        Шаблон сообщения о недиагностируемой ошибке вызова API

        Требуется? false
        Позиция? 12
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `WhatIf [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `Confirm [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `<CommonParameters>`
        Данный командлет поддерживает общие параметры: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer и OutVariable. Для получения дополнительных сведений введите
        "get-help [about_CommonParameters][]".



#### Register-Domain

Метод регистрирует домен на сервисах Яндекса.
Если домен уже подключен, то метод [reg_domain][] не выполняет никаких действий.

##### Синтаксис

	Register-Domain [-DomainName] <String> [-Token] <String> [-WhatIf] [-Confirm] <CommonParameters>

##### Компонент

API Яндекс.Почты для доменов

##### Параметры

- `DomainName <String>`
        имя домена для регистрации на сервисах Яндекса

        Требуется? true
        Позиция? 1
        Значение по умолчанию
        Принимать входные данные конвейера?true (ByValue, ByPropertyName)
        Принимать подстановочные знаки?

- `Token <String>`
        авторизационный токен, полученный через [Get-Token][], для другого, уже зарегистрированного домена

        Требуется? true
        Позиция? 2
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `WhatIf [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `Confirm [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `<CommonParameters>`
        Данный командлет поддерживает общие параметры: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer и OutVariable. Для получения дополнительных сведений введите
        "get-help [about_CommonParameters][]".



##### Примеры использования

1. Регистрация нескольких доменов

		$token = Get-Token -DomainName 'maindomain.ru';	'domain1.ru', 'domain2.ru' | Register-Domain -Token $token;

##### Связанные ссылки

- [reg_domain][]

#### Remove-Domain

Метод позволяет отключить домен.
Отключенный домен перестает выводиться в списке доменов. После отключения домен можно подключить заново.
Отключение домена не влечет за собой изменения MX-записей. MX-записи нужно устанавливать отдельно на
DNS-серверах, куда делегирован домен.

##### Синтаксис

	Remove-Domain [-DomainName] <String> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

##### Компонент

API Яндекс.Почты для доменов

##### Параметры

- `DomainName <String>`
        имя домена для регистрации на сервисах Яндекса

        Требуется? true
        Позиция? 1
        Значение по умолчанию
        Принимать входные данные конвейера?true (ByValue, ByPropertyName)
        Принимать подстановочные знаки?

- `PassThru [<SwitchParameter>]`
        передавать домены далее по конвейеру или нет

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `WhatIf [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `Confirm [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `<CommonParameters>`
        Данный командлет поддерживает общие параметры: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer и OutVariable. Для получения дополнительных сведений введите
        "get-help [about_CommonParameters][]".



##### Примеры использования

1. Пример 1.

		Remove-Domain -DomainName 'test.ru';

##### Связанные ссылки

- [del_domain][]

#### Remove-Logo

Метод позволяет удалить логотип домена.

##### Синтаксис

	Remove-Logo [[-DomainName] <String>] [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

##### Компонент

API Яндекс.Почты для доменов

##### Параметры

- `DomainName <String>`
        имя домена - любой из доменов, зарегистрированных под Вашей учётной записью на сервисах Яндекса

        Требуется? false
        Позиция? 1
        Значение по умолчанию
        Принимать входные данные конвейера?true (ByValue, ByPropertyName)
        Принимать подстановочные знаки?

- `PassThru [<SwitchParameter>]`
        передавать домены далее по конвейеру или нет

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `WhatIf [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `Confirm [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `<CommonParameters>`
        Данный командлет поддерживает общие параметры: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer и OutVariable. Для получения дополнительных сведений введите
        "get-help [about_CommonParameters][]".



##### Примеры использования

1. Удаление логотипа для домена yourdomain.ru.

		Remove-Logo -DomainName 'yourdomain.ru';

2. Удаление логотипа для нескольких доменов.

		'domain1.ru', 'domain2.ru' | Remove-Logo;

##### Связанные ссылки

- [del_logo][]

#### Set-Logo

Метод позволяет установить логотип домена.
Поддерживаются графические файлы форматов jpg, gif, png размером
до 2 Мбайт.

##### Синтаксис

	Set-Logo [[-DomainName] <String>] [-Path] <FileInfo> [-PassThru] [-WhatIf] [-Confirm] <CommonParameters>

##### Компонент

API Яндекс.Почты для доменов

##### Параметры

- `DomainName <String>`
        имя домена - любой из доменов, зарегистрированных под Вашей учётной записью на сервисах Яндекса

        Требуется? false
        Позиция? 1
        Значение по умолчанию
        Принимать входные данные конвейера?true (ByValue, ByPropertyName)
        Принимать подстановочные знаки?

- `Path <FileInfo>`
        путь к файлу логотипа.
        Поддерживаются графические файлы форматов jpg, gif, png размером до 2 Мбайт

        Требуется? true
        Позиция? 2
        Значение по умолчанию
        Принимать входные данные конвейера?true (ByPropertyName)
        Принимать подстановочные знаки?

- `PassThru [<SwitchParameter>]`
        передавать домены далее по конвейеру или нет

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `WhatIf [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `Confirm [<SwitchParameter>]`

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `<CommonParameters>`
        Данный командлет поддерживает общие параметры: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer и OutVariable. Для получения дополнительных сведений введите
        "get-help [about_CommonParameters][]".



##### Примеры использования

1. Установка логотипа для домена yourdomain.ru

		Set-Logo -DomainName 'yourdomain.ru' -Path 'c:\work\logo.png';

##### Связанные ссылки

- [add_logo][]

#### Get-Token

Метод [get_token][] предназначен для получения авторизационного токена.
Авторизационный токен используется для активации API Яндекс.Почты для доменов. Получать токен
нужно только один раз. Чтобы получить токен, следует иметь подключенный домен, авторизоваться
его администратором.

Данная функция возвращает непосредственно токен, либо генерирует исключение.

##### Синтаксис

	Get-Token [-DomainName] <String> [-NoCache] <CommonParameters>

##### Компонент

API Яндекс

##### Передаваемые по конвейеру данные

[System.String] - собственно token

##### Параметры

- `DomainName <String>`
        имя домена - любой из доменов, зарегистрированных под Вашей учётной записью на сервисах Яндекса

        Требуется? true
        Позиция? 1
        Значение по умолчанию
        Принимать входные данные конвейера?true (ByValue)
        Принимать подстановочные знаки?

- `NoCache [<SwitchParameter>]`
        данный флаг указывает на необходимость принудительного запроса токена, минуя кеш

        Требуется? false
        Позиция? named
        Значение по умолчанию
        Принимать входные данные конвейера?false
        Принимать подстановочные знаки?

- `<CommonParameters>`
        Данный командлет поддерживает общие параметры: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer и OutVariable. Для получения дополнительных сведений введите
        "get-help [about_CommonParameters][]".



##### Примеры использования

1. Получение токена для домена yourdomain.ru.

		$token = Get-Token -DomainName 'yourdomain.ru';

##### Связанные ссылки

- [get_token][]


[about_CommonParameters]: http://go.microsoft.com/fwlink/?LinkID=113216 "Описание параметров, которые могут использоваться с любым командлетом."
[add_logo]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_add_logo.xml 
[del_admin]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_del_admin.xml 
[del_domain]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_del_domain.xml 
[del_logo]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_del_logo.xml#domain-control_del_logo 
[get_admins]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_get_admins.xml 
[get_token]: http://api.yandex.ru/pdd/doc/api-pdd/reference/get-token.xml#get-token 
[Get-Admin]: <ITG.Yandex#Get-Admin> "Метод (обёртка над Яндекс.API get_admins). Метод позволяет получить список дополнительных администраторов домена."
[Get-Token]: <ITG.Yandex#Get-Token> "Метод (обёртка над Яндекс.API get_token) предназначен для получения авторизационного токена."
[Invoke-API]: <ITG.Yandex#Invoke-API> "Обёртка для вызовов методов API Яндекс. Предназначена для внутреннего использования."
[reg_domain]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_reg_domain.xml 
[Register-Admin]: <ITG.Yandex#Register-Admin> "Метод (обёртка над Яндекс.API set_admin) предназначен для указания логина дополнительного администратора домена."
[Register-Domain]: <ITG.Yandex#Register-Domain> "Метод (обёртка над Яндекс.API reg_domain) предназначен для регистрации домена на сервисах Яндекса."
[Remove-Admin]: <ITG.Yandex#Remove-Admin> "Метод (обёртка над Яндекс.API del_admin) предназначен для удаления дополнительного администратора домена."
[Remove-Domain]: <ITG.Yandex#Remove-Domain> "Метод (обёртка над Яндекс.API del_domain) предназначен для отключения домена от Яндекс.Почта для доменов."
[Remove-Logo]: <ITG.Yandex#Remove-Logo> "Метод (обёртка над Яндекс.API del_logo) предназначен для удаления логотипа домена."
[set_admin]: http://api.yandex.ru/pdd/doc/api-pdd/reference/domain-control_add_admin.xml 
[Set-Logo]: <ITG.Yandex#Set-Logo> "Метод (обёртка над Яндекс.API add_logo) предназначен для установки логотипа для домена."

---------------------------------------

Генератор: [ITG.Readme](http://github.com/IT-Service/ITG.Readme "Модуль PowerShell для генерации readme для модулей PowerShell").


﻿#
# Манифест модуля для модуля "ITG.Yandex".
#
# Создано: Sergey S. Betke
#
# Дата создания: 10.11.2012
#
# Архив проекта: https://github.com/IT-Service/ITG.Yandex
#

@{

# Файл модуля скрипта или двоичного модуля, связанный с данным манифестом
RootModule = 'ITG.Yandex.psm1'

# Номер версии данного модуля.
ModuleVersion = '2.0.1'

# Уникальный идентификатор данного модуля
GUID = '826e836c-d10c-4d4d-b86b-8b4a41829b99'

# Автор данного модуля
Author = 'Sergey S. Betke'

# Компания, создавшая данный модуль, или его поставщик
CompanyName = 'IT-Service.Nov.RU'

# Заявление об авторских правах на модуль
Copyright = '(c) 2012 Sergey S. Betke. All rights reserved.'

# Описание функций данного модуля
Description = 'Обёртки для API Яндекс - базовый модуль для поддержки API различных сервисов Яндекса.'

# Минимальный номер версии обработчика Windows PowerShell, необходимой для работы данного модуля
PowerShellVersion = '3.0'

# Имя узла Windows PowerShell, необходимого для работы данного модуля
PowerShellHostName = ''

# Минимальный номер версии узла Windows PowerShell, необходимой для работы данного модуля
PowerShellHostVersion = ''

# Минимальный номер версии компонента .NET Framework, необходимой для данного модуля
DotNetFrameworkVersion = '2.0'

# Минимальный номер версии среды CLR (общеязыковой среды выполнения), необходимой для работы данного модуля
CLRVersion = '2.0'

# Архитектура процессора (нет, X86, AMD64, IA64), необходимая для работы модуля
ProcessorArchitecture = ''

# Модули, которые необходимо импортировать в глобальную среду перед импортированием данного модуля
RequiredModules = @(
    @{ModuleName = 'ITG.WinAPI.User32'; ModuleVersion = '2.0'} `
,   @{ModuleName = 'ITG.WinAPI.UrlMon'; ModuleVersion = '2.0'} `
,   @{ModuleName = 'ITG.RegExps'; ModuleVersion = '1.1'} `
,   @{ModuleName = 'ITG.Utils'; ModuleVersion = '2.0'} `
)

# Сборки, которые должны быть загружены перед импортированием данного модуля
RequiredAssemblies = @()

# Файлы скрипта (.ps1), которые запускаются в среде вызывающей стороны перед импортированием данного модуля
ScriptsToProcess = @()

# Файлы типа (.ps1xml), которые загружаются при импорте данного модуля
TypesToProcess = @()

# Файлы формата (PS1XML-файлы), которые загружаются при импорте данного модуля
FormatsToProcess = @()

# Модули для импортирования в модуль, указанный в параметре ModuleToProcess, в качестве вложенных модулей
NestedModules = @()

# Функции для экспорта из данного модуля
FunctionsToExport = '*'

# Командлеты для экспорта из данного модуля
CmdletsToExport = '*'

# Переменные для экспорта из данного модуля
VariablesToExport = '*'

# Псевдонимы для экспорта из данного модуля
AliasesToExport = '*'

# Список всех модулей, входящих в пакет данного модуля
ModuleList = @()

# Список всех файлов, входящих в пакет данного модуля
FileList = `
	'ITG.Yandex.psm1' `
,   'ITG.Yandex.psd1' `
,   'readme.md'

# Личные данные, передаваемые в модуль, указанный в параметре ModuleToProcess
PrivateData = ''

}
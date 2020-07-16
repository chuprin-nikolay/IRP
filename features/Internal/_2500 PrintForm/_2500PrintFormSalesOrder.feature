#language: ru
@tree
@Positive

Функционал: check print functionality (Sales order)



Контекст:
	Дано Я запускаю сценарий открытия TestClient или подключаю уже существующий.



Сценарий: _25001 adding print plugin for sales order
	* Open form to add plugin
		И я открываю навигационную ссылку 'e1cib/list/Catalog.ExternalDataProc'
		И я нажимаю на кнопку с именем 'FormCreate'
	* Filling plugin data and adding it to the database
		И я буду выбирать внешний файл "#workingDir#\DataProcessor\PrintFormSalesOrder.epf"
		И я нажимаю на кнопку с именем "FormAddExtDataProc"
		И в поле 'Path to plugin for test' я ввожу текст ''
		И в поле 'Name' я ввожу текст 'PrintFormSalesOrder'
		И я нажимаю на кнопку открытия поля с именем "Description_en"
		И в поле 'ENG' я ввожу текст 'Sales order'
		И в поле 'TR' я ввожу текст 'Sales order tr'
		И я нажимаю на кнопку 'Ok'
		И я нажимаю на кнопку 'Save and close'
		И Пауза 5
	* Check the addition of plugin
		Тогда я проверяю наличие элемента справочника "ExternalDataProc" со значением поля "Description_en" "Sales order"

Сценарий: _25002 creating a print command for Sales order
	* Open Command register
		И я открываю навигационную ссылку 'e1cib/list/InformationRegister.ExternalCommands'
		И я нажимаю на кнопку с именем 'FormCreate'
	* Filling test command data for Sales order
		* Create metadata for sales order and select it for the command
			И я нажимаю кнопку выбора у поля "Configuration metadata"
			И в таблице "List" я перехожу к строке:
				| 'Description' |
				| 'Documents'   |
			И в таблице "List" я перехожу к строке:
				| 'Description' |
				| 'SalesOrder'  |
			И в таблице "List" я выбираю текущую строку
			И я нажимаю кнопку выбора у поля "Plugins"
			Тогда открылось окно 'Plugins'
			И в таблице "List" я перехожу к строке:
				| 'Description' |
				| 'Sales Order' |
			И в таблице "List" я выбираю текущую строку
		* Set UI group for command
			И я нажимаю кнопку выбора у поля "UI group"
			* Create UI group Print
				И я нажимаю на кнопку с именем 'FormCreate'
				И в поле 'ENG' я ввожу текст 'Print'
				И я нажимаю на кнопку открытия поля "ENG"
				И в поле 'TR' я ввожу текст 'Print'
				И в поле 'RU' я ввожу текст 'Печать'
				И я нажимаю на кнопку 'Ok'
				И я нажимаю на кнопку 'Save and close'
			И я нажимаю на кнопку с именем 'FormChoose'
	* Save command
		И я нажимаю на кнопку 'Save and close'
	* Check command save
		И я открываю навигационную ссылку 'e1cib/list/InformationRegister.ExternalCommands'
		Тогда таблица "List" содержит строки:
		| 'Configuration metadata' | 'Plugins' | 'UI group' |
		| 'SalesOrder'             | 'Sales Order'        | 'Print'           |

Сценарий: _25003 check Sales order printing
	* Create Sales order
		И я открываю навигационную ссылку 'e1cib/list/Document.SalesOrder'
		И я нажимаю на кнопку с именем 'FormCreate'
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| 'Description' |
			| 'Kalipso'     |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Legal name"
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Partner term"
		И в таблице "List" я перехожу к строке:
			| 'Description'                   |
			| 'Basic Partner terms, without VAT' |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я нажимаю на кнопку с именем 'ItemListAdd'
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита с именем "ItemListItem"
		И в таблице "List" я перехожу к строке:
			| 'Description' |
			| 'Shirt'       |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я активизирую поле с именем "ItemListItemKey"
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита с именем "ItemListItemKey"
		И в таблице "List" я перехожу к строке:
			| 'Item'  | 'Item key' |
			| 'Shirt' | '36/Red'  |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я нажимаю на кнопку с именем 'ItemListAdd'
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита с именем "ItemListItem"
		И в таблице "List" я перехожу к строке:
			| 'Description' |
			| 'Boots'       |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я активизирую поле с именем "ItemListItemKey"
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита с именем "ItemListItemKey"
		И в таблице "List" я перехожу к строке:
			| 'Item'  | 'Item key' |
			| 'Boots' | '37/18SD'  |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я завершаю редактирование строки
	* Change document number and date
		И я перехожу к закладке "Other"
		И в поле 'Number' я ввожу текст '8 000'
		Тогда открылось окно '1C:Enterprise'
		И я нажимаю на кнопку 'Yes'
		И в поле 'Number' я ввожу текст '8 000'
		И в поле 'Date' я ввожу текст '01.12.2019  0:00:01'
		И я перехожу к закладке "Item list"
		# Когда открылось окно 'Update item list info'
		# И я нажимаю на кнопку 'Ок'
	* Post document
		И я нажимаю на кнопку 'Post and close'
		И в таблице "List" я перехожу к строке:
		| 'Number' |
		| '8 000'  |
		И в таблице "List" я выбираю текущую строку
	* Printing out of a document
		И я нажимаю на кнопку 'Sales Order'
	* Check printing form
		И я жду открытия окна "Table" в течение 20 секунд
		Дано Табличный документ "" равен макету "SalesOrderPrintForm" по шаблону
		И Пауза 30
	И Я закрыл все окна клиентского приложения










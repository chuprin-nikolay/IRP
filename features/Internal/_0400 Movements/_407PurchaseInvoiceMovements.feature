﻿#language: en
@tree
@Positive
@Movements
@MovementsPurchaseInvoice

Functionality: check Purchase invoice movements



Scenario: _04096 preparation (Purchase invoice)
	When set True value to the constant
	And I close TestClient session
	Given I open new TestClient session or connect the existing one
	* Load info
		When Create information register Barcodes records
		When Create catalog Companies objects (own Second company)
		When Create catalog Agreements objects
		When Create catalog ObjectStatuses objects
		When Create catalog ItemKeys objects
		When Create catalog ItemTypes objects
		When Create catalog Units objects
		When Create catalog Items objects
		When Create catalog PriceTypes objects
		When Create catalog Specifications objects
		When Create chart of characteristic types AddAttributeAndProperty objects
		When Create catalog AddAttributeAndPropertySets objects
		When Create catalog AddAttributeAndPropertyValues objects
		When Create catalog Currencies objects
		When Create catalog Companies objects (Main company)
		When Create catalog Stores objects
		When Create catalog Partners objects
		When Create catalog Companies objects (partners company)
		When Create information register PartnerSegments records
		When Create catalog PartnerSegments objects
		When Create chart of characteristic types CurrencyMovementType objects
		When Create catalog TaxRates objects
		When Create catalog Taxes objects	
		When Create information register TaxSettings records
		When Create information register PricesByItemKeys records
		When Create catalog IntegrationSettings objects
		When Create information register CurrencyRates records
		When Create catalog BusinessUnits objects
		When Create catalog ExpenseAndRevenueTypes objects
		When Create catalog Companies objects (second company Ferron BP)
		When Create catalog PartnersBankAccounts objects
		When update ItemKeys
	* Add plugin for taxes calculation
		Given I open hyperlink "e1cib/list/Catalog.ExternalDataProc"
		If "List" table does not contain lines Then
				| "Description" |
				| "TaxCalculateVAT_TR" |
			When add Plugin for tax calculation
		When Create information register Taxes records (VAT)
	* Tax settings
		When filling in Tax settings for company
	When Create Document discount
	* Add plugin for discount
		Given I open hyperlink "e1cib/list/Catalog.ExternalDataProc"
		If "List" table does not contain lines Then
				| "Description" |
				| "DocumentDiscount" |
			When add Plugin for document discount
	When Create catalog CancelReturnReasons objects
	When Create catalog CashAccounts objects
	When Create catalog SerialLotNumbers objects
	* Load Bank payment
	When Create document BankPayment objects (check movements, advance)
	And I execute 1C:Enterprise script at server
			| "Documents.BankPayment.FindByNumber(1).GetObject().Write(DocumentWriteMode.Posting);" |	
	* Load PO
	When Create document PurchaseOrder objects (check movements, GR before PI, Use receipt sheduling)
	When Create document PurchaseOrder objects (check movements, GR before PI, not Use receipt sheduling)
	When Create document InternalSupplyRequest objects (check movements)
	And I execute 1C:Enterprise script at server
			| "Documents.InternalSupplyRequest.FindByNumber(117).GetObject().Write(DocumentWriteMode.Posting);" |	
	When Create document PurchaseOrder objects (check movements, PI before GR, not Use receipt sheduling)
	And I execute 1C:Enterprise script at server
			| "Documents.PurchaseOrder.FindByNumber(115).GetObject().Write(DocumentWriteMode.Posting);" |	
			| "Documents.PurchaseOrder.FindByNumber(116).GetObject().Write(DocumentWriteMode.Posting);" |
			| "Documents.PurchaseOrder.FindByNumber(117).GetObject().Write(DocumentWriteMode.Posting);" |	
	* Load GR
	When Create document GoodsReceipt objects (check movements)
	And I execute 1C:Enterprise script at server
			| "Documents.GoodsReceipt.FindByNumber(115).GetObject().Write(DocumentWriteMode.Posting);" |	
			| "Documents.GoodsReceipt.FindByNumber(116).GetObject().Write(DocumentWriteMode.Posting);" |
			// | "Documents.GoodsReceipt.FindByNumber(117).GetObject().Write(DocumentWriteMode.Posting);" |
			| "Documents.GoodsReceipt.FindByNumber(118).GetObject().Write(DocumentWriteMode.Posting);" |
			| "Documents.GoodsReceipt.FindByNumber(119).GetObject().Write(DocumentWriteMode.Posting);" |
	* Load PI
	When Create document PurchaseInvoice objects (check movements)
	And I execute 1C:Enterprise script at server
			| "Documents.PurchaseInvoice.FindByNumber(115).GetObject().Write(DocumentWriteMode.Posting);" |	
			| "Documents.PurchaseInvoice.FindByNumber(116).GetObject().Write(DocumentWriteMode.Posting);" |
			| "Documents.PurchaseInvoice.FindByNumber(117).GetObject().Write(DocumentWriteMode.Posting);" |	
			| "Documents.PurchaseInvoice.FindByNumber(118).GetObject().Write(DocumentWriteMode.Posting);" |	
			| "Documents.PurchaseInvoice.FindByNumber(119).GetObject().Write(DocumentWriteMode.Posting);" |	

// 115
Scenario: _04097 check Purchase invoice movements by the Register  "R1021 Vendors transactions"
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R1021 Vendors transactions"
		And I click "Registrations report" button
		And I select "R1021 Vendors transactions" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 115 dated 12.02.2021 15:13:56' | ''            | ''                    | ''          | ''             | ''                             | ''         | ''                  | ''          | ''                   | ''                                               | ''                     |
			| 'Document registrations records'                 | ''            | ''                    | ''          | ''             | ''                             | ''         | ''                  | ''          | ''                   | ''                                               | ''                     |
			| 'Register  "R1021 Vendors transactions"'         | ''            | ''                    | ''          | ''             | ''                             | ''         | ''                  | ''          | ''                   | ''                                               | ''                     |
			| ''                                               | 'Record type' | 'Period'              | 'Resources' | 'Dimensions'   | ''                             | ''         | ''                  | ''          | ''                   | ''                                               | 'Attributes'           |
			| ''                                               | ''            | ''                    | 'Amount'    | 'Company'      | 'Multi currency movement type' | 'Currency' | 'Legal name'        | 'Partner'   | 'Agreement'          | 'Basis'                                          | 'Deferred calculation' |
			| ''                                               | 'Receipt'     | '12.02.2021 15:13:56' | '393,76'    | 'Main Company' | 'Reporting currency'           | 'USD'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'No'                   |
			| ''                                               | 'Receipt'     | '12.02.2021 15:13:56' | '2 300'     | 'Main Company' | 'Local currency'               | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'No'                   |
			| ''                                               | 'Receipt'     | '12.02.2021 15:13:56' | '2 300'     | 'Main Company' | 'TRY'                          | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'No'                   |
			| ''                                               | 'Receipt'     | '12.02.2021 15:13:56' | '2 300'     | 'Main Company' | 'en description is empty'      | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'No'                   |
			| ''                                               | 'Expense'     | '12.02.2021 15:13:56' | '342,4'     | 'Main Company' | 'Reporting currency'           | 'USD'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'No'                   |
			| ''                                               | 'Expense'     | '12.02.2021 15:13:56' | '2 000'     | 'Main Company' | 'Local currency'               | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'No'                   |
			| ''                                               | 'Expense'     | '12.02.2021 15:13:56' | '2 000'     | 'Main Company' | 'TRY'                          | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'No'                   |
			| ''                                               | 'Expense'     | '12.02.2021 15:13:56' | '2 000'     | 'Main Company' | 'en description is empty'      | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'No'                   |
		And I close all client application windows
		
Scenario: _04098 check Purchase invoice movements by the Register  "R1001 Purchases"
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R1001 Purchases"
		And I click "Registrations report" button
		And I select "R1001 Purchases" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 115 dated 12.02.2021 15:13:56' | ''                    | ''          | ''       | ''           | ''              | ''             | ''                             | ''         | ''                                               | ''          | ''                                     | ''                     |
			| 'Document registrations records'                 | ''                    | ''          | ''       | ''           | ''              | ''             | ''                             | ''         | ''                                               | ''          | ''                                     | ''                     |
			| 'Register  "R1001 Purchases"'                    | ''                    | ''          | ''       | ''           | ''              | ''             | ''                             | ''         | ''                                               | ''          | ''                                     | ''                     |
			| ''                                               | 'Period'              | 'Resources' | ''       | ''           | ''              | 'Dimensions'   | ''                             | ''         | ''                                               | ''          | ''                                     | 'Attributes'           |
			| ''                                               | ''                    | 'Quantity'  | 'Amount' | 'Net amount' | 'Offers amount' | 'Company'      | 'Multi currency movement type' | 'Currency' | 'Invoice'                                        | 'Item key'  | 'Row key'                              | 'Deferred calculation' |
			| ''                                               | '12.02.2021 15:13:56' | '2'         | '51,36'  | '43,53'      | ''              | 'Main Company' | 'Reporting currency'           | 'USD'      | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'Interner'  | '9db770ce-c5f9-4f4c-a8a9-7adc10793d77' | 'No'                   |
			| ''                                               | '12.02.2021 15:13:56' | '2'         | '300'    | '254,24'     | ''              | 'Main Company' | 'Local currency'               | 'TRY'      | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'Interner'  | '9db770ce-c5f9-4f4c-a8a9-7adc10793d77' | 'No'                   |
			| ''                                               | '12.02.2021 15:13:56' | '2'         | '300'    | '254,24'     | ''              | 'Main Company' | 'TRY'                          | 'TRY'      | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'Interner'  | '9db770ce-c5f9-4f4c-a8a9-7adc10793d77' | 'No'                   |
			| ''                                               | '12.02.2021 15:13:56' | '2'         | '300'    | '254,24'     | ''              | 'Main Company' | 'en description is empty'      | 'TRY'      | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'Interner'  | '9db770ce-c5f9-4f4c-a8a9-7adc10793d77' | 'No'                   |
			| ''                                               | '12.02.2021 15:13:56' | '5'         | '171,2'  | '145,09'     | ''              | 'Main Company' | 'Reporting currency'           | 'USD'      | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | '36/Yellow' | '18d36228-af88-4ba5-a17a-f3ab3ddb6816' | 'No'                   |
			| ''                                               | '12.02.2021 15:13:56' | '5'         | '1 000'  | '847,46'     | ''              | 'Main Company' | 'Local currency'               | 'TRY'      | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | '36/Yellow' | '18d36228-af88-4ba5-a17a-f3ab3ddb6816' | 'No'                   |
			| ''                                               | '12.02.2021 15:13:56' | '5'         | '1 000'  | '847,46'     | ''              | 'Main Company' | 'TRY'                          | 'TRY'      | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | '36/Yellow' | '18d36228-af88-4ba5-a17a-f3ab3ddb6816' | 'No'                   |
			| ''                                               | '12.02.2021 15:13:56' | '5'         | '1 000'  | '847,46'     | ''              | 'Main Company' | 'en description is empty'      | 'TRY'      | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | '36/Yellow' | '18d36228-af88-4ba5-a17a-f3ab3ddb6816' | 'No'                   |
			| ''                                               | '12.02.2021 15:13:56' | '10'        | '171,2'  | '145,09'     | ''              | 'Main Company' | 'Reporting currency'           | 'USD'      | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'S/Yellow'  | '3e2661d8-cf3b-4695-8cf7-a14ecc9f32ce' | 'No'                   |
			| ''                                               | '12.02.2021 15:13:56' | '10'        | '1 000'  | '847,46'     | ''              | 'Main Company' | 'Local currency'               | 'TRY'      | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'S/Yellow'  | '3e2661d8-cf3b-4695-8cf7-a14ecc9f32ce' | 'No'                   |
			| ''                                               | '12.02.2021 15:13:56' | '10'        | '1 000'  | '847,46'     | ''              | 'Main Company' | 'TRY'                          | 'TRY'      | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'S/Yellow'  | '3e2661d8-cf3b-4695-8cf7-a14ecc9f32ce' | 'No'                   |
			| ''                                               | '12.02.2021 15:13:56' | '10'        | '1 000'  | '847,46'     | ''              | 'Main Company' | 'en description is empty'      | 'TRY'      | 'Purchase invoice 115 dated 12.02.2021 15:13:56' | 'S/Yellow'  | '3e2661d8-cf3b-4695-8cf7-a14ecc9f32ce' | 'No'                   |
			
		And I close all client application windows
		
Scenario: _04099 check Purchase invoice movements by the Register  "R1005 Special offers of purchases" (without special offers)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R1005 Special offers of purchases"
		And I click "Registrations report" button
		And I select "R1005 Special offers of purchases" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document does not contain values
			| 'Register  "R1005 Special offers of purchases"'                     |
			
		And I close all client application windows
		
Scenario: _040100 check Purchase invoice movements by the Register  "R5010 Reconciliation statement"
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R5010 Reconciliation statement"
		And I click "Registrations report" button
		And I select "R5010 Reconciliation statement" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 115 dated 12.02.2021 15:13:56' | ''            | ''                    | ''          | ''           | ''             | ''                  |
			| 'Document registrations records'                 | ''            | ''                    | ''          | ''           | ''             | ''                  |
			| 'Register  "R5010 Reconciliation statement"'     | ''            | ''                    | ''          | ''           | ''             | ''                  |
			| ''                                               | 'Record type' | 'Period'              | 'Resources' | 'Dimensions' | ''             | ''                  |
			| ''                                               | ''            | ''                    | 'Amount'    | 'Currency'   | 'Company'      | 'Legal name'        |
			| ''                                               | 'Expense'     | '12.02.2021 15:13:56' | '2 300'     | 'TRY'        | 'Main Company' | 'Company Ferron BP' |	
		And I close all client application windows
		
Scenario: _040101 check Purchase invoice movements by the Register  "R4010 Actual stocks" (use GR)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R4010 Actual stocks"
		And I click "Registrations report" button
		And I select "R4010 Actual stocks" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document does not contain values
			| 'Register  "R4010 Actual stocks"'                     |
			
		And I close all client application windows
		
Scenario: _040102 check Purchase invoice movements by the Register  "R4017 Procurement of internal supply requests" (without ISR)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R4017 Procurement of internal supply requests"
		And I click "Registrations report" button
		And I select "R4017 Procurement of internal supply requests" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document does not contain values
			| 'Register  "R4017 Procurement of internal supply requests"'|
			
		And I close all client application windows
		
Scenario: _040103 check Purchase invoice movements by the Register  "R1020 Advances to vendors" (with advance)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R1020 Advances to vendors"
		And I click "Registrations report" button
		And I select "R1020 Advances to vendors" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 115 dated 12.02.2021 15:13:56' | ''            | ''                    | ''          | ''             | ''                             | ''         | ''                  | ''          | ''                                         | ''                     |
			| 'Document registrations records'                 | ''            | ''                    | ''          | ''             | ''                             | ''         | ''                  | ''          | ''                                         | ''                     |
			| 'Register  "R1020 Advances to vendors"'          | ''            | ''                    | ''          | ''             | ''                             | ''         | ''                  | ''          | ''                                         | ''                     |
			| ''                                               | 'Record type' | 'Period'              | 'Resources' | 'Dimensions'   | ''                             | ''         | ''                  | ''          | ''                                         | 'Attributes'           |
			| ''                                               | ''            | ''                    | 'Amount'    | 'Company'      | 'Multi currency movement type' | 'Currency' | 'Legal name'        | 'Partner'   | 'Basis'                                    | 'Deferred calculation' |
			| ''                                               | 'Expense'     | '12.02.2021 15:13:56' | '342,4'     | 'Main Company' | 'Reporting currency'           | 'USD'      | 'Company Ferron BP' | 'Ferron BP' | 'Bank payment 1 dated 12.02.2021 11:24:13' | 'No'                   |
			| ''                                               | 'Expense'     | '12.02.2021 15:13:56' | '2 000'     | 'Main Company' | 'Local currency'               | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Bank payment 1 dated 12.02.2021 11:24:13' | 'No'                   |
			| ''                                               | 'Expense'     | '12.02.2021 15:13:56' | '2 000'     | 'Main Company' | 'en description is empty'      | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Bank payment 1 dated 12.02.2021 11:24:13' | 'No'                   |	
		And I close all client application windows
		
Scenario: _040104 check Purchase invoice movements by the Register  "R4050 Stock inventory"
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R4050 Stock inventory"
		And I click "Registrations report" button
		And I select "R4050 Stock inventory" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 115 dated 12.02.2021 15:13:56' | ''            | ''                    | ''          | ''             | ''         | ''          |
			| 'Document registrations records'                 | ''            | ''                    | ''          | ''             | ''         | ''          |
			| 'Register  "R4050 Stock inventory"'              | ''            | ''                    | ''          | ''             | ''         | ''          |
			| ''                                               | 'Record type' | 'Period'              | 'Resources' | 'Dimensions'   | ''         | ''          |
			| ''                                               | ''            | ''                    | 'Quantity'  | 'Company'      | 'Store'    | 'Item key'  |
			| ''                                               | 'Receipt'     | '12.02.2021 15:13:56' | '5'         | 'Main Company' | 'Store 02' | '36/Yellow' |
			| ''                                               | 'Receipt'     | '12.02.2021 15:13:56' | '10'        | 'Main Company' | 'Store 02' | 'S/Yellow'  |	
		And I close all client application windows
		
Scenario: _040105 check Purchase invoice movements by the Register  "R4011 Free stocks"  (use GR)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R4011 Free stocks"
		And I click "Registrations report" button
		And I select "R4011 Free stocks" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document does not contain values
			| 'Register  "R4011 Free stocks"'                     |
			
		And I close all client application windows
		
Scenario: _040106 check Purchase invoice movements by the Register  "R1031 Receipt invoicing" (PO-GR-PI)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R1031 Receipt invoicing"
		And I click "Registrations report" button
		And I select "R1031 Receipt invoicing" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 115 dated 12.02.2021 15:13:56' | ''            | ''                    | ''          | ''             | ''         | ''                                            | ''          |
			| 'Document registrations records'                 | ''            | ''                    | ''          | ''             | ''         | ''                                            | ''          |
			| 'Register  "R1031 Receipt invoicing"'            | ''            | ''                    | ''          | ''             | ''         | ''                                            | ''          |
			| ''                                               | 'Record type' | 'Period'              | 'Resources' | 'Dimensions'   | ''         | ''                                            | ''          |
			| ''                                               | ''            | ''                    | 'Quantity'  | 'Company'      | 'Store'    | 'Basis'                                       | 'Item key'  |
			| ''                                               | 'Expense'     | '12.02.2021 15:13:56' | '5'         | 'Main Company' | 'Store 02' | 'Goods receipt 115 dated 12.02.2021 15:10:35' | '36/Yellow' |
			| ''                                               | 'Expense'     | '12.02.2021 15:13:56' | '10'        | 'Main Company' | 'Store 02' | 'Goods receipt 115 dated 12.02.2021 15:10:35' | 'S/Yellow'  |

		And I close all client application windows
		
Scenario: _040107 check Purchase invoice movements by the Register  "R1040 Taxes outgoing"
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R1040 Taxes outgoing"
		And I click "Registrations report" button
		And I select "R1040 Taxes outgoing" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 115 dated 12.02.2021 15:13:56' | ''            | ''                    | ''               | ''           | ''             | ''    | ''         | ''                  |
			| 'Document registrations records'                 | ''            | ''                    | ''               | ''           | ''             | ''    | ''         | ''                  |
			| 'Register  "R1040 Taxes outgoing"'               | ''            | ''                    | ''               | ''           | ''             | ''    | ''         | ''                  |
			| ''                                               | 'Record type' | 'Period'              | 'Resources'      | ''           | 'Dimensions'   | ''    | ''         | ''                  |
			| ''                                               | ''            | ''                    | 'Taxable amount' | 'Tax amount' | 'Company'      | 'Tax' | 'Tax rate' | 'Tax movement type' |
			| ''                                               | 'Receipt'     | '12.02.2021 15:13:56' | '254,24'         | '45,76'      | 'Main Company' | 'VAT' | '18%'      | ''                  |
			| ''                                               | 'Receipt'     | '12.02.2021 15:13:56' | '847,46'         | '152,54'     | 'Main Company' | 'VAT' | '18%'      | ''                  |
			| ''                                               | 'Receipt'     | '12.02.2021 15:13:56' | '847,46'         | '152,54'     | 'Main Company' | 'VAT' | '18%'      | ''                  |	
		And I close all client application windows
		
Scenario: _040108 check Purchase invoice movements by the Register  "R1012 Invoice closing of purchase orders" (PO exists)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R1012 Invoice closing of purchase orders"
		And I click "Registrations report" button
		And I select "R1012 Invoice closing of purchase orders" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 115 dated 12.02.2021 15:13:56'       | ''            | ''                    | ''          | ''       | ''           | ''             | ''                                             | ''         | ''          | ''                                     |
			| 'Document registrations records'                       | ''            | ''                    | ''          | ''       | ''           | ''             | ''                                             | ''         | ''          | ''                                     |
			| 'Register  "R1012 Invoice closing of purchase orders"' | ''            | ''                    | ''          | ''       | ''           | ''             | ''                                             | ''         | ''          | ''                                     |
			| ''                                                     | 'Record type' | 'Period'              | 'Resources' | ''       | ''           | 'Dimensions'   | ''                                             | ''         | ''          | ''                                     |
			| ''                                                     | ''            | ''                    | 'Quantity'  | 'Amount' | 'Net amount' | 'Company'      | 'Order'                                        | 'Currency' | 'Item key'  | 'Row key'                              |
			| ''                                                     | 'Expense'     | '12.02.2021 15:13:56' | '2'         | '300'    | '254,24'     | 'Main Company' | 'Purchase order 115 dated 12.02.2021 12:44:43' | 'TRY'      | 'Interner'  | '9db770ce-c5f9-4f4c-a8a9-7adc10793d77' |
			| ''                                                     | 'Expense'     | '12.02.2021 15:13:56' | '5'         | '1 000'  | '847,46'     | 'Main Company' | 'Purchase order 115 dated 12.02.2021 12:44:43' | 'TRY'      | '36/Yellow' | '18d36228-af88-4ba5-a17a-f3ab3ddb6816' |
			| ''                                                     | 'Expense'     | '12.02.2021 15:13:56' | '10'        | '1 000'  | '847,46'     | 'Main Company' | 'Purchase order 115 dated 12.02.2021 12:44:43' | 'TRY'      | 'S/Yellow'  | '3e2661d8-cf3b-4695-8cf7-a14ecc9f32ce' |	
		And I close all client application windows
		
Scenario: _040109 check Purchase invoice movements by the Register  "R4035 Incoming stocks"
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R4035 Incoming stocks"
		And I click "Registrations report" button
		And I select "R4035 Incoming stocks" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document does not contain values
			| 'Register  "R4035 Incoming stocks"'                     |
			
		And I close all client application windows
		
Scenario: _040110 check Purchase invoice movements by the Register  "R4012 Stock Reservation" (without IncomingStocksRequested)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R4012 Stock Reservation"
		And I click "Registrations report" button
		And I select "R4012 Stock Reservation" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document does not contain values
			| 'Register  "R4012 Stock Reservation"'                     |
			
		And I close all client application windows
		
Scenario: _040111 check Purchase invoice movements by the Register  "R2013 Procurement of sales orders" (without SO)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R2013 Procurement of sales orders"
		And I click "Registrations report" button
		And I select "R2013 Procurement of sales orders" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document does not contain values
			| 'Register  "R2013 Procurement of sales orders"'                     |
			
		And I close all client application windows
		
Scenario: _040112 check Purchase invoice movements by the Register  "R4036 Incoming stock requested" (without IncomingStocksRequested)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R4036 Incoming stock requested"
		And I click "Registrations report" button
		And I select "R4036 Incoming stock requested" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document does not contain values
			| 'Register  "R4036 Incoming stock requested"'                     |
			
		And I close all client application windows
		
Scenario: _040113 check Purchase invoice movements by the Register  "R4014 Serial lot numbers" (not use Serial lot numbers)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R4014 Serial lot numbers"
		And I click "Registrations report" button
		And I select "R4014 Serial lot numbers" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document does not contain values
			| 'Register  "R4014 Serial lot numbers"'                     |
			
		And I close all client application windows
		
Scenario: _040114 check Purchase invoice movements by the Register  "R1011 Receipt of purchase orders" (use GR)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '115' |
	* Check movements by the Register  "R1011 Receipt of purchase orders"
		And I click "Registrations report" button
		And I select "R1011 Receipt of purchase orders" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document does not contain values
			| 'Register  "R1011 Receipt of purchase orders"'                     |
			
		And I close all client application windows




		

// 117

		
		
Scenario: _040993 check Purchase invoice movements by the Register  "R1005 Special offers of purchases" (with special offers)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '117' |
	* Check movements by the Register  "R1005 Special offers of purchases"
		And I click "Registrations report" button
		And I select "R1005 Special offers of purchases" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 117 dated 12.02.2021 15:12:15' | ''                    | ''              | ''             | ''                             | ''         | ''                                               | ''          | ''                                     | ''                 | ''                     |
			| 'Document registrations records'                 | ''                    | ''              | ''             | ''                             | ''         | ''                                               | ''          | ''                                     | ''                 | ''                     |
			| 'Register  "R1005 Special offers of purchases"'  | ''                    | ''              | ''             | ''                             | ''         | ''                                               | ''          | ''                                     | ''                 | ''                     |
			| ''                                               | 'Period'              | 'Resources'     | 'Dimensions'   | ''                             | ''         | ''                                               | ''          | ''                                     | ''                 | 'Attributes'           |
			| ''                                               | ''                    | 'Offers amount' | 'Company'      | 'Multi currency movement type' | 'Currency' | 'Invoice'                                        | 'Item key'  | 'Row key'                              | 'Special offer'    | 'Deferred calculation' |
			| ''                                               | '12.02.2021 15:12:15' | '5,14'          | 'Main Company' | 'Reporting currency'           | 'USD'      | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'Interner'  | '1b90516b-b3ac-4ca5-bb47-44477975f242' | 'DocumentDiscount' | 'No'                   |
			| ''                                               | '12.02.2021 15:12:15' | '17,12'         | 'Main Company' | 'Reporting currency'           | 'USD'      | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'S/Yellow'  | '4fcbb4cf-3824-47fb-89b5-50d151315d4d' | 'DocumentDiscount' | 'No'                   |
			| ''                                               | '12.02.2021 15:12:15' | '17,12'         | 'Main Company' | 'Reporting currency'           | 'USD'      | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | '36/Yellow' | '923e7825-c20f-4a3e-a983-2b85d80e475a' | 'DocumentDiscount' | 'No'                   |
			| ''                                               | '12.02.2021 15:12:15' | '30'            | 'Main Company' | 'Local currency'               | 'TRY'      | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'Interner'  | '1b90516b-b3ac-4ca5-bb47-44477975f242' | 'DocumentDiscount' | 'No'                   |
			| ''                                               | '12.02.2021 15:12:15' | '30'            | 'Main Company' | 'TRY'                          | 'TRY'      | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'Interner'  | '1b90516b-b3ac-4ca5-bb47-44477975f242' | 'DocumentDiscount' | 'No'                   |
			| ''                                               | '12.02.2021 15:12:15' | '30'            | 'Main Company' | 'en description is empty'      | 'TRY'      | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'Interner'  | '1b90516b-b3ac-4ca5-bb47-44477975f242' | 'DocumentDiscount' | 'No'                   |
			| ''                                               | '12.02.2021 15:12:15' | '100'           | 'Main Company' | 'Local currency'               | 'TRY'      | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'S/Yellow'  | '4fcbb4cf-3824-47fb-89b5-50d151315d4d' | 'DocumentDiscount' | 'No'                   |
			| ''                                               | '12.02.2021 15:12:15' | '100'           | 'Main Company' | 'Local currency'               | 'TRY'      | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | '36/Yellow' | '923e7825-c20f-4a3e-a983-2b85d80e475a' | 'DocumentDiscount' | 'No'                   |
			| ''                                               | '12.02.2021 15:12:15' | '100'           | 'Main Company' | 'TRY'                          | 'TRY'      | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'S/Yellow'  | '4fcbb4cf-3824-47fb-89b5-50d151315d4d' | 'DocumentDiscount' | 'No'                   |
			| ''                                               | '12.02.2021 15:12:15' | '100'           | 'Main Company' | 'TRY'                          | 'TRY'      | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | '36/Yellow' | '923e7825-c20f-4a3e-a983-2b85d80e475a' | 'DocumentDiscount' | 'No'                   |
			| ''                                               | '12.02.2021 15:12:15' | '100'           | 'Main Company' | 'en description is empty'      | 'TRY'      | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'S/Yellow'  | '4fcbb4cf-3824-47fb-89b5-50d151315d4d' | 'DocumentDiscount' | 'No'                   |
			| ''                                               | '12.02.2021 15:12:15' | '100'           | 'Main Company' | 'en description is empty'      | 'TRY'      | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | '36/Yellow' | '923e7825-c20f-4a3e-a983-2b85d80e475a' | 'DocumentDiscount' | 'No'                   |
			
		And I close all client application windows
		



		
Scenario: _0401063 check Purchase invoice movements by the Register  "R1031 Receipt invoicing" (PO-PI)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '117' |
	* Check movements by the Register  "R1031 Receipt invoicing"
		And I click "Registrations report" button
		And I select "R1031 Receipt invoicing" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 117 dated 12.02.2021 15:12:15' | ''            | ''                    | ''          | ''             | ''         | ''                                            | ''          |
			| 'Document registrations records'                 | ''            | ''                    | ''          | ''             | ''         | ''                                            | ''          |
			| 'Register  "R1031 Receipt invoicing"'            | ''            | ''                    | ''          | ''             | ''         | ''                                            | ''          |
			| ''                                               | 'Record type' | 'Period'              | 'Resources' | 'Dimensions'   | ''         | ''                                            | ''          |
			| ''                                               | ''            | ''                    | 'Quantity'  | 'Company'      | 'Store'    | 'Basis'                                       | 'Item key'  |
			| ''                                               | 'Receipt'     | '12.02.2021 15:12:15' | '5'         | 'Main Company' | 'Store 02' | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | '36/Yellow' |


		And I close all client application windows
		

Scenario: _0401064 check Purchase invoice movements by the Register  "R1021 Vendors transactions" (with advance)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '117' |
	* Check movements by the Register  "R1021 Vendors transactions"
		And I click "Registrations report" button
		And I select "R1021 Vendors transactions" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 117 dated 12.02.2021 15:12:15' | ''            | ''                    | ''          | ''             | ''                             | ''         | ''                  | ''          | ''                   | ''                                               | ''                     |
			| 'Document registrations records'                 | ''            | ''                    | ''          | ''             | ''                             | ''         | ''                  | ''          | ''                   | ''                                               | ''                     |
			| 'Register  "R1021 Vendors transactions"'         | ''            | ''                    | ''          | ''             | ''                             | ''         | ''                  | ''          | ''                   | ''                                               | ''                     |
			| ''                                               | 'Record type' | 'Period'              | 'Resources' | 'Dimensions'   | ''                             | ''         | ''                  | ''          | ''                   | ''                                               | 'Attributes'           |
			| ''                                               | ''            | ''                    | 'Amount'    | 'Company'      | 'Multi currency movement type' | 'Currency' | 'Legal name'        | 'Partner'   | 'Agreement'          | 'Basis'                                          | 'Deferred calculation' |
			| ''                                               | 'Receipt'     | '12.02.2021 15:12:15' | '765,26'    | 'Main Company' | 'Reporting currency'           | 'USD'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'No'                   |
			| ''                                               | 'Receipt'     | '12.02.2021 15:12:15' | '4 470'     | 'Main Company' | 'Local currency'               | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'No'                   |
			| ''                                               | 'Receipt'     | '12.02.2021 15:12:15' | '4 470'     | 'Main Company' | 'TRY'                          | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'No'                   |
			| ''                                               | 'Receipt'     | '12.02.2021 15:12:15' | '4 470'     | 'Main Company' | 'en description is empty'      | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'No'                   |
			| ''                                               | 'Expense'     | '12.02.2021 15:12:15' | '342,4'     | 'Main Company' | 'Reporting currency'           | 'USD'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'No'                   |
			| ''                                               | 'Expense'     | '12.02.2021 15:12:15' | '2 000'     | 'Main Company' | 'Local currency'               | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'No'                   |
			| ''                                               | 'Expense'     | '12.02.2021 15:12:15' | '2 000'     | 'Main Company' | 'TRY'                          | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'No'                   |
			| ''                                               | 'Expense'     | '12.02.2021 15:12:15' | '2 000'     | 'Main Company' | 'en description is empty'      | 'TRY'      | 'Company Ferron BP' | 'Ferron BP' | 'Vendor Ferron, TRY' | 'Purchase invoice 117 dated 12.02.2021 15:12:15' | 'No'                   |

		And I close all client application windows

Scenario: _0401066 check Purchase invoice movements by the Register  "R4017 Procurement of internal supply requests" (ISR exists)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '117' |
	* Check movements by the Register  "R4017 Procurement of internal supply requests"
		And I click "Registrations report" button
		And I select "R4017 Procurement of internal supply requests" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 117 dated 12.02.2021 15:12:15'            | ''            | ''                    | ''          | ''             | ''         | ''                                                      | ''         |
			| 'Document registrations records'                            | ''            | ''                    | ''          | ''             | ''         | ''                                                      | ''         |
			| 'Register  "R4017 Procurement of internal supply requests"' | ''            | ''                    | ''          | ''             | ''         | ''                                                      | ''         |
			| ''                                                          | 'Record type' | 'Period'              | 'Resources' | 'Dimensions'   | ''         | ''                                                      | ''         |
			| ''                                                          | ''            | ''                    | 'Quantity'  | 'Company'      | 'Store'    | 'Internal supply request'                               | 'Item key' |
			| ''                                                          | 'Expense'     | '12.02.2021 15:12:15' | '10'        | 'Main Company' | 'Store 02' | 'Internal supply request 117 dated 12.02.2021 14:39:38' | 'S/Yellow' |

		And I close all client application windows

// Scenario: _0401067 check Purchase invoice movements by the Register  "R2013 Procurement of sales orders" (SO exists)
// 	* Select Purchase invoice
// 		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
// 		And I go to line in "List" table
// 			| 'Number'  |
// 			| '117' |
// 	* Check movements by the Register  "R2013 Procurement of sales orders"
// 		And I click "Registrations report" button
// 		And I select "R2013 Procurement of sales orders" exact value from "Register" drop-down list
// 		And I click "Generate report" button
// 		Then "ResultTable" spreadsheet document is equal
// 			| 'Purchase invoice 117 dated 12.02.2021 15:12:15' | ''                    | ''                 | ''                    | ''                  | ''                 | ''                 | ''               | ''             | ''                                        | ''         |
// 			| 'Document registrations records'                 | ''                    | ''                 | ''                    | ''                  | ''                 | ''                 | ''               | ''             | ''                                        | ''         |
// 			| 'Register  "R2013 Procurement of sales orders"'  | ''                    | ''                 | ''                    | ''                  | ''                 | ''                 | ''               | ''             | ''                                        | ''         |
// 			| ''                                               | 'Period'              | 'Resources'        | ''                    | ''                  | ''                 | ''                 | ''               | 'Dimensions'   | ''                                        | ''         |
// 			| ''                                               | ''                    | 'Ordered quantity' | 'Re ordered quantity' | 'Purchase quantity' | 'Receipt quantity' | 'Shipped quantity' | 'Sales quantity' | 'Company'      | 'Order'                                   | 'Item key' |
// 			| ''                                               | '12.02.2021 15:12:15' | ''                 | ''                    | '24'                | ''                 | ''                 | ''               | 'Main Company' | 'Sales order 1 dated 27.01.2021 19:50:45' | '37/18SD'  |

// 		And I close all client application windows

Scenario: _0401068 check Purchase invoice movements by the Register  "R1011 Receipt of purchase orders" (PO exists, not use GR)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '117' |
	* Check movements by the Register "R1011 Receipt of purchase orders"
		And I click "Registrations report" button
		And I select "R1011 Receipt of purchase orders" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 117 dated 12.02.2021 15:12:15' | ''            | ''                    | ''          | ''             | ''                                             | ''          |
			| 'Document registrations records'                 | ''            | ''                    | ''          | ''             | ''                                             | ''          |
			| 'Register  "R1011 Receipt of purchase orders"'   | ''            | ''                    | ''          | ''             | ''                                             | ''          |
			| ''                                               | 'Record type' | 'Period'              | 'Resources' | 'Dimensions'   | ''                                             | ''          |
			| ''                                               | ''            | ''                    | 'Quantity'  | 'Company'      | 'Order'                                        | 'Item key'  |
			| ''                                               | 'Expense'     | '12.02.2021 15:12:15' | '10'        | 'Main Company' | 'Purchase order 117 dated 12.02.2021 12:45:05' | 'S/Yellow'  |

		And I close all client application windows

Scenario: _0401069 check Purchase invoice movements by the Register  "R4014 Serial lot numbers" (use Serial lot numbers)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '117' |
	* Check movements by the Register "R4014 Serial lot numbers"
		And I click "Registrations report" button
		And I select "R4014 Serial lot numbers" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 117 dated 12.02.2021 15:12:15' | ''            | ''                    | ''          | ''             | ''         | ''                  |
			| 'Document registrations records'                 | ''            | ''                    | ''          | ''             | ''         | ''                  |
			| 'Register  "R4014 Serial lot numbers"'           | ''            | ''                    | ''          | ''             | ''         | ''                  |
			| ''                                               | 'Record type' | 'Period'              | 'Resources' | 'Dimensions'   | ''         | ''                  |
			| ''                                               | ''            | ''                    | 'Quantity'  | 'Company'      | 'Item key' | 'Serial lot number' |
			| ''                                               | 'Receipt'     | '12.02.2021 15:12:15' | '10'        | 'Main Company' | 'S/Yellow' | '0512'              |
		And I close all client application windows

//PI (without GR)

	
Scenario: _0401054 check Purchase invoice movements by the Register  "R4011 Free stocks" (not use GR, GR not exists)
	And I close all client application windows
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '118' |
	* Check movements by the Register  "R4011 Free stocks"
		And I click "Registrations report" button
		And I select "R4011 Free stocks" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 118 dated 12.02.2021 16:08:41' | ''            | ''                    | ''          | ''           | ''          |
			| 'Document registrations records'                 | ''            | ''                    | ''          | ''           | ''          |
			| 'Register  "R4011 Free stocks"'                  | ''            | ''                    | ''          | ''           | ''          |
			| ''                                               | 'Record type' | 'Period'              | 'Resources' | 'Dimensions' | ''          |
			| ''                                               | ''            | ''                    | 'Quantity'  | 'Store'      | 'Item key'  |
			| ''                                               | 'Receipt'     | '12.02.2021 16:08:41' | '5'         | 'Store 02'   | '36/Yellow' |
		And I close all client application windows




Scenario: _0401093 check Purchase invoice movements by the Register  "R1012 Invoice closing of purchase orders" (without PO)
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '118' |
	* Check movements by the Register  "R1012 Invoice closing of purchase orders"
		And I click "Registrations report" button
		And I select "R1012 Invoice closing of purchase orders" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document does not contain values
			| 'Register  "R1012 Invoice closing of purchase orders"'                     |
			
		And I close all client application windows

Scenario: _0401014 check Purchase invoice movements by the Register  "R4010 Actual stocks" (not use GR)
	And I close all client application windows
	* Select Purchase invoice
		Given I open hyperlink "e1cib/list/Document.PurchaseInvoice"
		And I go to line in "List" table
			| 'Number'  |
			| '118' |
	* Check movements by the Register  "R4010 Actual stocks"
		And I click "Registrations report" button
		And I select "R4010 Actual stocks" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Purchase invoice 118 dated 12.02.2021 16:08:41' | ''            | ''                    | ''          | ''           | ''          |
			| 'Document registrations records'                 | ''            | ''                    | ''          | ''           | ''          |
			| 'Register  "R4010 Actual stocks"'                | ''            | ''                    | ''          | ''           | ''          |
			| ''                                               | 'Record type' | 'Period'              | 'Resources' | 'Dimensions' | ''          |
			| ''                                               | ''            | ''                    | 'Quantity'  | 'Store'      | 'Item key'  |
			| ''                                               | 'Receipt'     | '12.02.2021 16:08:41' | '5'         | 'Store 02'   | '36/Yellow' |
			
		And I close all client application windows






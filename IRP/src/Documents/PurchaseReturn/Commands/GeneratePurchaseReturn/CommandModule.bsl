&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	GenerateDocument(CommandParameter);
EndProcedure

&AtClient
Procedure GenerateDocument(ArrayOfBasisDocuments)
	DocumentStructure = GetDocumentsStructure(ArrayOfBasisDocuments);
	
	If DocumentStructure.Count() = 0 Then
		For Each BasisDocument In ArrayOfBasisDocuments Do
			ErrorMessage = GetErrorMessage(BasisDocument);
			If ValueIsFilled(ErrorMessage) Then
				ShowMessageBox( , ErrorMessage);
				Return;
			EndIf;
		EndDo;
	EndIf;
	
	For Each FillingData In DocumentStructure Do
		FormParameters = New Structure("FillingValues", FillingData);
		InfoMessage = GetInfoMessage(FillingData);
		If Not IsBlankString(InfoMessage) Then
			FormParameters.Insert("InfoMessage", InfoMessage);
		EndIf;
		OpenForm("Document.PurchaseReturn.ObjectForm", FormParameters, , New UUID());
	EndDo;
EndProcedure

&AtServer
Function GetDocumentsStructure(ArrayOfBasisDocuments)
	
	ArrayOf_PurchaseInvoice = New Array();
	ArrayOf_PurchaseReturnOrder = New Array();
	ArrayOf_ShipmentConfirmation = New Array();
	
	For Each Row In ArrayOfBasisDocuments Do
		If TypeOf(Row) = Type("DocumentRef.PurchaseInvoice") Then
			ArrayOf_PurchaseInvoice.Add(Row);
		ElsIf TypeOf(Row) = Type("DocumentRef.PurchaseReturnOrder") Then
			ArrayOf_PurchaseReturnOrder.Add(Row);
		ElsIf TypeOf(Row) = Type("DocumentRef.ShipmentConfirmation") Then
			ArrayOf_ShipmentConfirmation.Add(Row);
		Else
			Raise R().Error_043;
		EndIf;
	EndDo;
	
	ArrayOfTables = New Array();
	ArrayOfTables.Add(GetDocumentTable_PurchaseInvoice(ArrayOf_PurchaseInvoice));
	ArrayOfTables.Add(GetDocumentTable_PurchaseReturnOrder(ArrayOf_PurchaseReturnOrder));
	ArrayOfTables.Add(GetDocumentTable_ShipmentConfirmation(ArrayOf_ShipmentConfirmation));
	
	Return JoinDocumentsStructure(ArrayOfTables, 
	"BasedOn, Company, Partner, LegalName, Agreement, Currency, PriceIncludeTax");
EndFunction

&AtServer
Function JoinDocumentsStructure(ArrayOfTables, UnjoinFields)
	
	ItemList = New ValueTable();
	ItemList.Columns.Add("BasedOn"			, New TypeDescription("String"));
	ItemList.Columns.Add("Company"			, New TypeDescription("CatalogRef.Companies"));
	ItemList.Columns.Add("Partner"			, New TypeDescription("CatalogRef.Partners"));
	ItemList.Columns.Add("LegalName"		, New TypeDescription("CatalogRef.Companies"));
	ItemList.Columns.Add("Agreement"		, New TypeDescription("CatalogRef.Agreements"));
	ItemList.Columns.Add("PriceIncludeTax"	, New TypeDescription("Boolean"));
	ItemList.Columns.Add("Currency"			, New TypeDescription("CatalogRef.Currencies"));
	ItemList.Columns.Add("ItemKey"			, New TypeDescription("CatalogRef.ItemKeys"));
	ItemList.Columns.Add("Store"			, New TypeDescription("CatalogRef.Stores"));
	ItemList.Columns.Add("PurchaseReturnOrder"
		, New TypeDescription("DocumentRef.PurchaseReturnOrder"));
	ItemList.Columns.Add("PurchaseInvoice"	, New TypeDescription("DocumentRef.PurchaseInvoice"));
	ItemList.Columns.Add("Unit"				, New TypeDescription("CatalogRef.Units"));
	ItemList.Columns.Add("Quantity"			, New TypeDescription(Metadata.DefinedTypes.typeQuantity.Type));
	ItemList.Columns.Add("TaxAmount"		, New TypeDescription(Metadata.DefinedTypes.typeAmount.Type));
	ItemList.Columns.Add("TotalAmount"		, New TypeDescription(Metadata.DefinedTypes.typeAmount.Type));
	ItemList.Columns.Add("NetAmount"		, New TypeDescription(Metadata.DefinedTypes.typeAmount.Type));
	ItemList.Columns.Add("OffersAmount"		, New TypeDescription(Metadata.DefinedTypes.typeAmount.Type));
	ItemList.Columns.Add("PriceType"		, New TypeDescription("CatalogRef.PriceTypes"));
	ItemList.Columns.Add("Price"			, New TypeDescription(Metadata.DefinedTypes.typePrice.Type));
	ItemList.Columns.Add("Key"				, New TypeDescription(Metadata.DefinedTypes.typeRowID.Type));
	ItemList.Columns.Add("RowKey"			, New TypeDescription("String"));
	ItemList.Columns.Add("DontCalculateRow" , New TypeDescription("Boolean"));
	
	TaxListMetadataColumns = Metadata.Documents.PurchaseReturn.TabularSections.TaxList.Attributes;
	TaxList = New ValueTable();
	TaxList.Columns.Add("Key"					, TaxListMetadataColumns.Key.Type);
	TaxList.Columns.Add("Tax"					, TaxListMetadataColumns.Tax.Type);
	TaxList.Columns.Add("Analytics"				, TaxListMetadataColumns.Analytics.Type);
	TaxList.Columns.Add("TaxRate"				, TaxListMetadataColumns.TaxRate.Type);
	TaxList.Columns.Add("Amount"				, TaxListMetadataColumns.Amount.Type);
	TaxList.Columns.Add("IncludeToTotalAmount"	, TaxListMetadataColumns.IncludeToTotalAmount.Type);
	TaxList.Columns.Add("ManualAmount"			, TaxListMetadataColumns.ManualAmount.Type);
	TaxList.Columns.Add("Ref"					, New TypeDescription("DocumentRef.PurchaseReturnOrder"));
	
	SpecialOffersMetadataColumns = Metadata.Documents.PurchaseReturn.TabularSections.SpecialOffers.Attributes;
	SpecialOffers = New ValueTable();
	SpecialOffers.Columns.Add("Key"		, SpecialOffersMetadataColumns.Key.Type);
	SpecialOffers.Columns.Add("Offer"	, SpecialOffersMetadataColumns.Offer.Type);
	SpecialOffers.Columns.Add("Amount"	, SpecialOffersMetadataColumns.Amount.Type);
	SpecialOffers.Columns.Add("Ref"		, New TypeDescription("DocumentRef.PurchaseReturnOrder"));
	
	SerialLotNumbersMetadataColumns = Metadata.Documents.PurchaseReturn.TabularSections.SerialLotNumbers.Attributes;
	SerialLotNumbers = New ValueTable();
	SerialLotNumbers.Columns.Add("Key"		       , SerialLotNumbersMetadataColumns.Key.Type);
	SerialLotNumbers.Columns.Add("SerialLotNumber" , SerialLotNumbersMetadataColumns.SerialLotNumber.Type);
	SerialLotNumbers.Columns.Add("Quantity"        , SerialLotNumbersMetadataColumns.Quantity.Type);
	SerialLotNumbers.Columns.Add("Ref"		       , New TypeDescription("DocumentRef.PurchaseReturnOrder"));
	
	ShipmentConfirmtionsMetadataColumns = Metadata.Documents.PurchaseReturn.TabularSections.ShipmentConfirmations.Attributes;
	ShipmentConfirmations = New ValueTable();
	ShipmentConfirmations.Columns.Add("Key"		                       , ShipmentConfirmtionsMetadataColumns.Key.Type);
	ShipmentConfirmations.Columns.Add("ShipmentConfirmation"           , ShipmentConfirmtionsMetadataColumns.ShipmentConfirmation.Type);
	ShipmentConfirmations.Columns.Add("Quantity"	                   , ShipmentConfirmtionsMetadataColumns.Quantity.Type);
	ShipmentConfirmations.Columns.Add("QuantityInShipmentConfirmation" , ShipmentConfirmtionsMetadataColumns.QuantityInShipmentConfirmation.Type);
	ShipmentConfirmations.Columns.Add("Ref"		                       , New TypeDescription("DocumentRef.PurchaseReturnOrder"));
	
	For Each TableStructure In ArrayOfTables Do
		For Each Row In TableStructure.ItemList Do
			FillPropertyValues(ItemList.Add(), Row);
		EndDo;
		For Each Row In TableStructure.TaxList Do
			FillPropertyValues(TaxList.Add(), Row);
		EndDo;
		For Each Row In TableStructure.SpecialOffers Do
			FillPropertyValues(SpecialOffers.Add(), Row);
		EndDo;
		For Each Row In TableStructure.SerialLotNumbers Do
			FillPropertyValues(SerialLotNumbers.Add(), Row);
		EndDo;
		For Each Row In TableStructure.ShipmentConfirmations Do
			FillPropertyValues(ShipmentConfirmations.Add(), Row);
		EndDo;		
	EndDo;
	
	ItemListCopy = ItemList.Copy();
	ItemListCopy.GroupBy(UnjoinFields);
	
	ArrayOfResults = New Array();
	
	For Each Row In ItemListCopy Do
		Result = New Structure(UnjoinFields);
		FillPropertyValues(Result, Row);
		
		Result.Insert("ItemList"		     , New Array());
		Result.Insert("TaxList"			     , New Array());
		Result.Insert("SpecialOffers"	     , New Array());
		Result.Insert("SerialLotNumbers"     , New Array());
		Result.Insert("ShipmentConfirmations" , New Array());
		
		Filter = New Structure(UnjoinFields);
		FillPropertyValues(Filter, Row);
		
		ArrayOfTaxListFilters = New Array();
		ArrayOfSpecialOffersFilters = New Array();
		ArrayOfSerialLotNumbersFilters = New Array();
		ArrayOfShipmentConfirmationsFilters = New Array();
		
		ItemListFiltered = ItemList.Copy(Filter);
		For Each RowItemList In ItemListFiltered Do
			NewRow = New Structure();
			
			For Each ColumnItemList In ItemListFiltered.Columns Do
				NewRow.Insert(ColumnItemList.Name, RowItemList[ColumnItemList.Name]);
			EndDo;
			
			NewRow.Key = RowItemList.RowKey;
			
			ArrayOfTaxListFilters.Add(New Structure("Ref, Key", RowItemList.PurchaseReturnOrder, NewRow.Key));
			ArrayOfSpecialOffersFilters.Add(New Structure("Ref, Key", RowItemList.PurchaseReturnOrder, NewRow.Key));
			ArrayOfSerialLotNumbersFilters.Add(New Structure("Ref, Key", RowItemList.PurchaseReturnOrder, NewRow.Key));
			ArrayOfShipmentConfirmationsFilters.Add(New Structure("Ref, Key", RowItemList.PurchaseReturnOrder, NewRow.Key));
						
			Result.ItemList.Add(NewRow);
		EndDo;
		
		For Each TaxListFilter In ArrayOfTaxListFilters Do
			For Each RowTaxList In TaxList.Copy(TaxListFilter) Do
				NewRow = New Structure();
				NewRow.Insert("Key"					, RowTaxList.Key);
				NewRow.Insert("Tax"					, RowTaxList.Tax);
				NewRow.Insert("Analytics"			, RowTaxList.Analytics);
				NewRow.Insert("TaxRate"				, RowTaxList.TaxRate);
				NewRow.Insert("Amount"				, RowTaxList.Amount);
				NewRow.Insert("IncludeToTotalAmount", RowTaxList.IncludeToTotalAmount);
				NewRow.Insert("ManualAmount"		, RowTaxList.ManualAmount);
				Result.TaxList.Add(NewRow);
			EndDo;
		EndDo;
		
		For Each SpecialOffersFilter In ArrayOfSpecialOffersFilters Do
			For Each RowSpecialOffers In SpecialOffers.Copy(SpecialOffersFilter) Do
				NewRow = New Structure();
				NewRow.Insert("Key", RowSpecialOffers.Key);
				NewRow.Insert("Offer", RowSpecialOffers.Offer);
				NewRow.Insert("Amount", RowSpecialOffers.Amount);
				Result.SpecialOffers.Add(NewRow);
			EndDo;
		EndDo;
		
		For Each SerialLotNumbersFilter In ArrayOfSerialLotNumbersFilters Do
			For Each RowSerialLotNumber In SerialLotNumbers.Copy(SerialLotNumbersFilter) Do
				NewRow = New Structure();
				NewRow.Insert("Key", RowSerialLotNumber.Key);
				NewRow.Insert("SerialLotNumber", RowSerialLotNumber.SerialLotNumber);
				NewRow.Insert("Quantity", RowSerialLotNumber.Quantity);
				Result.SerialLotNumbers.Add(NewRow);
			EndDo;
		EndDo;
		
		For Each ShipmentConfirmationsFilter In ArrayOfShipmentConfirmationsFilters Do
			For Each RowShipmentConfirmation In ShipmentConfirmations.Copy(ShipmentConfirmationsFilter) Do
				NewRow = New Structure();
				NewRow.Insert("Key"		                       , RowShipmentConfirmation.Key);
				NewRow.Insert("ShipmentConfirmation"           , RowShipmentConfirmation.ShipmentConfirmation);
				NewRow.Insert("Quantity"	                   , RowShipmentConfirmation.Quantity);
				NewRow.Insert("QuantityInShipmentConfirmation" , RowShipmentConfirmation.QuantityInShipmentConfirmation);
				Result.ShipmentConfirmations.Add(NewRow);
			EndDo;
		EndDo;
		
		ArrayOfResults.Add(Result);
	EndDo;
	Return ArrayOfResults;
EndFunction

&AtServer
Function GetDocumentTable_ShipmentConfirmation(ArrayOfBasisDocuments)
	Query = New Query();
	Query.Text =
		"SELECT ALLOWED
		|	""ShipmentConfirmation"" AS BasedOn,
		|	ReceiptInvoicing.Store AS Store,
		|	VALUE(Document.PurchaseReturnOrder.EmptyRef) AS PurchaseReturnOrder,
		|	ReceiptInvoicing.ItemKey AS ItemKey,
		|	CASE
		|		WHEN ReceiptInvoicing.ItemKey.Unit <> VALUE(Catalog.Units.EmptyRef)
		|			THEN ReceiptInvoicing.ItemKey.Unit
		|		ELSE ReceiptInvoicing.ItemKey.Item.Unit
		|	END AS Unit,
		|	CAST(ReceiptInvoicing.Basis AS Document.ShipmentConfirmation) AS ShipmentConfirmation,
		|	CAST(ReceiptInvoicing.Basis AS Document.ShipmentConfirmation).Company AS Company,
		|	CAST(ReceiptInvoicing.Basis AS Document.ShipmentConfirmation).Partner AS Partner,
		|	CAST(ReceiptInvoicing.Basis AS Document.ShipmentConfirmation).LegalName AS LegalName,
		|	ReceiptInvoicing.QuantityBalance AS Quantity
		|FROM
		|	AccumulationRegister.R1031B_ReceiptInvoicing.Balance(, Basis IN (&ArrayOfShipmentConfirmation)
		|	AND CAST(Basis AS
		|		Document.ShipmentConfirmation).TransactionType = VALUE(Enum.ShipmentConfirmationTransactionTypes.ReturnToVendor)) AS
		|		ReceiptInvoicing";
	Query.SetParameter("ArrayOfShipmentConfirmation", ArrayOfBasisDocuments);
	
	QueryTable = Query.Execute().Unload();
	Return ExtractInfoFromRows_ShipmentConfirmation(QueryTable);
EndFunction

&AtServer
Function GetDocumentTable_PurchaseReturnOrder(ArrayOfBasisDocuments)
	Query = New Query();
	Query.Text =
		"SELECT ALLOWED
		|	""PurchaseReturnOrder"" AS BasedOn,
		|	OrderBalanceBalance.Store AS Store,
		|	OrderBalanceBalance.Order AS PurchaseReturnOrder,
		|	OrderBalanceBalance.ItemKey,
		|	OrderBalanceBalance.RowKey,
		|	CASE
		|		WHEN OrderBalanceBalance.ItemKey.Unit <> VALUE(Catalog.Units.EmptyRef)
		|			THEN OrderBalanceBalance.ItemKey.Unit
		|		ELSE OrderBalanceBalance.ItemKey.Item.Unit
		|	END AS Unit,
		|	OrderBalanceBalance.QuantityBalance AS Quantity
		|FROM
		|	AccumulationRegister.OrderBalance.Balance(, Order IN (&ArrayOfOrders)) AS OrderBalanceBalance";
	Query.SetParameter("ArrayOfOrders", ArrayOfBasisDocuments);
	
	QueryTable = Query.Execute().Unload();
	Return ExtractInfoFromRows_PurchaseReturnOrder(QueryTable);
EndFunction

&AtServer
Function GetDocumentTable_PurchaseInvoice(ArrayOfBasisDocuments)
	Query = New Query();
	Query.Text =
		"SELECT ALLOWED
		|	""PurchaseInvoice"" AS BasedOn,
		|	Table.PurchaseInvoice AS PurchaseInvoice,
		|	Table.ItemKey,
		|	Table.RowKey,
		|	CASE
		|		WHEN Table.ItemKey.Unit <> VALUE(Catalog.Units.EmptyRef)
		|			THEN Table.ItemKey.Unit
		|		ELSE Table.ItemKey.Item.Unit
		|	END AS Unit,
		|	Table.QuantityTurnover AS Quantity,
		|	Table.Company AS Company
		|FROM
		|	AccumulationRegister.PurchaseTurnovers.Turnovers(,,, PurchaseInvoice IN (&ArrayOfBasises)
		|	AND CurrencyMovementType = VALUE(ChartOfCharacteristicTypes.CurrencyMovementType.SettlementCurrency)) AS Table
		|WHERE
		|	Table.QuantityTurnover > 0";
	Query.SetParameter("ArrayOfBasises", ArrayOfBasisDocuments);
	
	QueryTable = Query.Execute().Unload();
	Return ExtractInfoFromRows_PurchaseInvoice(QueryTable);
EndFunction

&AtServer
Function ExtractInfoFromRows_ShipmentConfirmation(QueryTable)
	ShipmentConfirmationsTable = CreateTable_ShipmentConfirmations();
	ItemList = QueryTable.Copy();
	ItemList.GroupBy("BasedOn, Store, PurchaseReturnOrder, ItemKey, Unit, Company, Partner, LegalName", "Quantity");
	ItemList.Columns.Add("Key", Metadata.DefinedTypes.typeRowID.Type);
	ItemList.Columns.Add("RowKey", Metadata.DefinedTypes.typeRowID.Type);
	For Each RowItemList In ItemList Do
		RowKey = String(New UUID());
		RowItemList.Key = RowKey;
		RowItemList.RowKey = RowKey;
		Filter = New Structure("BasedOn, Store, PurchaseReturnOrder, ItemKey, Unit, Company, Partner, LegalName");
		FillPropertyValues(Filter, RowItemList);
		For Each RowShipmentConfirmation In QueryTable.Copy(Filter) Do
			NewRowShipmentConfirmation = ShipmentConfirmationsTable.Add();
			NewRowShipmentConfirmation.Key = RowItemList.Key;
			NewRowShipmentConfirmation.ShipmentConfirmation = RowShipmentConfirmation.ShipmentConfirmation;
			NewRowShipmentConfirmation.Quantity = RowShipmentConfirmation.Quantity;
			NewRowShipmentConfirmation.QuantityInShipmentConfirmation = RowShipmentConfirmation.Quantity;
		EndDo;	
	EndDo;
	Return New Structure("ItemList, TaxList, SpecialOffers, SerialLotNumbers, ShipmentConfirmations", 
	ItemList, 
	New ValueTable(), 
	New ValueTable(),
	New ValueTable(),
	ShipmentConfirmationsTable);
EndFunction


&AtServer
Function ExtractInfoFromRows_PurchaseInvoice(QueryTable)
	QueryTable.Columns.Add("Key", New TypeDescription(Metadata.DefinedTypes.typeRowID.Type));
	For Each Row In QueryTable Do
		Row.Key = Row.RowKey;
	EndDo;
	
	Query = New Query();
	Query.Text =
		"SELECT
		|   QueryTable.BasedOn,
		|	QueryTable.PurchaseInvoice,
		|	QueryTable.ItemKey,
		|	QueryTable.Key,
		|	QueryTable.RowKey,
		|	QueryTable.Unit,
		|	QueryTable.Quantity
		|INTO tmpQueryTable
		|FROM
		|	&QueryTable AS QueryTable
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT ALLOWED
		|   tmpQueryTable.BasedOn AS BasedOn,
		|	tmpQueryTable.ItemKey AS ItemKey,
		|	tmpQueryTable.PurchaseInvoice AS PurchaseInvoice,
		|	UNDEFINED AS PurchaseReturnOrder,
		|	CAST(tmpQueryTable.PurchaseInvoice AS Document.PurchaseInvoice).Partner AS Partner,
		|	CAST(tmpQueryTable.PurchaseInvoice AS Document.PurchaseInvoice).LegalName AS LegalName,
		|	CAST(tmpQueryTable.PurchaseInvoice AS Document.PurchaseInvoice).Agreement AS Agreement,
		|	CAST(tmpQueryTable.PurchaseInvoice AS Document.PurchaseInvoice).PriceIncludeTax AS PriceIncludeTax,
		|	CAST(tmpQueryTable.PurchaseInvoice AS Document.PurchaseInvoice).Currency AS Currency,
		|	CAST(tmpQueryTable.PurchaseInvoice AS Document.PurchaseInvoice).Company AS Company,
		|
		|	tmpQueryTable.Key,
		|	tmpQueryTable.RowKey,
		|	tmpQueryTable.Unit AS QuantityUnit,
		|	tmpQueryTable.Quantity AS Quantity,
		|	ISNULL(ItemList.Price, 0) AS Price,
		|	ISNULL(ItemList.Unit, VALUE(Catalog.Units.EmptyRef)) AS Unit,
		|	ISNULL(ItemList.TaxAmount, 0) AS TaxAmount,
		|	ISNULL(ItemList.TotalAmount, 0) AS TotalAmount,
		|	ISNULL(ItemList.NetAmount, 0) AS NetAmount,
		|	ISNULL(ItemList.OffersAmount, 0) AS OffersAmount,
		|	ISNULL(ItemList.PriceType, VALUE(Catalog.PriceTypes.EmptyRef)) AS PriceType,
		|	ISNULL(ItemList.Store, VALUE(Catalog.Stores.EmptyRef)) AS Store,
		|	ISNULL(ItemList.DontCalculateRow, FALSE) AS DontCalculateRow
		|FROM
		|	tmpQueryTable AS tmpQueryTable
		|		INNER JOIN Document.PurchaseInvoice.ItemList AS ItemList
		|		ON tmpQueryTable.Key = ItemList.Key
		|		AND tmpQueryTable.PurchaseInvoice = ItemList.Ref
		|ORDER BY 
		|	ItemList.LineNumber
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	TaxList.Ref,
		|	TaxList.Key,
		|	TaxList.Tax,
		|	TaxList.Analytics,
		|	TaxList.TaxRate,
		|	TaxList.Amount,
		|	TaxList.IncludeToTotalAmount,
		|	TaxList.ManualAmount
		|FROM
		|	Document.PurchaseInvoice.TaxList AS TaxList
		|		INNER JOIN tmpQueryTable AS tmpQueryTable
		|		ON tmpQueryTable.PurchaseInvoice = TaxList.Ref
		|		AND tmpQueryTable.Key = TaxList.Key
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	SpecialOffers.Ref,
		|	SpecialOffers.Key,
		|	SpecialOffers.Offer,
		|	SpecialOffers.Amount
		|FROM
		|	Document.PurchaseInvoice.SpecialOffers AS SpecialOffers
		|		INNER JOIN tmpQueryTable AS tmpQueryTable
		|		ON tmpQueryTable.PurchaseInvoice = SpecialOffers.Ref
		|		AND tmpQueryTable.Key = SpecialOffers.Key
		|
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	SerialLotNumbers.Ref,
		|	SerialLotNumbers.Key,
		|	SerialLotNumbers.SerialLotNumber,
		|	SerialLotNumbers.Quantity
		|FROM
		|	Document.PurchaseInvoice.SerialLotNumbers AS SerialLotNumbers
		|		INNER JOIN tmpQueryTable AS tmpQueryTable
		|		ON tmpQueryTable.PurchaseInvoice = SerialLotNumbers.Ref
		|		AND tmpQueryTable.Key = SerialLotNumbers.Key
		|";
	
	Query.SetParameter("QueryTable", QueryTable);
	QueryResults = Query.ExecuteBatch();
	
	QueryTable_ItemList = QueryResults[1].Unload();
	DocumentsServer.RecalculateQuantityInTable(QueryTable_ItemList);
	
	QueryTable_TaxList = QueryResults[2].Unload();
	QueryTable_SpecialOffers = QueryResults[3].Unload();
	QueryTable_SerialLotNumbers = QueryResults[4].Unload();
	
	Return New Structure("ItemList, TaxList, SpecialOffers, SerialLotNumbers, ShipmentConfirmations", 
		QueryTable_ItemList, 
		QueryTable_TaxList, 
		QueryTable_SpecialOffers,
		QueryTable_SerialLotNumbers,
		New ValueTable());
EndFunction

&AtServer
Function ExtractInfoFromRows_PurchaseReturnOrder(QueryTable)
	QueryTable.Columns.Add("Key", New TypeDescription(Metadata.DefinedTypes.typeRowID.Type));
	For Each Row In QueryTable Do
		Row.Key = Row.RowKey;
	EndDo;
	
	Query = New Query();
	Query.Text =
		"SELECT
		|   QueryTable.BasedOn,
		|	QueryTable.Store,
		|	QueryTable.PurchaseReturnOrder,
		|	QueryTable.ItemKey,
		|	QueryTable.Key,
		|	QueryTable.RowKey,
		|	QueryTable.Unit,
		|	QueryTable.Quantity
		|INTO tmpQueryTable
		|FROM
		|	&QueryTable AS QueryTable
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT ALLOWED
		|	tmpQueryTable.BasedOn AS BasedOn,
		|	tmpQueryTable.ItemKey AS ItemKey,
		|	tmpQueryTable.Store AS Store,
		|	tmpQueryTable.PurchaseReturnOrder AS PurchaseReturnOrder,
		|	CAST(tmpQueryTable.PurchaseReturnOrder AS Document.PurchaseReturnOrder).Partner AS Partner,
		|	CAST(tmpQueryTable.PurchaseReturnOrder AS Document.PurchaseReturnOrder).LegalName AS LegalName,
		|	CAST(tmpQueryTable.PurchaseReturnOrder AS Document.PurchaseReturnOrder).Agreement AS Agreement,
		|	CAST(tmpQueryTable.PurchaseReturnOrder AS Document.PurchaseReturnOrder).PriceIncludeTax AS PriceIncludeTax,
		|	CAST(tmpQueryTable.PurchaseReturnOrder AS Document.PurchaseReturnOrder).Currency AS Currency,
		|	CAST(tmpQueryTable.PurchaseReturnOrder AS Document.PurchaseReturnOrder).Company AS Company,
		|	tmpQueryTable.Key,
		|	tmpQueryTable.RowKey,
		|	tmpQueryTable.Unit AS QuantityUnit,
		|	tmpQueryTable.Quantity AS Quantity,
		|	ISNULL(ItemList.Price, 0) AS Price,
		|	ISNULL(ItemList.Unit, VALUE(Catalog.Units.EmptyRef)) AS Unit,
		|	ISNULL(ItemList.TaxAmount, 0) AS TaxAmount,
		|	ISNULL(ItemList.TotalAmount, 0) AS TotalAmount,
		|	ISNULL(ItemList.NetAmount, 0) AS NetAmount,
		|	ISNULL(ItemList.OffersAmount, 0) AS OffersAmount,
		|	ISNULL(ItemList.PriceType, VALUE(Catalog.PriceTypes.EmptyRef)) AS PriceType,
		|	ISNULL(ItemList.PurchaseInvoice, VALUE(Document.PurchaseInvoice.EmptyRef)) AS PurchaseInvoice,
		|	ISNULL(ItemList.DontCalculateRow, FALSE) AS DontCalculateRow
		|FROM
		|	Document.PurchaseReturnOrder.ItemList AS ItemList
		|		INNER JOIN tmpQueryTable AS tmpQueryTable
		|		ON tmpQueryTable.Key = ItemList.Key
		|		AND tmpQueryTable.PurchaseReturnOrder = ItemList.Ref
		|ORDER BY 
		|	ItemList.LineNumber
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	TaxList.Ref,
		|	TaxList.Key,
		|	TaxList.Tax,
		|	TaxList.Analytics,
		|	TaxList.TaxRate,
		|	TaxList.Amount,
		|	TaxList.IncludeToTotalAmount,
		|	TaxList.ManualAmount
		|FROM
		|	Document.PurchaseReturnOrder.TaxList AS TaxList
		|		INNER JOIN tmpQueryTable AS tmpQueryTable
		|		ON tmpQueryTable.PurchaseReturnOrder = TaxList.Ref
		|		AND tmpQueryTable.Key = TaxList.Key
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	SpecialOffers.Ref,
		|	SpecialOffers.Key,
		|	SpecialOffers.Offer,
		|	SpecialOffers.Amount
		|FROM
		|	Document.PurchaseReturnOrder.SpecialOffers AS SpecialOffers
		|		INNER JOIN tmpQueryTable AS tmpQueryTable
		|		ON tmpQueryTable.PurchaseReturnOrder = SpecialOffers.Ref
		|		AND tmpQueryTable.Key = SpecialOffers.Key";
		
	Query.SetParameter("QueryTable", QueryTable);
	QueryResults = Query.ExecuteBatch();
	
	QueryTable_ItemList = QueryResults[1].Unload();
	DocumentsServer.RecalculateQuantityInTable(QueryTable_ItemList);
	
	QueryTable_TaxList = QueryResults[2].Unload();
	QueryTable_SpecialOffers = QueryResults[3].Unload();
	
	Return New Structure("ItemList, TaxList, SpecialOffers, SerialLotNumbers, ShipmentConfirmations", 
		QueryTable_ItemList, 
		QueryTable_TaxList, 
		QueryTable_SpecialOffers,
		New ValueTable(),
		New ValueTable());
EndFunction

Function CreateTable_ShipmentConfirmations()
	ColumnsMetadata = Metadata.Documents.PurchaseReturn.TabularSections.ShipmentConfirmations.Attributes;
	GoodsReceiptsTable = New ValueTable();
	GoodsReceiptsTable.Columns.Add("Key", ColumnsMetadata.Key.Type);
	GoodsReceiptsTable.Columns.Add("ShipmentConfirmation", ColumnsMetadata.ShipmentConfirmation.Type);
	GoodsReceiptsTable.Columns.Add("Quantity", ColumnsMetadata.Quantity.Type);
	GoodsReceiptsTable.Columns.Add("QuantityInShipmentConfirmation", ColumnsMetadata.Quantity.Type);
	GoodsReceiptsTable.Columns.Add("Ref" , New TypeDescription("DocumentRef.PurchaseReturnOrder"));
	Return GoodsReceiptsTable;
EndFunction

#Region Errors

&AtServer
Function GetInfoMessage(FillingData)
	InfoMessage = "";
	If FillingData.BasedOn = "PurchaseReturnOrder" Then
		BasisDocument = New Array();
		For Each Row In FillingData.ItemList Do
			BasisDocument.Add(Row.PurchaseReturnOrder);
		EndDo;
		If PurchaseReturnExist(BasisDocument) Then
			InfoMessage = StrTemplate(R().InfoMessage_001, 
										Metadata.Documents.PurchaseReturn.Synonym,
										Metadata.Documents.PurchaseReturnOrder.Synonym);
		EndIf;
	EndIf;
	Return InfoMessage;	
EndFunction

&AtServer
Function PurchaseReturnExist(BasisDocument)
	Query = New Query(
	"SELECT TOP 1
	|	PurchaseTurnoversTurnovers.Recorder,
	|	PurchaseTurnoversTurnovers.QuantityTurnover AS QuantityTurnover
	|FROM
	|	AccumulationRegister.PurchaseTurnovers.Turnovers(, , Recorder, PurchaseInvoice IN (&BasisDocument)) AS PurchaseTurnoversTurnovers
	|WHERE
	|	VALUETYPE(PurchaseTurnoversTurnovers.Recorder) = TYPE(Document.PurchaseReturn)");
	Query.SetParameter("BasisDocument", BasisDocument);
	Return Not Query.Execute().IsEmpty();
EndFunction

&AtServer
Function GetErrorMessage(BasisDocument)
	ErrorMessage = Undefined;
	
	If TypeOf(BasisDocument) = Type("DocumentRef.PurchaseReturnOrder") Then
		If Not BasisDocument.Status.Posting Or Not BasisDocument.Posted Then
			Return StrTemplate(R().Error_054, String(BasisDocument));		
		EndIf;
	EndIf;
	
	If TypeOf(BasisDocument) = Type("DocumentRef.PurchaseInvoice") Then
		ErrorMessage = StrTemplate(R().Error_021, Metadata.Documents.PurchaseInvoice.Synonym);
	EndIf;
	
	Return ErrorMessage;
EndFunction

#EndRegion
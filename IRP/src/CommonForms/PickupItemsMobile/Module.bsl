&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	If Parameters.Property("Stores") Then
		ThisObject.Stores.LoadValues(Parameters.Stores);
	EndIf;
	
	If Parameters.Property("ReceiverStores") Then
		ThisObject.ReceiverStores.LoadValues(Parameters.ReceiverStores);
		ThisObject.Items.ItemListInStockReceiver.Visible = True;
		ThisObject.Items.ItemKeyListInStockReceiver.Visible = True;
	Else
		ThisObject.Items.ItemListInStockReceiver.Visible = False;
		ThisObject.Items.ItemKeyListInStockReceiver.Visible = False;
	EndIf;
	
	If Parameters.Property("EndPeriod") Then
		ThisObject.EndPeriod = Parameters.EndPeriod;
	EndIf;
	
	If Parameters.Property("PriceType") Then
		ThisObject.PriceType = Parameters.PriceType;
		ThisObject.Items.ItemListPrice.Visible = True;
		ThisObject.Items.ItemKeyListPrice.Visible = True;
		ThisObject.Items.ItemTableValuePrice.Visible = True;
		ThisObject.Items.ItemTableValueAmount.Visible = True;
	Else
		ThisObject.Items.ItemListPrice.Visible = False;
		ThisObject.Items.ItemTableValuePrice.Visible = False;
		ThisObject.Items.ItemKeyListPrice.Visible = False;
		ThisObject.Items.ItemTableValueAmount.Visible = False;
	EndIf;
	
	If Parameters.Property("UseBox") Then
		ThisObject.UseBox = Parameters.UseBox;
	EndIf;
	
	ItemTypeAfterSelection();
EndProcedure

&AtServer
Procedure ItemTypeAfterSelection()
	ItemList.Clear();
	CurrentItem = Items.GroupItems;
	TitleFilter = "";
	FilterTitleOnEdit(TitleFilter);
	ItemValueTable = ThisObject.ItemTableValue.Unload( , "Item, Quantity");
	ItemValueTable.GroupBy("Item", "Quantity");
	Query = New Query;
	Query.Text = "SELECT
		|	ItemValueTable.Item,
		|	ItemValueTable.Quantity
		|INTO ItemPickedOut
		|FROM
		|	&ItemValueTable AS ItemValueTable
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	StockReservationBalance.ItemKey.Item AS Item,
		|	SUM(StockReservationBalance.QuantityBalance) AS QuantityBalance
		|INTO ItemBalance
		|FROM
		|	AccumulationRegister.StockReservation.Balance(&EndPeriod, Store IN (&Stores)
		|	AND &ItemType) AS StockReservationBalance
		|GROUP BY
		|	StockReservationBalance.ItemKey.Item
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	StockReservationBalance.ItemKey.Item AS Item,
		|	SUM(StockReservationBalance.QuantityBalance) AS QuantityBalanceReceiver
		|INTO ItemBalanceReceiver
		|FROM
		|	AccumulationRegister.StockReservation.Balance(&EndPeriod, Store IN (&ReceiverStores)
		|	AND &ItemType) AS StockReservationBalance
		|GROUP BY
		|	StockReservationBalance.ItemKey.Item
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	ItemKey.Item,
		|	SUM(1) AS ItemKeyCount
		|INTO Items
		|FROM
		|	Catalog.ItemKeys AS ItemKey
		|WHERE
		|	NOT ItemKey.DeletionMark
		|	AND NOT ItemKey.Item.DeletionMark
		|	AND &ItemType
		|	AND &UseBox
		|GROUP BY
		|	ItemKey.Item
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	Items.Item AS Item,
		|	Items.Item.Unit AS Unit,
		|	ItemBalance.QuantityBalance,
		|	ItemBalanceReceiver.QuantityBalanceReceiver,
		|	ItemPickedOut.Quantity AS QuantityPickedOut,
		|	Items.ItemKeyCount,
		|	&PriceType AS PriceType,
		|	0 AS Price
		|FROM
		|	Items AS Items
		|		LEFT JOIN ItemBalance AS ItemBalance
		|		ON Items.Item = ItemBalance.Item
		|		LEFT JOIN ItemPickedOut AS ItemPickedOut
		|		ON Items.Item = ItemPickedOut.Item
		|		LEFT JOIN ItemBalanceReceiver AS ItemBalanceReceiver
		|		ON Items.Item = ItemBalanceReceiver.Item";
	Query.SetParameter("ItemValueTable", ItemValueTable);
	Query.SetParameter("EndPeriod", ThisObject.EndPeriod);
	Query.SetParameter("Stores", ThisObject.Stores);
	Query.SetParameter("PriceType", PriceType);
	Query.SetParameter("ReceiverStores", ThisObject.ReceiverStores);
	If ValueIsFilled(ThisObject.ItemType) Then
		Query.Text = StrReplace(Query.Text, "&ItemType", "ItemKey.Item.ItemType = &ItemType");
		Query.SetParameter("ItemType", ThisObject.ItemType);
	Else
		Query.SetParameter("ItemType", True);
	EndIf;
	If ThisObject.UseBox Then
		Query.SetParameter("UseBox", True);
	Else
		Query.Text = StrReplace(Query.Text, "&UseBox", "ItemKey.Item REFS Catalog.Items");
	EndIf;
	QueryExecution = Query.Execute();
	If Not QueryExecution.IsEmpty() Then
		QueryUnload = QueryExecution.Unload();
		TableOneItemKey = QueryUnload.Copy(New Structure("ItemKeyCount", 1), "Item");
		
		ItemsOneItemKeyArray = TableOneItemKey.UnloadColumn("Item");
		
		TableOfItemKeysInfo = Catalogs.Items.GetTableOfItemKeysInfoByItems(ItemsOneItemKeyArray);
		TableOfItemKeysInfo.Columns.Add("PriceType", New TypeDescription("CatalogRef.PriceTypes"));
		TableOfItemKeysInfo.FillValues(ThisObject.PriceType, "PriceType");
		
		PricesResult = GetItemInfo.ItemPriceInfoByTable(TableOfItemKeysInfo, ThisObject.EndPeriod);
		
		QueryPrice = New Query;
		QueryPrice.Text = "SELECT
			|	ItemKeys.Ref AS ItemKey,
			|	CASE
			|		WHEN ItemKeys.Unit = VALUE(Catalog.Units.EmptyRef)
			|			THEN ItemKeys.Item.Unit
			|		ELSE ItemKeys.Unit
			|	END AS Unit,
			|	ItemKeys.Item,
			|	ItemKeys.AffectPricingMD5 as AffectPricingMD5
			|INTO ItemKeys
			|FROM
			|	Catalog.ItemKeys AS ItemKeys
			|WHERE
			|	ItemKeys.Item IN (&Items)
			|	AND
			|	NOT ItemKeys.DeletionMark
			|;
			|//////////////////////////////////////////////////////////////////////////////////////////////////////////
			|SELECT
			|	PricesResult.Price,
			|	PricesResult.Unit,
			|	PricesResult.PriceType,
			|	PricesResult.ItemKey
			|INTO T_PricesResult
			|FROM
			|	&PricesResult AS PricesResult
			|
			|;
			|////////////////////////////////////////////////////////////////////////////////
			|SELECT
			|	ItemKeys.ItemKey.Item AS Item,
			|	IsNull(PricesResult.Price, 0) AS Price
			|FROM
			|	ItemKeys AS ItemKeys
			|		LEFT JOIN T_PricesResult AS PricesResult
			|		ON ItemKeys.ItemKey = PricesResult.ItemKey";
		
		QueryPrice.SetParameter("Items", ItemsOneItemKeyArray);
		QueryPrice.SetParameter("PricesResult", PricesResult);
		
		QueryPriceExecution = QueryPrice.Execute();
		If Not QueryPriceExecution.IsEmpty() Then
			QueryPriceUnload = QueryPriceExecution.Unload();
			LastQuery = New Query;
			LastQuery.Text = "SELECT
				|	Items.Item,
				|	Items.QuantityBalance,
				|	Items.QuantityBalanceReceiver,
				|	Items.QuantityPickedOut,
				|	Items.ItemKeyCount
				|INTO Items
				|FROM
				|	&Items AS Items
				|;
				|////////////////////////////////////////////////////////////////////////////////
				|SELECT
				|	Prices.Item,
				|	Prices.Price AS Price
				|INTO Prices
				|FROM
				|	&Prices AS Prices
				|;
				|////////////////////////////////////////////////////////////////////////////////
				|SELECT
				|	Items.Item,
				|	Items.QuantityBalance,
				|	Items.QuantityBalanceReceiver,
				|	Items.QuantityPickedOut,
				|	Items.ItemKeyCount,
				|	ISNULL(Prices.Price, 0) AS Price
				|FROM
				|	Items AS Items
				|		LEFT JOIN Prices AS Prices
				|		ON Items.Item = Prices.Item";
			LastQuery.SetParameter("Items", QueryUnload);
			LastQuery.SetParameter("Prices", QueryPriceUnload);
			LastQueryExecution = LastQuery.Execute();
			If Not LastQueryExecution.IsEmpty() Then
				LastQueryUnload = LastQueryExecution.Unload();
				QueryUnload = LastQueryUnload;
			EndIf;
		EndIf;
		For Each Row In QueryUnload Do
			NewRow = ItemList.Add();
			NewRow.Item = Row.Item;
			NewRow.Title = Row.Item;
			NewRow.InStock = Row.QuantityBalance;
			NewRow.InStockReceiver = Row.QuantityBalanceReceiver;
			NewRow.PickedOut = Row.QuantityPickedOut;
			NewRow.ItemKeyCount = Row.ItemKeyCount;
			NewRow.Price = Row.Price;
		EndDo;
	EndIf;
EndProcedure

&AtClient
Procedure ItemListSelection(Item, RowSelected, Field, StandardProcessing)
	
	StandardProcessing = False;
	
	CurrentRow = Items.ItemList.CurrentData;
	
	TransferParameters = New Structure;
	TransferParameters.Insert("Item", CurrentRow.Item);
	
	ItemListSelectionAfterResult = ItemListSelectionAfter(TransferParameters);
	
	If Not ItemListSelectionAfterResult Then
		CurrentItem = Items.GroupItemKeys;
		ChangeVisible(False);
		TitleFilter = "";
		FilterTitleOnEdit(TitleFilter);
	EndIf;
	
EndProcedure

&AtClient
Procedure PickupItemsSubEnd(Result, AdditionalParameters) Export
	If NOT ValueIsFilled(Result) Then
		Return;
	EndIf;
EndProcedure

&AtServer
Function ItemListSelectionAfter(ParametersStructure)
	ReturnValue = False;
	ItemKeyList.Clear();
	ItemValueTable = ThisObject.ItemTableValue.Unload( , "ItemKey, Quantity");
	ItemValueTable.GroupBy("ItemKey", "Quantity");
	
	
	TableOfItemKeysInfo = Catalogs.Items.GetTableOfItemKeysInfoByItems(ParametersStructure.Item);
	TableOfItemKeysInfo.Columns.Add("PriceType", New TypeDescription("CatalogRef.PriceTypes"));
	TableOfItemKeysInfo.FillValues(ThisObject.PriceType, "PriceType");
	
	PricesResult = GetItemInfo.ItemPriceInfoByTable(TableOfItemKeysInfo, ThisObject.EndPeriod);
	
	Query = New Query;
	Query.Text = "////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	ItemValueTable.ItemKey,
		|	ItemValueTable.Quantity
		|INTO ItemPickedOut
		|FROM
		|	&ItemValueTable AS ItemValueTable
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	ItemKeys.Ref AS ItemKey,
		|	CASE
		|		WHEN ItemKeys.Unit = VALUE(Catalog.Units.EmptyRef)
		|			THEN ItemKeys.Item.Unit
		|		ELSE ItemKeys.Unit
		|	END AS Unit,
		|	ItemKeys.Item,
		|	ItemKeys.AffectPricingMD5
		|INTO ItemKeyTempTable
		|FROM
		|	Catalog.ItemKeys AS ItemKeys
		|WHERE
		|	NOT ItemKeys.DeletionMark
		|	AND
		|	NOT ItemKeys.Item.DeletionMark
		|	AND ItemKeys.Item = &Item
		|;
		|///////////////////////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	PricesResult.Price,
		|	PricesResult.Unit,
		|	PricesResult.PriceType,
		|	PricesResult.ItemKey
		|INTO T_PricesResult
		|FROM
		|	&PricesResult AS PricesResult
		|
		|;
		|///////////////////////////////////////////////////////
		|SELECT
		|	ItemKeyTempTable.ItemKey AS ItemKey,
		|	ItemKeyTempTable.Unit AS Unit,
		|	StockReservationBalance.QuantityBalance,
		|	StockReservationBalanceReceiver.QuantityBalance AS QuantityBalanceReceiver,
		|	ItemPickedOut.Quantity AS QuantityPickedOut,
		|	PricesResult.Price
		|FROM
		|	ItemKeyTempTable AS ItemKeyTempTable
		|		LEFT JOIN AccumulationRegister.StockReservation.Balance(&EndPeriod, Store IN (&Stores)
		|		AND ItemKey.Item = &Item) AS StockReservationBalance
		|		ON ItemKeyTempTable.ItemKey = StockReservationBalance.ItemKey
		|		LEFT JOIN AccumulationRegister.StockReservation.Balance(&EndPeriod, Store IN (&ReceiverStores)
		|		AND ItemKey.Item = &Item) AS StockReservationBalanceReceiver
		|		ON ItemKeyTempTable.ItemKey = StockReservationBalanceReceiver.ItemKey
		|		LEFT JOIN ItemPickedOut AS ItemPickedOut
		|		ON ItemKeyTempTable.ItemKey = ItemPickedOut.ItemKey
		|		LEFT JOIN T_PricesResult AS PricesResult
		|		ON ItemKeyTempTable.ItemKey = PricesResult.ItemKey";
	Query.SetParameter("Stores", ThisObject.Stores);
	Query.SetParameter("ReceiverStores", ThisObject.ReceiverStores);
	Query.SetParameter("EndPeriod", ThisObject.EndPeriod);
	Query.SetParameter("PriceType", ThisObject.PriceType);
	Query.SetParameter("Item", ParametersStructure.Item);
	Query.SetParameter("ItemValueTable", ItemValueTable);
	Query.SetParameter("PricesResult", PricesResult);
	
	QueryExecution = Query.Execute();
	If Not QueryExecution.IsEmpty() Then
		QuerySelection = QueryExecution.Select();
		If QuerySelection.Count() = 1 Then
			QuerySelection.Next();
			ReturnValue = True;
			TransferParameters = New Structure;
			TransferParameters.Insert("Item", ParametersStructure.Item);
			TransferParameters.Insert("ItemKey", QuerySelection.ItemKey);
			TransferParameters.Insert("Unit", QuerySelection.Unit);
			TransferParameters.Insert("Price", QuerySelection.Price);
			ItemKeyListSelectionAfter(TransferParameters);
		Else
			While QuerySelection.Next() Do
				NewRow = ItemKeyList.Add();
				NewRow.ItemKey = QuerySelection.ItemKey;
				NewRow.Title = QuerySelection.ItemKey;
				NewRow.InStock = QuerySelection.QuantityBalance;
				NewRow.InStockReceiver = QuerySelection.QuantityBalanceReceiver;
				NewRow.PickedOut = QuerySelection.QuantityPickedOut;
				NewRow.Price = QuerySelection.Price;
				NewRow.Unit = QuerySelection.Unit;
			EndDo;
		EndIf;
	EndIf;
	Return ReturnValue;
EndFunction

&AtClient
Procedure CommandBack(Command)
	ChangeVisible(True);
	ItemTypeAfterSelection();
EndProcedure

&AtClient
Procedure ChangeVisible(Visible = True)
	Items.GroupItemKeys.Visible = Not Visible;
	Items.GroupItems.Visible = Visible;
EndProcedure

&AtClient
Procedure CommandSaveAndClose(Command)
	Close(ThisObject.ItemTableValue);
EndProcedure

&AtClient
Procedure ItemKeyListSelection(Item, RowSelected, Field, StandardProcessing)
	StandardProcessing = False;
	TransferParameters = New Structure;
	CurrentRow = Items.ItemKeyList.CurrentData;
	TransferParameters.Insert("Item", ServiceSystemServer.GetObjectAttribute(CurrentRow.ItemKey, "Item"));
	TransferParameters.Insert("ItemKey", CurrentRow.ItemKey);
	TransferParameters.Insert("Price", CurrentRow.Price);
	TransferParameters.Insert("Unit", CurrentRow.Unit);
	ItemKeyListSelectionAfter(TransferParameters);
	
	TransferParameters = New Structure;
	TransferParameters.Insert("Item", ServiceSystemServer.GetObjectAttribute(CurrentRow.ItemKey, "Item"));
	ItemListSelectionAfter(TransferParameters);
EndProcedure

&AtServer
Procedure ItemKeyListSelectionAfter(ParametersStructure)
	SearchStructure = New Structure;
	SearchStructure.Insert("ItemKey", ParametersStructure.ItemKey);
	FoundedRows = ItemTableValue.FindRows(SearchStructure);
	If FoundedRows.Count() Then
		ItemRow = FoundedRows.Get(0);
		ItemRow.Quantity = ItemRow.Quantity + 1;
	Else
		ItemRow = ItemTableValue.Add();
		ItemRow.Item = ParametersStructure.Item;
		ItemRow.ItemKey = ParametersStructure.ItemKey;
		ItemRow.Quantity = 1;
		ItemRow.Price = ParametersStructure.Price;
		ItemRow.Unit = ParametersStructure.Unit;
	EndIf;
	ItemRow.Amount = ItemRow.Quantity * ItemRow.Price;
	ItemTypeAfterSelection();
EndProcedure

&AtClient
Procedure ItemTableValuePriceOnChange(Item)
	CalculateAmount();
EndProcedure

&AtClient
Procedure CalculateAmount()
	CurrentRow = ThisObject.Items.ItemTableValue.CurrentData;
	If CurrentRow = Undefined Then
		Return;
	EndIf;
	CurrentRow.Amount = CurrentRow.Quantity * CurrentRow.Price;
EndProcedure

&AtClient
Procedure ItemTypeOnChange(Item)
	ItemTypeAfterSelection();
EndProcedure

&AtClient
Procedure ItemTableValueQuantityOnChange(Item)
	ItemTypeAfterSelection();
EndProcedure

&AtClient
Procedure TitleFilterClearing(Item, StandardProcessing)
	FilterTitleOnEdit();
EndProcedure

&AtServer
Procedure FilterTitleOnEdit(Val Text = "")
	If Items.GroupItems.Visible Then
		Items.ItemList.RowFilter = New FixedStructure("Title", Text);
	ElsIf Items.GroupItemKeys.Visible Then
		Items.ItemKeyList.RowFilter = New FixedStructure("Title", Text);
	Else
		Return;
	EndIf;
EndProcedure

&AtClient
Procedure TitleFilterOnChange(Item)
	FilterTitleOnEdit(TitleFilter);
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	ChangeVisible(True);
EndProcedure

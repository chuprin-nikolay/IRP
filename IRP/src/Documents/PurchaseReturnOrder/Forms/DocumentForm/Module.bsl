#Region FormEvents
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	DocPurchaseReturnOrderServer.OnCreateAtServer(Object, ThisObject, Cancel, StandardProcessing);
	If Parameters.Key.IsEmpty() Then
		SetVisibilityAvailability(Object, ThisObject);
	EndIf;
EndProcedure

&AtClient
Procedure OnOpen(Cancel, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.OnOpen(Object, ThisObject, Cancel);
EndProcedure

&AtClient
Procedure NotificationProcessing(EventName, Parameter, Source, AddInfo = Undefined) Export
	If EventName = "UpdateAddAttributeAndPropertySets" Then
		AddAttributesCreateFormControl();
	EndIf;
	If Not Source = ThisObject Then
		Return;
	EndIf;
	
	DocPurchaseReturnOrderClient.NotificationProcessing(Object, ThisObject, EventName, Parameter, Source);
	
	ServerData = Undefined;		
	If TypeOf(Parameter) = Type("Structure") And Parameter.Property("AddInfo") Then
		ServerData = CommonFunctionsClientServer.GetFromAddInfo(Parameter.AddInfo, "ServerData");
	EndIf;
	
	If EventName = "NewBarcode" And IsInputAvailable() Then
		SearchByBarcode(Undefined, Parameter);
	EndIf;
	
	If Upper(EventName) = Upper("CallbackHandler") Then
		CurrenciesClient.CalculateAmount(Object, ThisObject);
		CurrenciesClient.SetRatePresentation(Object, ThisObject);
				
		If ServerData <> Undefined Then
			CurrenciesClient.SetVisibleRows(Object, ThisObject, Parameter.AddInfo);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure BeforeWrite(Cancel, WriteParameters)
	Return;
EndProcedure

&AtServer
Procedure OnWriteAtServer(Cancel, CurrentObject, WriteParameters)
	DocumentsServer.OnWriteAtServer(Object, ThisObject, Cancel, CurrentObject, WriteParameters);
EndProcedure

&AtClient
Procedure AfterWrite(WriteParameters, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.AfterWriteAtClient(Object, ThisObject, WriteParameters);
EndProcedure

&AtServer
Procedure AfterWriteAtServer(CurrentObject, WriteParameters, AddInfo = Undefined) Export
	DocPurchaseReturnOrderServer.AfterWriteAtServer(Object, ThisObject, CurrentObject, WriteParameters);
	SetVisibilityAvailability(CurrentObject, ThisObject);
EndProcedure

&AtServer
Procedure OnReadAtServer(CurrentObject)
	DocPurchaseReturnOrderServer.OnReadAtServer(Object, ThisObject, CurrentObject);
	SetVisibilityAvailability(CurrentObject, ThisObject);
EndProcedure

&AtServer
Procedure BeforeWriteAtServer(Cancel, CurrentObject, WriteParameters)
	AddAttributesAndPropertiesServer.BeforeWriteAtServer(ThisObject, Cancel, CurrentObject, WriteParameters);
EndProcedure

&AtClientAtServerNoContext
Procedure SetVisibilityAvailability(Object, Form) Export
	Form.Items.LegalName.Enabled = ValueIsFilled(Object.Partner);
EndProcedure

#EndRegion

#Region FormItemsEvents

&AtClient
Procedure StatusOnChange(Item)
	DocPurchaseReturnOrderClient.StatusOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure DateOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.DateOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure StoreOnChange(Item)
	DocPurchaseReturnOrderClient.StoreOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure PartnerOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.PartnerOnChange(Object, ThisObject, Item);
	SetVisibilityAvailability(Object, ThisObject);
EndProcedure

&AtClient
Procedure LegalNameOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.LegalNameOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure AgreementOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.AgreementOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure CompanyOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.CompanyOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure PriceIncludeTaxOnChange(Item)
	DocPurchaseReturnOrderClient.PriceIncludeTaxOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure CurrencyOnChange(Item)
	DocPurchaseReturnOrderClient.CurrencyOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure NumberOnChange(Item)
	DocPurchaseReturnOrderClient.NumberOnChange(Object, ThisObject, Item);
EndProcedure

#EndRegion

#Region ItemListEvents

&AtClient
Procedure ItemListAfterDeleteRow(Item)
	DocPurchaseReturnOrderClient.ItemListAfterDeleteRow(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.ItemListOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListOnStartEdit(Item, NewRow, Clone)
	If Clone Then
		Item.CurrentData.Key = New UUID();
	EndIf;
	DocumentsClient.TableOnStartEdit(Object, ThisObject, "Object.ItemList", Item, NewRow, Clone);
EndProcedure

&AtClient
Procedure ItemListOnActivateRow(Item)
	DocPurchaseReturnOrderClient.ItemListOnActivateRow(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListSelection(Item, RowSelected, Field, StandardProcessing)
	DocPurchaseReturnOrderClient.ItemListSelection(Object, ThisObject, Item, RowSelected, Field, StandardProcessing);
EndProcedure

#EndRegion

#Region ItemListItemsEvents

&AtClient
Procedure ItemListItemOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.ItemListItemOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListItemStartChoice(Item, ChoiceData, StandardProcessing)
	DocPurchaseReturnOrderClient.ItemListItemStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure ItemListItemEditTextChange(Item, Text, StandardProcessing)
	DocPurchaseReturnOrderClient.ItemListItemEditTextChange(Object, ThisObject, Item, Text, StandardProcessing);
EndProcedure

&AtClient
Procedure ItemListItemKeyOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.ItemListItemKeyOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListUnitOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.ItemListUnitOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListQuantityOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.ItemListQuantityOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListPriceOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.ItemListPriceOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListTotalAmountOnChange(Item, AddInfo = Undefined) Export
	DocPurchaseReturnOrderClient.ItemListTotalAmountOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListTaxAmountOnChange(Item)
	DocPurchaseReturnOrderClient.ItemListTaxAmountOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListDontCalculateRowOnChange(Item)
	DocPurchaseReturnOrderClient.ItemListDontCalculateRowOnChange(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure ItemListStoreOnChange(Item)
	DocPurchaseReturnOrderClient.ItemListStoreOnChange(Object, ThisObject, Item);
EndProcedure

#EndRegion

#Region ItemPartner

&AtClient
Procedure PartnerStartChoice(Item, ChoiceData, StandardProcessing)
	DocPurchaseReturnOrderClient.PartnerStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure PartnerEditTextChange(Item, Text, StandardProcessing)
	DocPurchaseReturnOrderClient.PartnerTextChange(Object, ThisObject, Item, Text, StandardProcessing);
EndProcedure

#EndRegion

#Region ItemLegalName

&AtClient
Procedure LegalNameStartChoice(Item, ChoiceData, StandardProcessing)
	DocPurchaseReturnOrderClient.LegalNameStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure LegalNameEditTextChange(Item, Text, StandardProcessing)
	DocPurchaseReturnOrderClient.LegalNameTextChange(Object, ThisObject, Item, Text, StandardProcessing);
EndProcedure

#EndRegion

#Region ItemAgreement

&AtClient
Procedure AgreementStartChoice(Item, ChoiceData, StandardProcessing)
	DocPurchaseReturnOrderClient.AgreementStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure AgreementEditTextChange(Item, Text, StandardProcessing)
	DocPurchaseReturnOrderClient.AgreementTextChange(Object, ThisObject, Item, Text, StandardProcessing);
EndProcedure

&AtClient
Procedure DateStartListChoice(Item, StandardProcessing)
	CurrentPartner = Object.Partner;
	CurrentAgreement = Object.Agreement;
	CurrentDate = Object.Date;
EndProcedure

#EndRegion

#Region ItemCompany

&AtClient
Procedure CompanyStartChoice(Item, ChoiceData, StandardProcessing)
	DocPurchaseReturnOrderClient.CompanyStartChoice(Object, ThisObject, Item, ChoiceData, StandardProcessing);
EndProcedure

&AtClient
Procedure CompanyEditTextChange(Item, Text, StandardProcessing)
	DocPurchaseReturnOrderClient.CompanyEditTextChange(Object, ThisObject, Item, Text, StandardProcessing);
EndProcedure

#EndRegion

#Region DescriptionEvents

&AtClient
Procedure DescriptionClick(Item, StandardProcessing)
	DocumentsClient.DescriptionClick(Object, ThisObject, Item, StandardProcessing);
EndProcedure

#EndRegion

#Region GroupTitleDecorations

&AtClient
Procedure DecorationGroupTitleCollapsedPictureClick(Item)
	DocumentsClient.DecorationGroupTitleCollapsedPictureClick(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure DecorationGroupTitleCollapsedLabelClick(Item)
	DocumentsClient.DecorationGroupTitleCollapsedLabelClick(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure DecorationGroupTitleUncollapsedPictureClick(Item)
	DocumentsClient.DecorationGroupTitleUncollapsedPictureClick(Object, ThisObject, Item);
EndProcedure

&AtClient
Procedure DecorationGroupTitleUncollapsedLabelClick(Item)
	DocumentsClient.DecorationGroupTitleUncollapsedLabelClick(Object, ThisObject, Item);
EndProcedure

#EndRegion

#Region Taxes

&AtClient
Procedure TaxValueOnChange(Item) Export
	DocPurchaseReturnOrderClient.ItemListTaxValueOnChange(Object, ThisObject, Item);
EndProcedure

&AtServer
Function Taxes_CreateFormControls(AddInfo = Undefined) Export
	Return TaxesServer.CreateFormControls_RetailDocuments(Object, ThisObject, AddInfo);
EndFunction

#EndRegion

#Region Commands

&AtClient
Procedure DecorationStatusHistoryClick(Item)
	ObjectStatusesClient.OpenHistoryByStatus(Object.Ref, ThisObject);
EndProcedure

&AtClient
Procedure OpenPickupItems(Command)
	DocPurchaseReturnOrderClient.OpenPickupItems(Object, ThisObject, Command);
EndProcedure

&AtClient
Procedure SearchByBarcode(Command, Barcode = "")
	DocPurchaseReturnOrderClient.SearchByBarcode(Barcode, Object, ThisObject);
EndProcedure

&AtClient
Procedure ShowRowKey(Command)
	DocumentsClient.ShowRowKey(ThisObject);
EndProcedure

#EndRegion

#Region Currencies

&AtClient
Procedure CurrenciesSelection(Item, RowSelected, Field, StandardProcessing, AddInfo = Undefined)
	CommonFunctionsClientServer.PutToAddInfo(AddInfo, "ExecuteAtClient", True);
	CurrenciesClient.CurrenciesTable_Selection(Object, ThisObject, Item, RowSelected, Field, StandardProcessing, AddInfo);
EndProcedure

&AtClient
Procedure CurrenciesRatePresentationOnChange(Item, AddInfo = Undefined)
	CommonFunctionsClientServer.PutToAddInfo(AddInfo, "ExecuteAtClient", True);
	CurrenciesClient.CurrenciesTable_RatePresentationOnChange(Object, ThisObject, Item, AddInfo);
EndProcedure

&AtClient
Procedure CurrenciesMultiplicityOnChange(Item, AddInfo = Undefined)
	CommonFunctionsClientServer.PutToAddInfo(AddInfo, "ExecuteAtClient", True);
	CurrenciesClient.CurrenciesTable_MultiplicityOnChange(Object, ThisObject, Item, AddInfo);
EndProcedure

&AtClient
Procedure CurrenciesAmountOnChange(Item, AddInfo = Undefined)
	CommonFunctionsClientServer.PutToAddInfo(AddInfo, "ExecuteAtClient", True);
	CurrenciesClient.CurrenciesTable_AmountOnChange(Object, ThisObject, Item, AddInfo);
EndProcedure

&AtClient
Procedure CurrenciesBeforeAddRow(Item, Cancel, Clone, Parent, IsFolder, Parameter)
	Cancel = True;
EndProcedure

&AtClient
Procedure CurrenciesBeforeDeleteRow(Item, Cancel)
	Cancel = True;
EndProcedure

#EndRegion

#Region AddAttributes

&AtClient
Procedure AddAttributeStartChoice(Item, ChoiceData, StandardProcessing) Export
	AddAttributesAndPropertiesClient.AddAttributeStartChoice(ThisObject, Item, StandardProcessing);
EndProcedure

&AtServer
Procedure AddAttributesCreateFormControl()
	AddAttributesAndPropertiesServer.CreateFormControls(ThisObject, "GroupOther");
EndProcedure

#EndRegion

#Region ExternalCommands

&AtClient
Procedure GeneratedFormCommandActionByName(Command) Export
	ExternalCommandsClient.GeneratedFormCommandActionByName(Object, ThisObject, Command.Name);
	GeneratedFormCommandActionByNameServer(Command.Name);	
EndProcedure

&AtServer
Procedure GeneratedFormCommandActionByNameServer(CommandName) Export
	ExternalCommandsServer.GeneratedFormCommandActionByName(Object, ThisObject, CommandName);
EndProcedure

#EndRegion

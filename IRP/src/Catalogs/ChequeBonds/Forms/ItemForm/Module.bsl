&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	AddAttributesAndPropertiesServer.OnCreateAtServer(ThisObject, "GroupAdditionalAttributes");
EndProcedure

&AtClient
Procedure AddAttributeStartChoice(Item, ChoiceData, StandardProcessing) Export
	AddAttributesAndPropertiesClient.AddAttributeStartChoice(ThisObject, Item, StandardProcessing);
EndProcedure

&AtServer
Procedure BeforeWriteAtServer(Cancel, CurrentObject, WriteParameters)
	AddAttributesAndPropertiesServer.BeforeWriteAtServer(ThisObject, Cancel, CurrentObject, WriteParameters);
EndProcedure

&AtClient
Procedure NotificationProcessing(EventName, Parameter, Source)
	If EventName = "UpdateAddAttributeAndPropertySets" Then
		AddAttributesCreateFormControll();
	EndIf;
EndProcedure

&AtServer
Procedure AddAttributesCreateFormControll()
	AddAttributesAndPropertiesServer.CreateFormControls(ThisObject);
EndProcedure

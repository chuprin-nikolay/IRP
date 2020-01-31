Procedure OnWrite(Cancel)
	If Not (ThisObject.AdditionalProperties.Property("SynhronizeAffectPricingMD5")
		And Not ThisObject.AdditionalProperties.SynhronizeAffectPricingMD5) Then
		Catalogs.ItemKeys.SynhronizeAffectPricingMD5BySpecification(ThisObject.Ref);
	EndIf;
EndProcedure

Procedure BeforeWrite(Cancel)
	Query = New Query();
	Query.Text = 
	"SELECT
	|	SpecificationsDataSet.Key AS Key,
	|	SpecificationsDataSet.Item AS Item,
	|	SpecificationsDataSet.Attribute AS Attribute,
	|	SpecificationsDataSet.Value AS Value
	|INTO tmp_DataSet
	|FROM
	|	&DataSet AS SpecificationsDataSet
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	SpecificationsDataQuantity.Key AS Key,
	|	SpecificationsDataQuantity.Quantity AS Quantity
	|INTO tmp_DataQuantity
	|FROM
	|	&DataQuantity AS SpecificationsDataQuantity
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	tmp_DataSet.Item AS Item,
	|	tmp_DataSet.Attribute AS Property,
	|	tmp_DataSet.Value AS Value,
	|	tmp_DataQuantity.Quantity AS Quantity
	|FROM
	|	tmp_DataSet AS tmp_DataSet
	|		INNER JOIN tmp_DataQuantity AS tmp_DataQuantity
	|		ON tmp_DataSet.Key = tmp_DataQuantity.Key";
	Query.SetParameter("DataSet", ThisObject.DataSet.Unload());
	Query.SetParameter("DataQuantity", ThisObject.DataQuantity.Unload());
	QueryResult = Query.Execute();
	ThisObject.UniqueMD5 = AddAttributesAndPropertiesServer.GetMD5BySpecification(QueryResult.Unload());
	If ValueIsFilled(UniqueID.FindRefByUniqueMD5(ThisObject, ThisObject.UniqueMD5)) Then
		Cancel = True;
		CommonFunctionsClientServer.ShowUsersMessage(R().Error_066);
	EndIf;
EndProcedure


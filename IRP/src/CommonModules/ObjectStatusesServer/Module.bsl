Procedure WriteStatusToRegister(DocumentRef, Status, Date,
		AddInfo = Undefined) Export
	LastStatusInfo = GetLastStatusInfo(DocumentRef);
	If LastStatusInfo.Status = Status Then
		Return;
	EndIf;
	RecordSet = InformationRegisters[GetObjectStatusesInformationRegisterName(DocumentRef)].CreateRecordSet();
	RecordSet.Filter.Object.Set(DocumentRef);
	RecordSet.Filter.Period.Set(Date);
	
	Record = RecordSet.Add();
	Record.Object = DocumentRef;
	Record.Period = Date;
	Record.Status = Status;
	Record.Author = SessionParameters.CurrentUserPartner;
	
	RecordSet.Write(True);
EndProcedure

Function GetAllStatusInfo(DocumentRef, AddInfo = Undefined) Export
	Query = New Query();
	Query.Text = "SELECT
		|	ObjectStatuses.Period AS Period,
		|	ObjectStatuses.Object,
		|	ObjectStatuses.Status,
		|	ObjectStatuses.Status.Posting AS Posting,
		|	ObjectStatuses.Author,
		|	ObjectStatuses.Status AS Status
		|FROM
		|	InformationRegister.ObjectStatuses AS ObjectStatuses
		|WHERE
		|	ObjectStatuses.Object = &Object
		|ORDER BY
		|	Period";
	Query.SetParameter("Object", DocumentRef);
	QueryResult = Query.Execute();
	ArrayOfStatusInfo = New Array();
	If QueryResult.IsEmpty() Then
		ArrayOfStatusInfo.Add(PutStatusInfoToStructure());
		Return ArrayOfStatusInfo;
	EndIf;
	QuerySelection = QueryResult.Select();
	While QuerySelection.Next() Do
		ArrayOfStatusInfo.Add(PutStatusInfoToStructure(QuerySelection));
	EndDo;
	Return ArrayOfStatusInfo;
EndFunction

Function GetAllStatusInfoByCheque(ChequeRef, AddInfo = Undefined) Export
	Query = New Query();
	Query.Text = "SELECT
		|	ChequeBondStatuses.Period AS Period,
		|	ChequeBondStatuses.Status AS Status
		|FROM
		|	InformationRegister.ChequeBondStatuses AS ChequeBondStatuses
		|WHERE
		|	ChequeBondStatuses.Cheque = &Cheque
		|ORDER BY
		|	Period";
	Query.SetParameter("Cheque", ChequeRef);
	QueryResult = Query.Execute();
	ArrayOfStatusInfo = New Array();
	If QueryResult.IsEmpty() Then
		ArrayOfStatusInfo.Add(PutStatusInfoToStructure());
		Return ArrayOfStatusInfo;
	EndIf;
	QuerySelection = QueryResult.Select();
	While QuerySelection.Next() Do
		ArrayOfStatusInfo.Add(PutStatusInfoToStructure(QuerySelection));
	EndDo;
	Return ArrayOfStatusInfo;
	
EndFunction

Function GetLastStatusInfo(DocumentRef, AddInfo = Undefined) Export
	Query = New Query();
	Query.Text = "SELECT
		|	ObjectStatusesSliceLast.Period,
		|	ObjectStatusesSliceLast.Object,
		|	ObjectStatusesSliceLast.Status,
		|	ObjectStatusesSliceLast.Status.Posting AS Posting,
		|	ObjectStatusesSliceLast.Author,
		|	ObjectStatusesSliceLast.Status AS Status
		|FROM
		|	InformationRegister.ObjectStatuses.SliceLast(, Object = &Object) AS ObjectStatusesSliceLast";
	Query.SetParameter("Object", DocumentRef);
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	If QuerySelection.Next() Then
		Return PutStatusInfoToStructure(QuerySelection);
	Else
		Return PutStatusInfoToStructure();
	EndIf;
EndFunction

Function GetAvailableStatusesByCheque(ChequeBondTransactionRef, ChequeRef) Export
	PointInTime = New Boundary(ServiceSystemServer.GetObjectAttribute(ChequeBondTransactionRef, "Date"), BoundaryType.Excluding);
	ArrayOfStatuses = New Array();
	StatusInfo = ObjectStatusesServer.GetLastStatusInfoByCheque(PointInTime, ChequeRef);
	If Not ValueIsFilled(StatusInfo.Status) Then
		ArrayOfStatuses.Add(ObjectStatusesServer.GetStatusByDefaultForCheque(ChequeRef));
	Else
		For Each Status In ObjectStatusesServer.GetNextPossibleStatuses(StatusInfo.Status) Do
			If ArrayOfStatuses.Find(Status) = Undefined Then
				ArrayOfStatuses.Add(Status);
			EndIf;
		EndDo;
		Return ArrayOfStatuses;
	EndIf;
	Return ArrayOfStatuses;
EndFunction

Function GetLastStatusInfoByCheque(PointInTime, ChequeRef, AddInfo = Undefined) Export
	Query = New Query();
	If PointInTime <> Undefined Then
		Query.Text = "SELECT
			|	ChequeBondStatusesSliceLast.Period,
			|	ChequeBondStatusesSliceLast.Cheque AS Object,
			|	ChequeBondStatusesSliceLast.Status,
			|	ChequeBondStatusesSliceLast.Author
			|FROM
			|	InformationRegister.ChequeBondStatuses.SliceLast(&PointInTime, Cheque = &Cheque) AS ChequeBondStatusesSliceLast";
		
	Else
		Query.Text = "SELECT
			|	ChequeBondStatusesSliceLast.Period,
			|	ChequeBondStatusesSliceLast.Cheque AS Object,
			|	ChequeBondStatusesSliceLast.Status,
			|	ChequeBondStatusesSliceLast.Author
			|FROM
			|	InformationRegister.ChequeBondStatuses.SliceLast(, Cheque = &Cheque) AS ChequeBondStatusesSliceLast";
	EndIf;
	Query.SetParameter("Cheque", ChequeRef);
	Query.SetParameter("PointInTime", PointInTime);
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	If QuerySelection.Next() Then
		Return PutStatusInfoToStructure(QuerySelection);
	Else
		Return PutStatusInfoToStructure();
	EndIf;
EndFunction

Function PutStatusInfoToStructure(StatusInfo = Undefined)
	Result = New Structure();
	Result.Insert("Period", Date('0001-01-01'));
	Result.Insert("Object", Undefined);
	Result.Insert("Status", Catalogs.ObjectStatuses.EmptyRef());
	Result.Insert("Author", Catalogs.Partners.EmptyRef());
	Result.Insert("Posting", False);
	If StatusInfo = Undefined Then
		Result.Insert("Posting", CreatePostingStructure());
	Else
		Result.Insert("Posting", PutStatusPostingToStructure(StatusInfo.Status));
	EndIf;
	
	If StatusInfo <> Undefined Then
		FillPropertyValues(Result, StatusInfo);
	EndIf;
	Return Result;
EndFunction

Function PutStatusPostingToStructure(Status) Export
	Query = New Query();
	Query.Text = "SELECT
		|	ObjectStatuses.PostingAdvanced AS Advanced,
		|	ObjectStatuses.PostingPartnerAccountTransactions AS PartnerAccountTransactions,
		|	ObjectStatuses.PostingReconciliationStatement AS ReconciliationStatement,
		|	ObjectStatuses.PostingAccountBalance AS AccountBalance,
		|	ObjectStatuses.PostingPlaningCashTransactions AS PlaningCashTransactions,
		|	ObjectStatuses.PostingChequeBondBalance AS ChequeBondBalance
		|FROM
		|	Catalog.ObjectStatuses AS ObjectStatuses
		|WHERE
		|	ObjectStatuses.Ref = &Ref";
	Query.SetParameter("Ref", Status);
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	
	Posting = CreatePostingStructure();
	
	If QuerySelection.Next() Then
		FillPropertyValues(Posting, QuerySelection);
	EndIf;
	Return Posting;
EndFunction


Function StatusHasPostingType(Status, PostingType) Export
	
	Query = New Query();
	Query.Text = "SELECT
	|	ObjectStatuses.PostingAdvanced AS Advanced,
	|	ObjectStatuses.PostingPartnerAccountTransactions AS PartnerAccountTransactions,
	|	ObjectStatuses.PostingReconciliationStatement AS ReconciliationStatement,
	|	ObjectStatuses.PostingAccountBalance AS AccountBalance,
	|	ObjectStatuses.PostingPlaningCashTransactions AS PlaningCashTransactions,
	|	ObjectStatuses.PostingChequeBondBalance AS ChequeBondBalance
	|FROM
	|	Catalog.ObjectStatuses AS ObjectStatuses
	|WHERE
	|	ObjectStatuses.Ref = &Ref
	|	AND ( ObjectStatuses.PostingAdvanced = &PostingType
	|	OR ObjectStatuses.PostingPartnerAccountTransactions = &PostingType
	|	OR ObjectStatuses.PostingReconciliationStatement = &PostingType
	|	OR ObjectStatuses.PostingAccountBalance = &PostingType
	|	OR ObjectStatuses.PostingPlaningCashTransactions = &PostingType
	|	Or ObjectStatuses.PostingChequeBondBalance = &PostingType)";
	Query.SetParameter("Ref", Status);
	Query.SetParameter("PostingType", PostingType);
	
	QueryResult = Query.Execute();
	
	Return Not QueryResult.IsEmpty();
	
EndFunction
							
								
Function CreatePostingStructure()
	Result = New Structure();
	Result.Insert("Advanced", Enums.DocumentPostingTypes.Nothing);
	Result.Insert("PartnerAccountTransactions", Enums.DocumentPostingTypes.Nothing);
	Result.Insert("ReconciliationStatement", Enums.DocumentPostingTypes.Nothing);
	Result.Insert("AccountBalance", Enums.DocumentPostingTypes.Nothing);
	Result.Insert("PlaningCashTransactions", Enums.DocumentPostingTypes.Nothing);
	Result.Insert("ChequeBondBalance", Enums.DocumentPostingTypes.Nothing);
	Return Result;
EndFunction

Function GetObjectStatusesInformationRegisterName(DocumentRef,
		AddInfo = Undefined) Export
	Return "ObjectStatuses";
EndFunction

Function GetStatusByDefault(DocumentRef, Val PredefinedDataName = "",
		AddInfo = Undefined) Export
	If Not ValueIsFilled(PredefinedDataName) Then
		PredefinedDataName = DocumentRef.Metadata().Name;
	EndIf;
	
	Query = New Query();
	Query.Text = "SELECT
		|	ObjectStatuses.Ref,
		|	ObjectStatuses.PredefinedDataName
		|FROM
		|	Catalog.ObjectStatuses AS ObjectStatuses
		|WHERE
		|	ObjectStatuses.Predefined";
	QueryResult = Query.Execute();
	QueryTable = QueryResult.Unload().Copy(New Structure("PredefinedDataName", PredefinedDataName));
	If Not QueryTable.Count() Then
		Return Catalogs.ObjectStatuses.EmptyRef();
	EndIf;
	
	Query = New Query();
	Query.Text = "SELECT TOP 1
		|	ObjectStatuses.Ref
		|FROM
		|	Catalog.ObjectStatuses AS ObjectStatuses
		|WHERE
		|	NOT ObjectStatuses.IsFolder
		|	AND ObjectStatuses.Parent = &Parent
		|	AND ObjectStatuses.SetByDefault";
	Query.SetParameter("Parent", Catalogs.ObjectStatuses[PredefinedDataName]);
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	If QuerySelection.Next() Then
		Return QuerySelection.Ref;
	Else
		Return Catalogs.ObjectStatuses.EmptyRef();
	EndIf;
EndFunction

Function GetStatusByDefaultForCheque(ChequeRef) Export
	If ChequeRef.Type = Enums.ChequeBondTypes.PartnerCheque Then
		Return ObjectStatusesServer.GetStatusByDefault(ChequeRef, "ChequeBondIncoming");
	ElsIf ChequeRef.Type = Enums.ChequeBondTypes.OwnCheque Then
		Return ObjectStatusesServer.GetStatusByDefault(ChequeRef, "ChequeBondOutgoing");
	Else
		Return Undefined;
	EndIf;
EndFunction

Function GetNextPossibleStatuses(Status) Export
	Query = New Query();
	Query.Text = "SELECT
		|	ObjectStatusesNextPossibleStatuses.Status AS Status
		|FROM
		|	Catalog.ObjectStatuses.NextPossibleStatuses AS ObjectStatusesNextPossibleStatuses
		|WHERE
		|	ObjectStatusesNextPossibleStatuses.Ref = &Ref
		|GROUP BY
		|	ObjectStatusesNextPossibleStatuses.Status";
	Query.SetParameter("Ref", Status);
	QueryResult = Query.Execute();
	Return QueryResult.Unload().UnloadColumn("Status");
EndFunction

Function GetObjectStatusesChoiseDataTable(SearchString, ArrayOfFilters,
		AdditionalParameters) Export
	Parameters = New Structure("Filter, SearchString", New Structure(), SearchString);
	Parameters.Filter.Insert("CustomSearchFilter", DocumentsServer.SerializeArrayOfFilters(ArrayOfFilters));
	Parameters.Filter.Insert("AdditionalParameters", DocumentsServer.SerializeArrayOfFilters(AdditionalParameters));
	
	TableOfResult = Catalogs.ObjectStatuses.GetChoiseDataTable(Parameters);
	Return TableOfResult.UnloadColumn("Ref");
EndFunction

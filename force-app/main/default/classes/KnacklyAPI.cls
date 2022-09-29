public without sharing class KnacklyAPI {
  static String base_url;
  static String catalog_name;
  static String key_id;  
  static String secret;
  static String workspace;
  private static String authToken;
  static String mainBody;

@AuraEnabled
    public static String submitKnacklyOrder(id opportunityId) {
        
	List<Knackly_API_Data__mdt> listKnacklyConnectionDetail = [SELECT base_url__c,catalog_name__c,key_id__c,secret__c,workspace__c 
                                                   from Knackly_API_Data__mdt where DeveloperName ='Knackly_Connection_Detail'];     
     if (listKnacklyConnectionDetail.size() > 0)
     {
	 	  base_url		= listKnacklyConnectionDetail[0].base_url__c;    
		  catalog_name 	= listKnacklyConnectionDetail[0].catalog_name__c;     
	 	  key_id		= listKnacklyConnectionDetail[0].key_id__c;    
	 	  secret		= listKnacklyConnectionDetail[0].secret__c;    
	 	  workspace		= listKnacklyConnectionDetail[0].workspace__c;             
     }
 	
    authToken = getAuthToken();
        
	List <Opportunity> knacklyData = [SELECT id,CloseDate,Rate__c,LOC_Term__c,Stated_Maturity_Date__c,Extension_Fee__c,Extension_Period_Days__c,
                                    Product_Sub_Type__c,Interest_Rate_Type__c,First_Payment_Date__c,Owner_Name__c,
                                    Closer__r.name, Borrower_Entity__r.Name,Borrower_Entity__r.Entity_Type__c,
									Borrower_Entity__r.Business_Tax_ID_EIN__c,Borrower_Entity__r.Address_1__c,Borrower_Entity__r.Address_2__c,
									Borrower_Entity__r.State__c,Borrower_Entity__r.Zip__c,Borrower_Entity__r.Company_Jurisdiction__c,
                                    Borrower_Entity__r.City__c,Borrower_Entity__r.Operating_Agreement_Date__c,
                                    (SELECT Title_Company__r.Name,Title_Company__r.Primary_Contact__r.Name
                                     ,Title_Company__r.Primary_Contact__r.Email,Title_Company__r.Primary_Contact__r.Phone
                                     ,Title_Company__r.BillingStreet,Title_Company__r.BillingCity
                                     ,Title_Company__r.BillingState,Title_Company__r.BillingPostalCode
                                     ,Escrow_Agent__r.Name,Escrow_Agent__r.Primary_Contact__r.Name
                                     ,Escrow_Agent__r.Primary_Contact__r.Email,Escrow_Agent__r.Primary_Contact__r.Phone
                                     ,Escrow_Agent__r.BillingStreet,Escrow_Agent__r.BillingCity,Escrow_Agent__r.BillingState
                                     ,Escrow_Agent__r.BillingPostalCode,Appraised_Value_Amount__c,Origination_Fee_Amnt__c
                                     ,Approved_Renovation_Holdback__c,Initial_Disbursement__c,Legal_Description__c
                                     ,Approved_Advance_Amount__c,Name,Address_2__c,City__c,State_Full__c,County__c,ZipCode__c,APN__c
                                     ,Initial_Advance__r.Escrow_Title_Number__c,Doc_Prep_Fee__c
                                     FROM properties__r)
                                    ,(SELECT Id,Company_Name__c,Company_Type__c,Company_Jurisdiction__c,State__c,Contact__r.FirstName,
                                      Contact__r.LastName,Contact__r.Middlename ,Contact__r.Sex__c,Contact__r.Birthdate,
                                      Contact__r.Marital_Status_Formula__c,Contact__r.MailingStreet,Contact__r.MailingCity,
                                      Contact__r.MailingState,Contact__r.MailingPostalCode,Contact__r.Phone, Contact__r.Email
                                      FROM Deal_Contacts__r where Entity_Type__c IN ('Guarantor')) 
                                    FROM Opportunity where id = :opportunityId];
		System.debug('RS999 knacklyData :' +knacklyData);        
        System.debug('RS999 knacklyData serializePretty :' +JSON.serializePretty(knacklyData, false)); 
        
        List <Property__c> listDealProperty = knacklyData[0].properties__r;
        System.debug('RS999 listDealProperty :' +listDealProperty);     
        
        List <Deal_Contact__c> listDealContactGuarantor = knacklyData[0].Deal_Contacts__r;
        System.debug('RS999 listDealContactGuarantor :' +listDealContactGuarantor);
        
        String body = '{';
        body +='"File":"' + String.valueof(knacklyData[0].id) + '",';
        body += '"LoanProperty": [';
        for (Property__c prop :listDealProperty )
        {
        	System.debug('RS999 prop :' +prop);            
            body += '{';
            body += '"Address": "' + (prop.Name == null ? '' : prop.Name) + '",';            
            body += '"Address2": "' + (prop.Address_2__c == null ? '' : prop.Address_2__c) + '",';                        
            body += '"City": "' + (prop.City__c == null ? '' : prop.City__c)  + '",';            
            body += '"State": "' + (prop.State_Full__c == null ? '' : prop.State_Full__c) + '",';             
            body += '"Zip": "' + (prop.ZipCode__c == null ? '' : prop.ZipCode__c) + '",';  
            body += '"LegalDescription": "'    + (prop.Legal_Description__c == null ? '' : prop.Legal_Description__c) + '",';          
            body += '"County": "' + (prop.County__c == null ? '' : prop.County__c) + '",';
            body += '"LoanToAsIsValue":' + (prop.Appraised_Value_Amount__c == null ? 0 : prop.Appraised_Value_Amount__c) + ',';      
            body += '"LoanAmount":' + (prop.Approved_Advance_Amount__c  == null ? 0 : prop.Approved_Advance_Amount__c ) + ',';      
            body += '"InitialAdvance":' + (prop.Initial_Disbursement__c == null ? 0 : prop.Initial_Disbursement__c) + ',';   
            body += '"MaxAggregateRenoAmount":' + (prop.Approved_Renovation_Holdback__c == null ? 0 : prop.Approved_Renovation_Holdback__c) + ',';   
            body += '"OriginationFeeAmount":' + (prop.Origination_Fee_Amnt__c == null ? 0 :  prop.Origination_Fee_Amnt__c) + ',';            
            body += '"ApprovedRenoAdvAmount":' + (prop.Approved_Renovation_Holdback__c == null ? 0 : prop.Approved_Renovation_Holdback__c) + ',';  
            body += '"APN": "' + (prop.APN__c == null ? '' : prop.APN__c) + '",';   
            body += '"ProcessingFee":' + (prop.Doc_Prep_Fee__c == null ? 0 :  prop.Doc_Prep_Fee__c) + ',';
           // body += '"Lot": "' + (prop.APN__c == null ? '' : prop.APN__c) + '",';
           // body += '"Block": "' + (prop.APN__c == null ? '' : prop.APN__c) + '",';
          //  body += '"MapNumber": "' + (prop.APN__c == null ? '' : prop.APN__c) + '",';
        	body +='"EscrowCompany": {';
			body += '"CompanyName":"' 	+ (prop.Escrow_Agent__r.Name == null ? '' : prop.Escrow_Agent__r.Name) + '",';  
            body += '"ContactName": "' 	+ (prop.Escrow_Agent__r.Primary_Contact__r.Name == null ? '' : prop.Escrow_Agent__r.Primary_Contact__r.Name) + '",';     
            body += '"ContactEmail": "' + (prop.Escrow_Agent__r.Primary_Contact__r.Email == null ? '' : prop.Escrow_Agent__r.Primary_Contact__r.Email) + '",';            
            body += '"ContactPhone": "' + (prop.Escrow_Agent__r.Primary_Contact__r.Phone == null ? '' : prop.Escrow_Agent__r.Primary_Contact__r.Phone) + '",';             
            body += '"Address": "' 		+ (prop.Escrow_Agent__r.BillingStreet == null ? '' : prop.Escrow_Agent__r.BillingStreet) + '",';             
            body += '"City": "' 		+ (prop.Escrow_Agent__r.BillingCity == null ? '' : prop.Escrow_Agent__r.BillingCity) + '",';             
            body += '"State": "' 		+ (prop.Escrow_Agent__r.BillingState == null ? '' : prop.Escrow_Agent__r.BillingState) + '",';             
            body += '"Zip": "' 			+ (prop.Escrow_Agent__r.BillingPostalCode == null ? '' : prop.Escrow_Agent__r.BillingPostalCode) + '",';   
            body += '"EscrowOrTitleNo" : "' + (prop.Initial_Advance__r.Escrow_Title_Number__c == null ? '' : prop.Initial_Advance__r.Escrow_Title_Number__c) + '"';  
            body += '},';            
        	body +='"TitleCompany": {';
			body += '"CompanyName":"' + (prop.Title_Company__r.Name == null ? '' : prop.Title_Company__r.Name) + '",';  
            body += '"ContactName": "' + (prop.Title_Company__r.Primary_Contact__r.Name == null ? '' : prop.Title_Company__r.Primary_Contact__r.Name) + '",';
            body += '"ContactEmail": "' + (prop.Title_Company__r.Primary_Contact__r.Email == null ? '' : prop.Title_Company__r.Primary_Contact__r.Email) + '",';            
            body += '"ContactPhone": "' + (prop.Title_Company__r.Primary_Contact__r.Phone == null ? '' : prop.Title_Company__r.Primary_Contact__r.Phone) + '",';             
            body += '"Address": "' + (prop.Title_Company__r.BillingStreet == null ? '' : prop.Title_Company__r.BillingStreet) + '",';             
            body += '"City": "' + (prop.Title_Company__r.BillingCity == null ? '' : prop.Title_Company__r.BillingCity) + '",';             
            body += '"State": "' + (prop.Title_Company__r.BillingState == null ? '' : prop.Title_Company__r.BillingState) + '",';             
            body += '"Zip": "' + (prop.Title_Company__r.BillingPostalCode == null ? '' : prop.Title_Company__r.BillingPostalCode) + '",'; 
            body += '"EscrowOrTitleNo" : "' + (prop.Initial_Advance__r.Escrow_Title_Number__c == null ? '' : prop.Initial_Advance__r.Escrow_Title_Number__c) + '"'; 
            body += '}';  
        	body += '},';              
        }   
      	body = body.removeEnd(',');  
        body += '],';
        body += '"Guarantors": [';     
        System.debug('RS999 listDealContactGuarantor.size() :' +listDealContactGuarantor.size());
		for (Deal_Contact__c  guarantor : listDealContactGuarantor)
    	{
        System.debug('RS999 guarantor :' +guarantor);
        body += '{';
        body += '"EntityName": "' 		+ (guarantor.Company_Type__c == null ? '' : guarantor.Company_Type__c) + '",';             
        body += '"EntityType": "' 		+ (guarantor.Company_Name__c == null ? '' : guarantor.Company_Name__c) + '",'; 
        body += '"FirstName": "' 		+ (guarantor.Contact__r.FirstName == null ? '' : guarantor.Contact__r.FirstName) + '",';             
        body += '"MiddleName": "' 		+ (guarantor.Contact__r.Middlename == null ? '' : guarantor.Contact__r.Middlename) + '",';             
        body += '"LastName": "' 		+ (guarantor.Contact__r.LastName == null ? '' : guarantor.Contact__r.LastName) + '",';            
        body += '"Gender": "' 			+ (guarantor.Contact__r.Sex__c == null ? '' : guarantor.Contact__r.Sex__c) + '",';             
        body += '"BirthDate": "' 		+ (guarantor.Contact__r.Birthdate == null ? '' : string.valueof(guarantor.Contact__r.Birthdate)) + '",';              
        body += '"MaritalStatus": "' 	+ (guarantor.Contact__r.Marital_Status_Formula__c == null ? '' : guarantor.Contact__r.Marital_Status_Formula__c) + '",';            
        body += '"SameAddress": "' 		+ '",';             
        body += '"State": "' 			+ (guarantor.Contact__r.MailingState == null ? '' : guarantor.Contact__r.MailingState) + '",';              
       // body += '"SpouseName": "' 	+ (guarantor.State__c == null ? '' : guarantor.State__c) + '",';            
        //body += '"SpouseDifferentResidenceTF": "' 	+ (guarantor.State__c == null ? '' : guarantor.State__c) + '",';
        //body += '"SpouseResidenceState": "' 			+ (guarantor.State__c == null ? '' : guarantor.State__c) + '",';
        //body += '"SpouseConsentTF": "' 				+ (guarantor.State__c == null ? '' : guarantor.State__c) + '",';
        body += '"Address1": "' 		+ (guarantor.Contact__r.MailingStreet == null ? '' : guarantor.Contact__r.MailingStreet.replaceAll('\r\n|\n|\r',' ')) + '",';        
        //body += '"Address2": "' 		+ (guarantor.State__c == null ? '' : guarantor.State__c) + '",'; 
        body += '"City": "' 			+ (guarantor.Contact__r.MailingCity == null ? '' : guarantor.Contact__r.MailingCity) + '",'; 
        body += '"Zip": "' 				+ (guarantor.Contact__r.MailingPostalCode == null ? '' : guarantor.Contact__r.MailingPostalCode) + '",'; 
        body += '"County": "' 			+ (guarantor.Contact__r.MailingCity == null ? '' : guarantor.Contact__r.MailingCity) + '",'; 
        body += '"Phone": "' 			+ (guarantor.Contact__r.Phone == null ? '' : guarantor.Contact__r.Phone) + '",'; 
        body += '"Email": "' 			+ (guarantor.Contact__r.Email == null ? '' : guarantor.Contact__r.Email) + '"';
        body += '},';        
    	}
      	body = body.removeEnd(',');         
        body += '],';
        body +='"LoanInfo": {';
        body += '"InterestRate":' + (knacklyData[0].Rate__c == null ? 0 : knacklyData[0].Rate__c) + ','; 
		body += '"MaturityDate": "' + (knacklyData[0].Stated_Maturity_Date__c == null ? '' : String.valueof(knacklyData[0].Stated_Maturity_Date__c)) + '",';
        body += '"Renovation": "' + (knacklyData[0].Product_Sub_Type__c == null ? '' : knacklyData[0].Product_Sub_Type__c) + '",';         
        body += '"IsExtensionOptionTF": ' + ((knacklyData[0].Extension_Period_Days__c == null || knacklyData[0].Extension_Period_Days__c == 0) ? '"False"' : '"True"') + ',';
        body += '"ExtendMonths":' + (knacklyData[0].Extension_Period_Days__c == null ? 0 : knacklyData[0].Extension_Period_Days__c) + ',';        
        body += '"ExtendFee": "' + (knacklyData[0].Extension_Fee__c == null ? '0' : knacklyData[0].Extension_Fee__c) + '",';   
        body += '"LoanDate": "' + (knacklyData[0].CloseDate == null ? '' : String.valueof(knacklyData[0].CloseDate)) + '",'; 
		body += '"TermOfLoan":"' + (knacklyData[0].LOC_Term__c == null ? '' : String.valueof(knacklyData[0].LOC_Term__c)) + '",';         
        body += '"LoanType":"' + (knacklyData[0].Interest_Rate_Type__c == null ? '' : knacklyData[0].Interest_Rate_Type__c) + '",';         
        body += '"FirstMonthlyPaymentDT": "' + knacklyData[0].First_Payment_Date__c + '",';   
        body += '"ClosingDate" :"' + (knacklyData[0].CloseDate == null ? '' : String.valueof(knacklyData[0].CloseDate)) + '",';
        body += '"OutsideCompletionDT": "' + (knacklyData[0].Stated_Maturity_Date__c == null ? '' : String.valueof(knacklyData[0].Stated_Maturity_Date__c)) + '",';
        body += '"CloserOnFile":"' + (String.valueof(knacklyData[0].Closer__r.name) == null ? '' : String.valueof(knacklyData[0].Closer__r.name)) + '",';
        body += '"LoanOriginator": "' + (knacklyData[0].Owner_Name__c == null ? '' : knacklyData[0].Owner_Name__c) + '"';        
        body += '},';        
        body += '"SingleBorrower": {' ;
		body += '"EntityType": "' + (String.valueof(knacklyData[0].Borrower_Entity__r.Entity_Type__c) == null ? '' : String.valueof(knacklyData[0].Borrower_Entity__r.Entity_Type__c)) + '",';        
        body += '"EntityName": "' + (String.valueof(knacklyData[0].Borrower_Entity__r.Name) == null ? '' : String.valueof(knacklyData[0].Borrower_Entity__r.Name)) + '",';
		body += '"EIN": "' + (String.valueof(knacklyData[0].Borrower_Entity__r.Business_Tax_ID_EIN__c) == null ? '' : String.valueof(knacklyData[0].Borrower_Entity__r.Business_Tax_ID_EIN__c)) + '",';
		body += '"Address1": "' + (String.valueof(knacklyData[0].Borrower_Entity__r.Address_1__c.replaceAll('\r\n|\n|\r',' ')) == null ? '' : String.valueof(knacklyData[0].Borrower_Entity__r.Address_1__c.replaceAll('\r\n|\n|\r',' '))) + '",';        
		body += '"Address2": "' + (String.valueof(knacklyData[0].Borrower_Entity__r.Address_2__c) == null ? '' : String.valueof(knacklyData[0].Borrower_Entity__r.Address_2__c).replaceAll('\r\n|\n|\r',' ')) + '",';                
		body += '"City": "' + (String.valueof(knacklyData[0].Borrower_Entity__r.City__c) == null ? '' : String.valueof(knacklyData[0].Borrower_Entity__r.City__c)) + '",';                        
		body += '"State": "' + (String.valueof(knacklyData[0].Borrower_Entity__r.State__c) == null ? '' : String.valueof(knacklyData[0].Borrower_Entity__r.State__c)) + '",';        
		body += '"Zip": "' + (String.valueof(knacklyData[0].Borrower_Entity__r.Zip__c) == null ? '' : String.valueof(knacklyData[0].Borrower_Entity__r.Zip__c)) + '",';                
		body += '"CompanyJurisdiction": "' + (String.valueof(knacklyData[0].Borrower_Entity__r.Company_Jurisdiction__c) == null ? '' : String.valueof(knacklyData[0].Borrower_Entity__r.Company_Jurisdiction__c)) + '",';                        
		body += '"PrincipalPlaceofBusiness": "' + (String.valueof(knacklyData[0].Borrower_Entity__r.Company_Jurisdiction__c) == null ? '' : String.valueof(knacklyData[0].Borrower_Entity__r.Company_Jurisdiction__c)) + '",';                                
		body += '"EntityFormationDate": "' + (String.valueof(knacklyData[0].Borrower_Entity__r.Operating_Agreement_Date__c) == null ? '' : String.valueof(knacklyData[0].Borrower_Entity__r.Operating_Agreement_Date__c)) + '",';                                        
        body += '"SignerL1":[';
		for (Deal_Contact__c  guarantor : listDealContactGuarantor)
    	{
        System.debug('RS999 Signer :' +guarantor);
        body += '{';
        body += '"EntityName": "' 		+ (guarantor.Company_Type__c == null ? '' : guarantor.Company_Type__c) + '",';             
        body += '"EntityType": "' 		+ (guarantor.Company_Name__c == null ? '' : guarantor.Company_Name__c) + '",'; 
        body += '"FirstName": "' 		+ (guarantor.Contact__r.FirstName == null ? '' : guarantor.Contact__r.FirstName) + '",';             
        body += '"LastName": "' 		+ (guarantor.Contact__r.LastName == null ? '' : guarantor.Contact__r.LastName) + '",';            
        body += '"Gender": "' 			+ (guarantor.Contact__r.Sex__c == null ? '' : guarantor.Contact__r.Sex__c) + '",';             
        body += '"State": "' 	+ (guarantor.State__c == null ? '' : guarantor.State__c) + '"';              
        body += '},';        
    	}        
      	body = body.removeEnd(',');        
        body += ']';
        body += '}';        
        body += '}';        
		System.debug('RS999 body :' +body);  
        mainBody = body;
		String Retstatus = submitOrder();        
        return Retstatus;
    }
    
    
  public static String getAuthToken() {

    String authToken = '';
    String authURI = '/api/v1/auth/login';
    String authEndpoint = base_url + workspace + authURI;
    system.debug('RS999 authEndpoint :' +authEndpoint);        
    HttpRequest req = new HttpRequest();
    req.setEndpoint(authEndpoint);
    req.setMethod('POST');
    req.setTimeout(120000);
    req.setHeader('Content-Type','application/json');
    String authBody = '{"KeyID": "' + key_id + '",' + '"Secret": "' + secret + '"}';
    system.debug('RS999 authBody :' +authBody);      
    req.setBody(authBody);

    if (!Test.isRunningTest()) 
    {
      HttpResponse resp = new Http().send(req);
      system.debug('RS999 resp.getBody() :' +resp.getBody());        
      system.debug('RS999 resp.getStatusCode() :' +resp.getStatusCode());        
          if(resp.getStatusCode() == 200 )
          {
              String retBody = resp.getBody();
              system.debug('RS999 retBody :' +retBody);
              Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(retBody );
              authToken = (String) respMap.get('token');          
              system.debug(respMap);
          }
    }
    system.debug('RS999 authToken :' +authToken);
    return authToken;
  }

  public static String submitOrder() 
  {
    String mainEndpoint = base_url + workspace + '/api/v1/catalogs/' + catalog_name + '/items';
    system.debug('RS999 mainEndpoint 2 :' +mainEndpoint);        

    if (!String.isBlank(authToken)) 
    {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(mainEndpoint);
    req.setMethod('POST');
    req.setHeader('Content-Type','application/json');        
    req.setHeader('Authorization', authToken);
    system.debug('RS999 mainBody:' +mainBody);         
    req.setBody(mainBody);

        if (!Test.isRunningTest()) 
        {
          HttpResponse resp = new Http().send(req);
     system.debug('RS999 resp.getBody() - 2 :' +resp.getBody());        
     system.debug('RS999 resp.getStatusCode() - 2 :' +resp.getStatusCode());            
              if(resp.getStatusCode() == 200 )
              {
                  String retBody = resp.getBody();
                  system.debug('RS999 retBody :' +retBody);
                  Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(retBody );
                  system.debug(respMap);
                  return 'Success';
              }
            Else
            return 'Error';
        }      
	}    
    return 'Error';      
  }

  
}
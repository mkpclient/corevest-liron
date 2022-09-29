@isTest
private class PortalAPITests {
  public static string BASE_URL = system.url.getOrgDomainUrl().toExternalForm();
  @testSetup
  static void setup() {
    test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);

    Application__c app = new Application__c(
      Contact__c = cont.Id,
      Alchemy_User_Id__c = 'af-sdba',
      Loan_Type__c = 'bridge'
    );
    insert app;

    cont.Alchemy_Portal_Id__c = 'af-sdba';
    cont.Email = 'portalapitest@example.com';
    update cont;
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    opp.Apex_Context__c = true;
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    ]
    .Id;
    opp.StageName = 'Hold';
    opp.Draw_Period__c = '12 Months';
    opp.Repayment_Period__c = '9 Months';
    opp.LOC_Loan_Type__c = 'Credit Line';
    opp.Loan_Size__c = 3000000;
    opp.Line_Expiration__c = '18 Months';
    opp.Requested_LTC_Max__c = 70;
    opp.Requested_LTV_Max__c = 80;
    opp.Requested_Origination_Fee__c = 0;
    opp.Requested_Draw_Fee__c = 2;
    opp.Requested_Exit_Fee__c = 0;
    opp.Requested_Interest_Type__c = 'Fixed';
    opp.Requested_Rate_1_9_Months__c = 10;
    opp.Requested_Revolving__c = 'Yes';
    opp.Requested_Draw_Fee_Cap__c = 'None';
    opp.Product_Sub_Type__c = 'Renovation';
    opp.Interest_Rate_Type__c = 'Floating';
    opp.Index__c = '1M LIBOR';
    opp.Index_Floor__c = '1.00%';
    opp.Index_Margin__c = 1.50;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_source__c = 'Main';
    opp.Application__c = app.Id;
    opp.Contact__c = cont.Id;
    update opp;
  }

  static testMethod void applicationAPITest() {
    RestRequest request = new RestRequest();
    request.requestUri = BASE_URL + '/services/apexrest/portal/application/';
    request.httpMethod = 'POST';
    request.addHeader('Content-Type', 'application/json');

    Map<String, Object> body = new Map<String, Object>();
    body.put('loanType', 'term');
    body.put('user_id', 'af-sdba');
    body.put('status', 'Pending');
    request.requestBody = Blob.valueOf(JSON.serialize(body));
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIApplication.doPost();

    Map<String, Object> respBody = (Map<String, Object>) JSON.deserializeUntyped(
      RestContext.response.responseBody.toString()
    );
    String applicationId = (String) respBody.get('id');
    system.debug(applicationId);
    request = new RestRequest();
    request.requestUri = 'apexrest/portal/application/' + applicationId;
    system.debug(request.requestURI);
    request.addHeader('Content-Type', 'application/json');

    body = new Map<String, Object>();
    body.put('loanType', 'term');
    body.put('user_id', 'af-sdba');
    body.put('status', 'Pending');
    request.requestBody = Blob.valueOf(JSON.serialize(body));
    request.httpMethod = 'PATCH';
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIApplication.doPatch();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/application/' + applicationId;
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIApplication.doGet();
    request.requestURI = 'apexrest/portal/application/af-sdba';
    PortalAPIApplication.doGet();

    String testRequest =
      '[{"Name": "Test Street 2","Address__c": "Test Street 2","Acquisition_Date__c": "2020-04-05","Comments__c": "Test comments","City__c": "Bellflower","Application__c": "' +
      applicationId +
      '","State__c": "California","Country__c": "United States","Zipcode__c": "90706","Property_Type__c": "SFR","Number_of_Units__c": 5,"Bedrooms__c": 1,"Bathrooms__c": 1,"Square_Footage__c": 900,"Year_Built__c": "1958","Air_Conditioning__c": "Yes","Pool__c": "Yes","Section_8__c": "Yes","Acquisition_Price__c": 2500.00,"Transaction_Costs__c": 2500.00,"Rehab_Costs__c": 2500.00,"Rehab_Completion_Date__c": "1991-04-17","Total_Basis__c": 2500.00,"Borrower_Opinion_of_Current_Value__c": 2500.00,"Currently_Leased__c": "Yes","Lease_Ready__c": "Yes","Lease_Start_Date__c": "1991-04-17","Lease_End_Date__c": "1991-04-17","Lease_Term__c": "string","Monthly_Rent__c": 2500.00,"Security_Deposit__c": 2500.00,"HOA__c": 2500.00,"Special_Assessments__c": 2500.00,"Taxes__c": 2500.00,"Insurance__c": 2500.00,"Property_Management__c": 2500.00,"MaintenanceRepairs__c": 2500.00,"Owner_Paid_Utilities__c": 2500.00,"Landscaping_Expense__c": 2500.00,"Other_Expenses__c": 2500.00,"Lease_UpMarketing__c": 2500.00,"Vacancy_RepairsMaintenance__c": 2500.00,"Credit_Loss__c": 2500.00,"Total_Expenses__c": 2500.00,"CapEx_Reserves__c": 2500.00,"Other_Reserves__c": 2500.00,"NOI__c": 2500.00}]';
    request = new RestRequest();
    request.requestUri =
      BASE_URL + '/services/apexrest/portal/application/properties';
    request.httpMethod = 'POST';
    request.addHeader('Content-Type', 'application/json');

    request.requestBody = Blob.valueOf(testRequest);
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIApplicationProperty.doPost();

    Application_Property__c prop = [
      SELECT Id
      FROM Application_Property__c
      LIMIT 1
    ];

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/application/properties/' + prop.Id;
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIApplicationProperty.doGet();

    request = new RestRequest();
    request.requestUri =
      'apexrest/portal/application/properties/applicationId/' + applicationId;
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIApplicationProperty.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/application/properties/' + prop.Id;
    request.httpMethod = 'DELETE';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIApplicationProperty.doDelete();

    request = new RestRequest();
    request.requestUri =
      'apexrest/portal/application/properties/applicationId/' + applicationId;
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIApplicationProperty.doGet();

    testRequest = '[{"Name": "Test Street 2","Address__c": "Test Street 2","Acquisition_Date__c": "2020-04-05","Comments__c": "Test comments","City__c": "Bellflower","State__c": "California","Country__c": "United States","Zipcode__c": "90706","Property_Type__c": "SFR","Number_of_Units__c": 5,"Bedrooms__c": 1,"Bathrooms__c": 1,"Square_Footage__c": 900,"Year_Built__c": "1958","Air_Conditioning__c": "Yes","Pool__c": "Yes","Section_8__c": "Yes","Acquisition_Price__c": 2500.00,"Transaction_Costs__c": 2500.00,"Rehab_Costs__c": 2500.00,"Rehab_Completion_Date__c": "1991-04-17","Total_Basis__c": 2500.00,"Borrower_Opinion_of_Current_Value__c": 2500.00,"Currently_Leased__c": "Yes","Lease_Ready__c": "Yes","Lease_Start_Date__c": "1991-04-17","Lease_End_Date__c": "1991-04-17","Lease_Term__c": "string","Monthly_Rent__c": 2500.00,"Security_Deposit__c": 2500.00,"HOA__c": 2500.00,"Special_Assessments__c": 2500.00,"Taxes__c": 2500.00,"Insurance__c": 2500.00,"Property_Management__c": 2500.00,"MaintenanceRepairs__c": 2500.00,"Owner_Paid_Utilities__c": 2500.00,"Landscaping_Expense__c": 2500.00,"Other_Expenses__c": 2500.00,"Lease_UpMarketing__c": 2500.00,"Vacancy_RepairsMaintenance__c": 2500.00,"Credit_Loss__c": 2500.00,"Total_Expenses__c": 2500.00,"CapEx_Reserves__c": 2500.00,"Other_Reserves__c": 2500.00,"NOI__c": 2500.00}]';
    request = new RestRequest();
    request.requestUri =
      BASE_URL + '/services/apexrest/portal/application/properties';
    request.httpMethod = 'POST';
    request.addHeader('Content-Type', 'application/json');

    request.requestBody = Blob.valueOf(testRequest);
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIApplicationProperty.doPost();
  }

  static testMethod void dashboardTests() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    List<Property__c> property = new List<Property__c>();
    Id recordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        sobjecttype = 'Property__c'
        AND DeveloperName = 'Bridge_No_Renovation'
    ]
    .Id;
    for (Integer i = 0; i < 20; i++) {
      property.add(
        new Property__c(
          Name = 'Test + ' + i,
          Property_Name__c = 'Test + ' + i,
          Deal__c = opp.Id,
          Escrow_Company_text__c = 'ESCROW',
          Insurance_Company_text__c = 'INSURANCE',
          Status__c = 'Pending',
          recordTypeId = recordTypeId
        )
      );
    }

    property[0].Status__c = 'Due Diligence';
    property[1].Status__c = 'Active';
    property[2].Payoff_Received_Date__c = system.today();
    insert property;
    Test.startTest();
    RestRequest request = new RestRequest();
    request.requestUri = 'apexrest/portal/dashboard/af-sdba';
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDashboard.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/dashboard/loans/af-sdba/new';
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDashboard.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/dashboard/properties/af-sdba/new';
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDashboard.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/dashboard/properties/af-sdba';
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDashboard.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/dashboard/loans/af-sdba';
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDashboard.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/dashboard/af-sdba/new';
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDashboard.doGet();

    Test.stopTest();
  }

  static testMethod void dealTests() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    List<Property__c> property = new List<Property__c>();
    Id recordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        sobjecttype = 'Property__c'
        AND DeveloperName = 'Bridge_No_Renovation'
    ]
    .Id;
    for (Integer i = 0; i < 20; i++) {
      property.add(
        new Property__c(
          Name = 'Test + ' + i,
          Property_Name__c = 'Test + ' + i,
          Deal__c = opp.Id,
          Escrow_Company_text__c = 'ESCROW',
          Insurance_Company_text__c = 'INSURANCE',
          Status__c = 'Pending',
          recordTypeId = recordTypeId
        )
      );
    }

    property[0].Status__c = 'Due Diligence';
    property[1].Status__c = 'Active';
    property[2].Payoff_Received_Date__c = system.today();
    insert property;
    Test.startTest();
    RestRequest request = new RestRequest();
    request.requestUri = 'apexrest/portal/deal/' + opp.Id;
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDeal.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/property/dealId/' + opp.Id;
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIProperty.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/property/' + property[0].Id;
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIProperty.doGet();

    Test.stopTest();
  }

  static testMethod void commentTests() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    RestRequest request = new RestRequest();
    request.requestUri = BASE_URL + '/services/apexrest/portal/application/';
    request.httpMethod = 'POST';
    request.addHeader('Content-Type', 'application/json');

    Map<String, Object> body = new Map<String, Object>();
    body.put('subject', 'test');
    body.put('body', 'test');
    body.put('loanId', opp.Id);
    body.put('userId', 'af-sdba');
    request.requestBody = Blob.valueOf(JSON.serialize(body));
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIComments.doPost();

    request = new RestRequest();
    request.requestUri = BASE_URL + '/services/apexrest/portal/application/';
    request.httpMethod = 'POST';
    request.addHeader('Content-Type', 'application/json');

    body = new Map<String, Object>();
    body.put('subject', 'test');
    body.put('body', 'test');
    body.put('loanId', opp.Id);
    body.put('userId', 'adfs');
    request.requestBody = Blob.valueOf(JSON.serialize(body));
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIComments.doPost();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/comments/af-sdba/all';
    request.httpMethod = 'GET';

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/comments/loanId/' + opp.Id;
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIComments.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/comments/af-sdba/count';
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIComments.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/comments/af-ssdba/count';
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIComments.doGet();

    Comment__c comment = [SELECT Id FROM Comment__c LIMIT 1];

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/comments/' + comment.Id;
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIComments.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/comments/af-sdba/picklists/loans';
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIComments.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/comments/af-sdba/picklists/applications';
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIComments.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/comments/af-sdba/picklists/properties';
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIComments.doGet();
  }

  static testMethod void termsheetTests() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    RestRequest request = new RestRequest();
    request.requestUri = BASE_URL + '/services/apexrest/portal/application/';
    request.httpMethod = 'POST';
    request.addHeader('Content-Type', 'application/json');

    Map<String, Object> body = new Map<String, Object>();
    body.put('dealId', opp.Id);
    body.put('fileName', 'test.txt');
    body.put('base64String', EncodingUtil.base64Encode(Blob.valueOf('test')));
    request.requestBody = Blob.valueOf(JSON.serialize(body));
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPITermsheet.doPost();

    request = new RestRequest();
    request.requestUri = BASE_URL + '/services/apexrest/portal/application/';
    request.httpMethod = 'PATCH';
    request.addHeader('Content-Type', 'application/json');

    body = new Map<String, Object>();
    body.put('dealId', opp.Id);
    body.put('fileName', 'test.txt');
    body.put('base64String', EncodingUtil.base64Encode(Blob.valueOf('test')));
    request.requestBody = Blob.valueOf(JSON.serialize(body));
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPITermsheet.doPatch();

    Deal_document__c dealDoc = [
      SELECT
        Id,
        Added_On__c,
        Added_By__r.Name,
        Document_Type__c,
        Reviewed_By__r.Name,
        Reviewed_On__c,
        File_Name__c,
        ContentVersion_Id__c,
        Status__c,
        Comments__c,
        Reviewed__c
      FROM Deal_Document__c
      WHERE Document_Type__c = 'Executed Term Sheet' AND Deal__c = :opp.Id
      LIMIT 1
    ];

    new PortalAPIDocumentVault.Document(dealDoc);
    request = new RestRequest();
    request.requestUri = 'apexrest/portal/termsheet/executed/' + opp.Id;
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPITermSheet.doGet();

    dealDoc.Document_Type__c = 'Term Sheet';
    update dealdoc;

    AlchemyAPI.sendTermSheet(opp.Id, dealDoc.Id);

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/termsheet/' + opp.Id;
    request.httpMethod = 'GET';

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPITermSheet.doGet();
  }

  static testMethod void userTests() {
    Lead l = new Lead(
      FirstName = 'Test1',
      LastName = 'Tester',
      Company = 'Test Company1',
      Email = 'test111@test.com',
      Phone = '5555555555',
      MobilePhone = '5555555555',
      Introduction_Source__c = 'Event',
      Entry_Id__c = '11111',
      Form_Title__c = 'FORM',
      Alchemy_Portal_Id__c = 'aa-11',
      OwnerId = UserInfo.getUserId()
    );

    insert l;

    RestRequest request = new RestRequest();
    request.requestUri = 'apexrest/portal/user/entryId/11111';
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();

    PortalAPIUser.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/user/entryId/1a111';
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();

    PortalAPIUser.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/user/aa-11';
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();

    PortalAPIUser.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/user/aa11';
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();

    PortalAPIUser.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/user/aa-11';
    request.httpMethod = 'PATCH';
    RestContext.request = request;
    RestContext.response = new RestResponse();

    Map<String, Object> body = new Map<String, Object>();
    body.put('id', 'aa-11');
    body.put('businessCity', 'Irvine');
    request.requestBody = Blob.valueOf(JSON.serialize(body));
    PortalAPIUser.doPatch();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/user/af-sdba';
    request.httpMethod = 'PATCH';
    RestContext.request = request;
    RestContext.response = new RestResponse();

    body = new Map<String, Object>();
    body.put('id', 'af-sdba');
    body.put('businessCity', 'Irvine');
    body.put('leadId', l.Id);
    body.put('lastName', l.LastName);
    request.requestBody = Blob.valueOf(JSON.serialize(body));
    PortalAPIUser.doPatch();
  }

  static testMethod void documentTests() {
    Contact cont = [SELECT Id, AccountId FROM Contact LIMIT 1];

    Opportunity topp1 = new Opportunity();
    topp1.Name = 'documentTests';
    topp1.CloseDate = System.today();
    topp1.StageName = 'Initial Review';
    topp1.Loan_Size__c = 2000000;
    topp1.AccountId = cont.AccountId;
    topp1.Contact__c = cont.Id;
    topp1.Final_Loan_Amount__c = 100;
    topp1.Deal_Intro_Source__c = 'Hotline';
    topp1.Deal_Intro_Sub_Source__c = 'Main';
    topp1.Apex_Context__c = true;
    topp1.Term_Loan_Type__c = '5 Year';
    topp1.YM_Prepayment_Penalty__c = '48 Months';
    topp1.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert topp1;

    //topp1.Term_Sheet_Issued__c = System.today();
    // update topp1;

    Deal_Contact__c dc = new Deal_Contact__c(
      Contact__c = cont.Id,
      Deal__c = topp1.Id,
      Deal_Contact_Type__c = 'Individual',
      Entity_Type__c = 'Sponsor' //if statement based on record type.
    );

    insert dc;
    Test.startTest();
    Property__c prop = new Property__c();
    prop.Property_Type__c = 'SFR';
    prop.Deal__c = topp1.Id;
    prop.Calc_AveValue__c = 100000;
    prop.Name = 'test';
    prop.Property_Name__c = 'test Street';
    prop.City__c = 'test';
    prop.State__c = 'test';
    prop.ZipCode__c = 'test';
    insert prop;
    RestRequest request = new RestRequest();
    request.requestUri =
      'apexrest/portal/documentvault/af-sdba/vault/' + topp1.Id;
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();

    PortalAPIDocumentVault.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/documentvault/af-sdba/loans';
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDocumentVault.doGet();

    request = new RestRequest();
    request.requestUri =
      'apexrest/portal/documentvault/af-sdba/documentTypes/' + topp1.Id;
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDocumentVault.doGet();

    Test.stopTest();
    // Checklist_ITem__c item = [
    //   SELECT Id
    //   FROM Checklist_Item__c
    //   WHERE RecordType.DeveloperName = 'Document_Upload'
    //   LIMIT 1
    // ];
  }

  static testMethod void documentTests2() {
    Contact cont = [SELECT Id, AccountId FROM Contact LIMIT 1];

    Opportunity topp1 = new Opportunity();
    topp1.Name = 'documentTests';
    topp1.CloseDate = System.today();
    topp1.StageName = 'Initial Review';
    topp1.Loan_Size__c = 2000000;
    topp1.AccountId = cont.AccountId;
    topp1.Contact__c = cont.Id;
    topp1.Final_Loan_Amount__c = 100;
    topp1.Deal_Intro_Source__c = 'Hotline';
    topp1.Deal_Intro_Sub_Source__c = 'Main';
    topp1.Apex_Context__c = true;
    topp1.Term_Loan_Type__c = '5 Year';
    topp1.YM_Prepayment_Penalty__c = '48 Months';
    topp1.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert topp1;

    //topp1.Term_Sheet_Issued__c = System.today();
    // update topp1;

    Deal_Contact__c dc = new Deal_Contact__c(
      Contact__c = cont.Id,
      Deal__c = topp1.Id,
      Deal_Contact_Type__c = 'Individual',
      Entity_Type__c = 'Sponsor' //if statement based on record type.
    );

    insert dc;

    Test.startTest();
    RestRequest request = new RestRequest();
    RestContext.response = new RestResponse();
    ContentVersion cv = new ContentVersion(
      Title = 'test.txt',
      PathOnClient = 'test.txt',
      VersionData = Blob.valueOf('test.txt'),
      Uploaded_From_Portal_Id__c = 'af-sdba'
    );

    insert cv;

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/documentvault/af-sdba/uncategorized';
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDocumentVault.doGet();

    Checklist__c checklist = new Checklist__c();
    checklist.Deal__c = topp1.Id;
    insert checklist;

    Checklist_Section__c section = new Checklist_Section__c();
    section.Checklist__c = checklist.id;
    insert section;

    Document_Structure__mdt struct = [
      SELECT Id
      FROM Document_Structure__mdt
      LIMIT 1
    ];
    Checklist_Item__c item = new Checklist_Item__c();
    item.Checklist_Section__c = section.Id;
    // item.Checklist__c = checklist.Id;
    item.Doc_Structure_Id__c = struct.Id;
    insert item;
    request = new RestRequest();
    request.requestUri = 'apexrest/portal/documentvault/upload';
    request.httpMethod = 'POST';

    Map<String, Object> body = new Map<String, String>();
    body.put('id', cv.Id);
    body.put('itemId', item.Id);
    request.requestBody = Blob.valueOf(JSON.serialize(body));

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDocumentVault.doPost();
    // Test.stopTest();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/documents/af-sdba/' + topp1.Id;
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDocument.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/documents/af-sdbsa/' + topp1.Id;
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDocument.doGet();

    Deal_Document__c doc = [
      SELECT
        Id,
        Deal__r.Name,
        Document_Type__c,
        Deal__c,
        Name,
        Property__c,
        File_Name__c,
        Property__r.Name,
        ContentVersion_Id__c,
        Added_On__c
      FROM Deal_Document__c
      LIMIT 1
    ];

    new PortalAPIDocument.Document(doc);
    new PortalAPIDocument.DOcument(doc.Id);

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/documentvault/upload/base64';
    request.httpMethod = 'POST';
    body.put('base64String', EncodingUtil.base64Encode(Blob.valueOf('test')));
    body.put('Uploaded_From_Portal_Id__c', 'af-sdba');
    body.put('fileName', 'test.txt');
    body.put('Description', 'test');
    request.requestBody = Blob.valueOf(JSON.serialize(body));

    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIDocumentVault.doPost();

    Test.stopTest();
  }

  static testMethod void apiTests() {
    Contact cont = [SELECT Id, AccountId FROM Contact LIMIT 1];
    cont.Email = 'test@example.com';
    cont.Alchemy_Portal_Id__c = null;

    update cont;
    Lead l = new Lead(
      FirstName = 'Test1',
      LastName = 'Tester',
      Company = 'Test Company1',
      Email = 'test111@test.com',
      Phone = '5555555555',
      MobilePhone = '5555555555',
      Introduction_Source__c = 'Event',
      Entry_Id__c = '11111',
      Form_Title__c = 'FORM',
      OwnerId = UserInfo.getUserId()
    );

    insert l;

    Test.startTest();
    AlchemyAPI.createUser(cont.Id, 'Contact');
    AlchemyAPI.createUser(l.Id, 'Lead');

    Test.stopTest();
  }

  static testMethod void apiTests2() {
    Contact cont = [SELECT Id, AccountId FROM Contact LIMIT 1];

    Opportunity topp2 = new Opportunity();
    topp2.Name = 'apiTests2 1';
    topp2.CloseDate = System.today();
    topp2.StageName = 'Initial Review';
    topp2.Loan_Size__c = 2000000;
    topp2.AccountId = cont.AccountId;
    topp2.Contact__c = cont.Id;
    topp2.Final_Loan_Amount__c = 100;
    topp2.Deal_Intro_Source__c = 'Hotline';
    topp2.Deal_Intro_Sub_Source__c = 'Main';
    topp2.Apex_Context__c = true;
    topp2.Term_Loan_Type__c = '5 Year';
    topp2.YM_Prepayment_Penalty__c = '48 Months';
    topp2.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert topp2;

    Test.startTest();

    RestRequest request = new RestRequest();
    request.requestUri = 'apexrest/portal/checklist/milestones/' + topp2.Id;
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIChecklist.doGet();

    Opportunity topp3 = new Opportunity();
    topp3.Name = 'apiTests2 2';
    topp3.CloseDate = System.today();
    topp3.StageName = 'Initial Review';
    topp3.Loan_Size__c = 2000000;
    topp3.AccountId = cont.AccountId;
    topp3.Contact__c = cont.Id;
    topp3.Final_Loan_Amount__c = 100;
    topp3.Deal_Intro_Source__c = 'Hotline';
    topp3.Deal_Intro_Sub_Source__c = 'Main';
    topp3.Apex_Context__c = true;
    topp3.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    ]
    .Id;
    insert topp3;

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/checklist/milestones/' + topp3.Id;
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIChecklist.doGet();

    Test.stopTest();
  }

  static testMethod void apiTests3() {
    Contact cont = [SELECT Id, AccountId FROM Contact LIMIT 1];

    Opportunity topp2 = new Opportunity();
    topp2.Name = 'apiTests2 1';
    topp2.CloseDate = System.today();
    topp2.StageName = 'Initial Review';
    topp2.Loan_Size__c = 2000000;
    topp2.AccountId = cont.AccountId;
    topp2.Contact__c = cont.Id;
    topp2.Final_Loan_Amount__c = 100;
    topp2.Deal_Intro_Source__c = 'Hotline';
    topp2.Deal_Intro_Sub_Source__c = 'Main';
    topp2.Apex_Context__c = true;
    topp2.Term_Loan_Type__c = '5 Year';
    topp2.YM_Prepayment_Penalty__c = '48 Months';
    topp2.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    insert topp2;

    Test.startTest();
    RestRequest request = new RestRequest();
    request.requestUri = 'apexrest/portal/broker/invite/';
    request.httpMethod = 'POST';

    Map<String, Object> body = new Map<String, String>();

    body.put('brokerId', 'af-sdba');
    body.put('borrowerEmail', 'test@example.com');
    body.put('borrowerFirstName', 'firstname');
    body.put('borrowerLastName', 'lastname');
    body.put('borrowerLastName', 'test company');
    body.put('borrowerId', 'af-sdaa');
    body.put('dealId', topp2.Id);

    request.requestBody = Blob.valueOf(JSON.serialize(body));

    RestContext.request = request;
    RestContext.response = new RestResponse();

    PortalAPIBroker.doPost();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/broker/invite/';
    request.httpMethod = 'POST';

    body = new Map<String, String>();
    Application__c application = new Application__c();
    insert application;
    body.put('brokerId', 'af-sdba');
    body.put('borrowerEmail', 'test@example.com');
    body.put('borrowerFirstName', 'firstname');
    body.put('borrowerLastName', 'lastname');
    body.put('borrowerLastName', 'test company');
    body.put('borrowerId', 'af-sdaa');
    body.put('applicationId', application.Id);

    request.requestBody = Blob.valueOf(JSON.serialize(body));

    RestContext.request = request;
    RestContext.response = new RestResponse();

    PortalAPIBroker.doPost();

    Test.stopTest();
  }

  static testMethod void apiTest4() {
    RestRequest request = new RestRequest();
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    request.requestUri = 'apexrest/portal/fundings/' + opp.Id + '/new/';
    request.httpMethod = 'POST';

    ContentVersion cv = new ContentVersion(
      Title = 'test.txt',
      PathOnClient = 'test.txt',
      VersionData = Blob.valueOf('test.txt'),
      Uploaded_From_Portal_Id__c = 'af-sdba'
    );

    insert cv;

    Map<String, Object> body = new Map<String, Object>();

    body.put('recordType', 'No Renovation');
    body.put('streetAddress', '5709 Caheunga Blvd');
    body.put('city', 'North Hollywood');
    body.put('state', 'CA');
    body.put('zipCode', '91601');
    body.put('propertyType', '2-4 Unit');
    body.put('numberOfUnits', 2);
    body.put('numberOfBathrooms', 2);
    body.put('numberOfBedrooms', 3);
    body.put('squareFootage', '2500');
    body.put('transactyionType', 'Refinance');
    body.put('requestedFundingDate', '2022-01-01');
    body.put('acquisitionPrice', 250000);
    body.put('purchaseDate', '2021-01-01');
    body.put('contractCloseDate', '2022-01-01');
    body.put('titleCompany', 'Test Title Company');
    body.put('titleContactName', 'Title Contact');
    body.put('titleContactPhone', '555-555-5555');
    body.put('titleContactEmail', 'title@example.com');
    body.put('interiorContact', 'Interior Contact');
    body.put('interiorAccessPOCPhone', '555-555-5555');
    body.put('interiorAccessPOCPhone', 'interior@example.com');
    body.put('settlementStatementId', cv.Id);
    body.put('purchaseContractId', cv.Id);
    List<Map<String, Object>> funding = new List<Map<String, Object>>();
    funding.add(body);

    request.requestBody = Blob.valueOf(JSON.serialize(funding));
    RestContext.request = request;
    RestContext.response = new RestResponse();
    PortalAPIFunding.doPost();
  }
}
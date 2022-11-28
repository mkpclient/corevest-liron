@isTest
private class AlchemyAPITests {
  public static string BASE_URL = system.url.getOrgDomainUrl().toExternalForm();
  @testSetup
  static void setup() {
    Test_Helper.createRate();
    Test_Helper.createDealLoanNumber();
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
    opp.Floor__c = 1.00;
    opp.Index_Margin__c = 1.50;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_source__c = 'Main';
    opp.Application__c = app.Id;
    opp.Contact__c = cont.Id;
    update opp;

    Deal_Contact__c dc = new Deal_Contact__c(
      Deal__c = opp.Id,
      COntact__c = cont.Id,
      Entity_Type__c = 'Portal Access'
    );
    insert dc;

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
    AlchemyAPI.getDealIds(new PortalAPIUser.PortalUser('test-123'));
    AlchemyAPI.getDealIdsContactId(cont.Id);
    AlchemyAPI.updateUser(cont.Id);
    ALchemyAPI.updateUser(l.Id);
    AlchemyAPI.deleteUser('aa-11');
    AlchemyAPI.tests();
    Test.stopTest();
  }

  static testMethod void apiTests2() {
    Test.startTest();
    AlchemyAPI.createOperationsUser(UserInfo.getUserId());
    Test.stopTest();
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
}
@isTest
private class PortalAPIUserTests {
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

  static testMethod void userTests() {
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

    // request = new RestRequest();
    // request.requestUri = 'apexrest/portal/user/aa11';
    // request.httpMethod = 'GET';
    // RestContext.request = request;
    // RestContext.response = new RestResponse();

    // PortalAPIUser.doGet();

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
    Test.startTest();
    request = new RestRequest();
    request.requestUri = 'apexrest/portal/user/af-sdba';
    request.httpMethod = 'PATCH';
    RestContext.request = request;
    RestContext.response = new RestResponse();
    Lead l = [SELECT id, LastName FROM Lead LIMIT 1];
    body = new Map<String, Object>();
    body.put('id', 'aa-11');
    body.put('businessCity', 'Irvine');
    body.put('leadId', l.Id);
    body.put('lastName', l.LastName);
    request.requestBody = Blob.valueOf(JSON.serialize(body));
    PortalAPIUser.doPatch();
    Test.stopTest();
  }

  static testMethod void userTests1() {
    User u = new User(Id = UserInfo.getUserId(), Portal_Id__c = 'test');
    update u;

    RestRequest request = new RestRequest();
    request.requestUri = 'apexrest/portal/user/operations/test/borrowers/';
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();

    PortalAPIUser.doGet();

    request = new RestRequest();
    request.requestUri = 'apexrest/portal/user/operations/test/borrowers/count';
    request.httpMethod = 'GET';
    RestContext.request = request;
    RestContext.response = new RestResponse();

    PortalAPIUser.doGet();
  }

  static testMethod void userTests2() {
    Contact cont = [SELECT Id, AccountId FROM Contact LIMIT 1];
    List<Id> ids = new List<Id>();
    ids.add(cont.Id);
    system.enqueueJob(new UpdatePortalUserQueueable(ids));
    List<String> portalIds = new List<String>();
    portalIds.add('test');
    system.enqueueJob(new UpdatePortalUserQueueable(portalIds, 'delete'));
  }

  static testMethod void userTests3() {
    User u = new User(
      Id = UserInfo.getUserId(),
      Create_Operations_Portal_User__c = true
    );
    update u;
  }
}
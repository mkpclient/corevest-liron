@isTest
private class PortalAPICommentsTests {
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
  }
  static testMethod void commentTests() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    RestRequest request = new RestRequest();
    request.requestUri = 'apexrest/portal/comments';
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
    request.requestUri = 'apexrest/portal/comments';
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
    request.requestUri = 'apexrest/portal/comments/read';
    request.httpMethod = 'POST';
    request.addHeader('Content-Type', 'application/json');

    List<Comment__c> comments = [SELECT Id FROM Comment__c LIMIT 1];

    List<Object> listbody = new List<Object>();
    listbody.add(comments[0].Id);
    request.requestBody = Blob.valueOf(JSON.serialize(listbody));
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
    Test.startTest();
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

    MessageCenterController.getAllComments(opp.Id);
    MessageCenterController.getCommentsById(comment.Id);

    Test.stopTest();
  }
}
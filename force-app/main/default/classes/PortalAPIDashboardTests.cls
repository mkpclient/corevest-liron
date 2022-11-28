@isTest
private class PortalAPIDashboardTests {
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
    Test.startTest();
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
}
@isTest
private class PortalAPIApplicationTests {
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
    // Opportunity opp = test_Helper.createOpportunity(acc, cont);
    // opp.Apex_Context__c = true;
    // opp.RecordTypeId = [
    //   SELECT Id
    //   FROM RecordType
    //   WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    // ]
    // .Id;
    // opp.StageName = 'Hold';
    // opp.Draw_Period__c = '12 Months';
    // opp.Repayment_Period__c = '9 Months';
    // opp.LOC_Loan_Type__c = 'Credit Line';
    // opp.Loan_Size__c = 3000000;
    // opp.Line_Expiration__c = '18 Months';
    // opp.Requested_LTC_Max__c = 70;
    // opp.Requested_LTV_Max__c = 80;
    // opp.Requested_Origination_Fee__c = 0;
    // opp.Requested_Draw_Fee__c = 2;
    // opp.Requested_Exit_Fee__c = 0;
    // opp.Requested_Interest_Type__c = 'Fixed';
    // opp.Requested_Rate_1_9_Months__c = 10;
    // opp.Requested_Revolving__c = 'Yes';
    // opp.Requested_Draw_Fee_Cap__c = 'None';
    // opp.Product_Sub_Type__c = 'Renovation';
    // opp.Interest_Rate_Type__c = 'Floating';
    // opp.Index__c = '1M LIBOR';
    // opp.Index_Floor__c = '1.00%';
    // opp.Index_Margin__c = 1.50;
    // opp.Deal_Intro_Source__c = 'Hotline';
    // opp.Deal_Intro_Sub_source__c = 'Main';
    // opp.Application__c = app.Id;
    // opp.Contact__c = cont.Id;
    // update opp;
  }
  static testMethod void applicationAPITest() {
    RestRequest request = new RestRequest();
    request.requestUri = BASE_URL + '/services/apexrest/portal/application/';
    request.httpMethod = 'POST';
    request.addHeader('Content-Type', 'application/json');

    Map<String, Object> body = new Map<String, Object>();
    body.put('loanType', 'Single Asset Bridge Loan');
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
    body.put('loanType', 'Single Asset Bridge Loan');
    body.put('user_id', 'af-sdba');
    body.put('status', 'Completed');
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
    request.requestURI = 'apexrest/portal/application/af-sdba/prefill/sab';
    PortalAPIApplication.doGet();

    // String testRequest =
    //   '[{"Name": "Test Street 2","Address__c": "Test Street 2","Acquisition_Date__c": "2020-04-05","Comments__c": "Test comments","City__c": "Bellflower","Application__c": "' +
    //   applicationId +
    //   '","State__c": "California","Country__c": "United States","Zipcode__c": "90706","Property_Type__c": "SFR","Number_of_Units__c": 5,"Bedrooms__c": 1,"Bathrooms__c": 1,"Square_Footage__c": 900,"Year_Built__c": "1958","Air_Conditioning__c": "Yes","Pool__c": "Yes","Section_8__c": "Yes","Acquisition_Price__c": 2500.00,"Transaction_Costs__c": 2500.00,"Rehab_Costs__c": 2500.00,"Rehab_Completion_Date__c": "1991-04-17","Total_Basis__c": 2500.00,"Borrower_Opinion_of_Current_Value__c": 2500.00,"Currently_Leased__c": "Yes","Lease_Ready__c": "Yes","Lease_Start_Date__c": "1991-04-17","Lease_End_Date__c": "1991-04-17","Lease_Term__c": "string","Monthly_Rent__c": 2500.00,"Security_Deposit__c": 2500.00,"HOA__c": 2500.00,"Special_Assessments__c": 2500.00,"Taxes__c": 2500.00,"Insurance__c": 2500.00,"Property_Management__c": 2500.00,"MaintenanceRepairs__c": 2500.00,"Owner_Paid_Utilities__c": 2500.00,"Landscaping_Expense__c": 2500.00,"Other_Expenses__c": 2500.00,"Lease_UpMarketing__c": 2500.00,"Vacancy_RepairsMaintenance__c": 2500.00,"Credit_Loss__c": 2500.00,"Total_Expenses__c": 2500.00,"CapEx_Reserves__c": 2500.00,"Other_Reserves__c": 2500.00,"NOI__c": 2500.00}]';
    // request = new RestRequest();
    // request.requestUri =
    //   BASE_URL + '/services/apexrest/portal/application/properties';
    // request.httpMethod = 'POST';
    // request.addHeader('Content-Type', 'application/json');

    // request.requestBody = Blob.valueOf(testRequest);
    // RestContext.request = request;
    // RestContext.response = new RestResponse();
    // PortalAPIApplicationProperty.doPost();

    // Application_Property__c prop = [
    //   SELECT Id
    //   FROM Application_Property__c
    //   LIMIT 1
    // ];

    // request = new RestRequest();
    // request.requestUri = 'apexrest/portal/application/properties/' + prop.Id;
    // request.httpMethod = 'GET';

    // RestContext.request = request;
    // RestContext.response = new RestResponse();
    // PortalAPIApplicationProperty.doGet();

    // request = new RestRequest();
    // request.requestUri =
    //   'apexrest/portal/application/properties/applicationId/' + applicationId;
    // request.httpMethod = 'GET';

    // RestContext.request = request;
    // RestContext.response = new RestResponse();
    // PortalAPIApplicationProperty.doGet();

    // request = new RestRequest();
    // request.requestUri = 'apexrest/portal/application/properties/' + prop.Id;
    // request.httpMethod = 'DELETE';

    // RestContext.request = request;
    // RestContext.response = new RestResponse();
    // PortalAPIApplicationProperty.doDelete();

    // request = new RestRequest();
    // request.requestUri =
    //   'apexrest/portal/application/properties/applicationId/' + applicationId;
    // request.httpMethod = 'GET';

    // RestContext.request = request;
    // RestContext.response = new RestResponse();
    // PortalAPIApplicationProperty.doGet();

    // testRequest = '[{"Name": "Test Street 2","Address__c": "Test Street 2","Acquisition_Date__c": "2020-04-05","Comments__c": "Test comments","City__c": "Bellflower","State__c": "California","Country__c": "United States","Zipcode__c": "90706","Property_Type__c": "SFR","Number_of_Units__c": 5,"Bedrooms__c": 1,"Bathrooms__c": 1,"Square_Footage__c": 900,"Year_Built__c": "1958","Air_Conditioning__c": "Yes","Pool__c": "Yes","Section_8__c": "Yes","Acquisition_Price__c": 2500.00,"Transaction_Costs__c": 2500.00,"Rehab_Costs__c": 2500.00,"Rehab_Completion_Date__c": "1991-04-17","Total_Basis__c": 2500.00,"Borrower_Opinion_of_Current_Value__c": 2500.00,"Currently_Leased__c": "Yes","Lease_Ready__c": "Yes","Lease_Start_Date__c": "1991-04-17","Lease_End_Date__c": "1991-04-17","Lease_Term__c": "string","Monthly_Rent__c": 2500.00,"Security_Deposit__c": 2500.00,"HOA__c": 2500.00,"Special_Assessments__c": 2500.00,"Taxes__c": 2500.00,"Insurance__c": 2500.00,"Property_Management__c": 2500.00,"MaintenanceRepairs__c": 2500.00,"Owner_Paid_Utilities__c": 2500.00,"Landscaping_Expense__c": 2500.00,"Other_Expenses__c": 2500.00,"Lease_UpMarketing__c": 2500.00,"Vacancy_RepairsMaintenance__c": 2500.00,"Credit_Loss__c": 2500.00,"Total_Expenses__c": 2500.00,"CapEx_Reserves__c": 2500.00,"Other_Reserves__c": 2500.00,"NOI__c": 2500.00}]';
    // request = new RestRequest();
    // request.requestUri =
    //   BASE_URL + '/services/apexrest/portal/application/properties';
    // request.httpMethod = 'POST';
    // request.addHeader('Content-Type', 'application/json');

    // request.requestBody = Blob.valueOf(testRequest);
    // RestContext.request = request;
    // RestContext.response = new RestResponse();
    // PortalAPIApplicationProperty.doPost();
  }
}
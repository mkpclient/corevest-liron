@isTest
public class HouseCanaryTest {
  @testSetup
  static void setUpData() {
    test_Helper.createDealLoanNumber();
    Account acc = new Account();
    acc.Name = 'Berkadia Commercial Mortgage';
    acc.BillingCountry = 'United States';
    acc.BillingState = 'California';
    acc.Introductions_Source__c = 'Hotline';
    acc.Introduction_Subsource__c = 'Main';
    acc.Alternate_Phone__c = '5555555555';
    insert acc;

    Contact con = new Contact();
    con.FirstName = 'test';
    con.LastName = 'test';
    con.MailingCountry = 'United States';
    con.MailingState = 'California';
    con.MobilePhone = '5555555555';
    con.Phone = '7777777777';
    con.Experian__c = 700;
    con.TransUnion__c = 710;
    con.Equifax__c = 700;
    con.Years_of_Experience__c = 10;
    con.Rental_Units_Owned__c = '5';
    con.Sponsor_Tier__c = 'Tier 1';
    con.Experience__c = 5;
    con.AccountId = acc.Id;
    insert con;

    Opportunity opp = new Opportunity();
    opp.Name = 'Test House Canary';
    opp.CloseDate = System.today();
    opp.StageName = 'Initial Review';
    opp.Loan_Size__c = 2000000;
    opp.Rate__c = 1;
    opp.Final_Loan_Amount__c = 100;
    opp.Deal_Intro_Source__c = 'Hotline';
    opp.Deal_Intro_Sub_Source__c = 'Main';
    opp.Deal_Intro_Sub_Source__c = 'Main';
    opp.Apex_Context__c = true;
    opp.Term_Loan_Type__c = '5 Year';
    opp.YM_Prepayment_Penalty__c = '48 Months';
    opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'Term_Loan'
    ]
    .Id;
    opp.AccountId = acc.Id;
    opp.Contact__c = con.Id;
    insert opp;

    Property__c p = new Property__c();
    p.Deal__c = opp.Id;
    p.Property_Type__c = 'SFR';
    p.Name = '103 Forest Point Dr';
    p.Property_Name__c = '103 Forest Point Dr';
    p.State__c = 'MS';
    p.City__c = 'Brandon';
    p.ZipCode__c = '39047';
    p.Number_of_Beds__c = 4;
    p.Number_of_Bath__c = 3.5;
    p.Square_Feet__c = '1745';
    p.pool__c = 'No';
    insert p;
  }

  static testMethod void testHouseCanaryCall() {
    List<Property__c> ps = [
      SELECT
        Id,
        Name,
        City__c,
        State__c,
        ZipCode__c,
        Status__c,
        Number_of_Beds__c,
        Number_of_Bath__c,
        Square_Feet__c,
        Year_Built__c,
        APN__c,
        Borrower_Opinion_of_Current_Value__c,
        Property_Type__c,
        Invalid_Address__c,
        Calc_AveValue__c,
        Is_HOA__c,
        Monthly_Rent__c,
        No_of_Stories__c
      FROM Property__c
      LIMIT 1
    ];
    Id recordId = ps[0].Id;
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockBeekinCallout());
    HouseCanaryAPI.callHouseCanarySingle(ps[0], ps[0].Id, false);
    HouseCanaryAPI.callHouseCanarySingle(ps[0], ps[0].Id, true);
    Test.stopTest();
  }

  public class MockBeekinCallout implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      String method = 'GET';
      HTTPResponse response = new HTTPResponse();
      response.setBody(
        '{"checks": {"All pre-analysis checks passed": true, "Address is supported": true, "Address is complete": true, "Precise geocode is available for address": true, "Property at address is of supported type": true, "Census block group information is available": true, "Enough information on neighborhood characteristics is available": true, "Gross living area of property is available or provided as input": true, "Comps available for analysis": false}, "input_params": {"street_address": "103 Forest Point Dr", "zipcode": "39047", "include_comp_based_analysis": "true", "product_type": "value_analysis"}, "recommended_approach": "Minor exceptions - Human review", "hc_avm_value_analysis": {"avm_value": 250834, "avm_confidence": "high", "avm_fsd": 0.12, "neighborhood_analysis": {"avm_value_sqft": 118, "5th_percentile_value_per_sqft": 107.1, "95th_percentile_value_per_sqft": 188.6, "within_neighborhood_norms": true}}}'
      );
      response.setHeader('Content-Type', 'application/json');
      response.setStatusCode(200);

      return response;
    }
  }
}
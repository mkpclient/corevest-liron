@isTest
public class BeekinAPITests {
  @testSetup
  static void setUpData() {
    Beekin_Settings__c beekinSettings = Beekin_Settings__c.getInstance();
	BeekinSettings.Endpoint__c = 'https://beta.api.beekin.co/';
    BeekinSettings.APIKey__c = '123ABC&';      
    insert beekinSettings;
test_Helper.createDealLoanNumber();
    Account acc = new Account();
    acc.Name = 'Test';
    insert acc;

    Contact con = new Contact();
    con.FirstName = 'Test';
    con.LastName = 'Test';
    con.AccountId = acc.Id;
    insert con;

    Opportunity opp = new Opportunity();
    opp.Name = 'Test';
    opp.AccountId = acc.Id;
    opp.Contact__c = con.Id;
    opp.StageName = 'Initial Review';
    opp.CloseDate = System.today();
    insert opp;

    Property__c p = new Property__c();
    p.Deal__c = opp.Id;
    p.Property_Type__c = 'SFR';
    p.Name = '1810 LEDGESTONE DRIVE';
    p.Property_Name__c = '1810 LEDGESTONE DRIVE';
    p.City__c = 'Houston';
    p.State__c = 'TX';
    p.ZipCode__c = '76549';
    p.Number_of_Beds__c = 4;
    p.Number_of_Bath__c =3;
    p.Square_Feet__c = '3000';
    p.pool__c = 'No';
    insert p;
  }

  static testMethod void testCallBeekin() {
    List<Property__c> ps = [
      SELECT
        Id,
        Name,
        City__c,
        State__c,
        ZipCode__c,
        Number_of_Beds__c,
        Number_of_Bath__c,
        Square_Feet__c,
        Year_Built__c,
        Property__c.Deal__c,
        pool__c,
        Property_Type__c
      FROM Property__c
      LIMIT 1
    ];
    Id recordId = ps[0].Id;
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockBeekinCallout());
    BeekinAPI.callBeekinSingle(ps[0], recordId);
    Test.stopTest();
  }
    
  static testMethod void testCallBeekinBatch() {
    List<Property__c> ps = [
      SELECT
        Id,
        Name,
        City__c,
        State__c,
        ZipCode__c,
        Number_of_Beds__c,
        Number_of_Bath__c,
        Square_Feet__c,
        Year_Built__c,
        Property__c.Deal__c,
        pool__c,
        Property_Type__c
      FROM Property__c
      LIMIT 1
    ];
    Id recordId = ps[0].Id;
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockBeekinCallout());
    BeekinAPI.callBeekin(ps);
    Test.stopTest();
  }    
    
  public class MockBeekinCallout implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
     String endpoint = 'https://beta.api.beekin.co/' + '/rent-estimate' + 'address=9216 Maverick Dr,Cincinnati,OH,45231&sqft=1359&beds=4&baths=1&property_type=0';
     String method = 'GET';
     HTTPResponse response = new HTTPResponse();
     response.setBody(
        '{"address": "9216 Maverick Dr,Cincinnati,OH,45231", "estimated_rent": 1607, "geolocation": { "lat": 39.2388118, "lng": -84.57107409999999},"lower": 1602,"upper": 1610}'
      );
     response.setHeader('Content-Type', 'application/json');
     response.setStatusCode(200);

     return response;
    }
  }
   
}
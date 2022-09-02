@isTest
public class RedBellAPITests {
  @testSetup
  static void setUpData() {
  test_Helper.createDealLoanNumber();       
    Red_Bell_Settings__c rbsettings = Red_Bell_Settings__c.getInstance();
    rbsettings.Username__c = 'TESTUSER';
    rbsettings.Password__c = '123ABC&';
    rbsettings.Grant_Type__c = 'password';
    rbsettings.Endpoint__c = 'https://beta.redbellre.com/orders/api';
    insert rbsettings;

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
    p.Property_Type__c = 'Other';
    p.Name = '1810 LEDGESTONE DRIVE';
    p.Property_Name__c = '1810 LEDGESTONE DRIVE';
    p.State__c = 'TX';
    p.ZipCode__c = '76549';
    insert p;

    String ACCESS_TOKEN;
    Boolean RETRIED_AUTH = false;
  }

  static testMethod void testCallRedBell() {
    List<Property__c> ps = [
      SELECT
        Id,
        Name,
        City__c,
        State__c,
        ZipCode__c,
        Status__c,
        Calc_AveValue__c,
        Number_of_Beds__c,
        Number_of_Bath__c,
        Square_Feet__c,
        Year_Built__c,
        APN__c,
        Property__c.Deal__c
      FROM Property__c
      LIMIT 1
    ];
    Id recordId = ps[0].Id;
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockRedBellCallout());
    RedBellAPI.callRedBell(ps, recordId);
    Test.stopTest();
  }

  public class MockRedBellCallout implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      String endpoint = request.getEndpoint();
      String method = request.getMethod();
      HTTPResponse response = new HTTPResponse();
      response.setBody(
        '{"Ave":{"Comps":[{"Address":"3505 Granite Dr","City":"Killeen","State":"TX","Zip":"76549","Image":"https://rbimages.blob.core.windows.net/rb-images/US/real-estate/mls-homes/single-family-property/for-sale/TX/Killeen/76549/1472-8659703-20180914-3505-Granite-Dr-0.jpg","Bed":3,"Bath":2.00,"Sqft":1493,"Garage":2.00,"LotSize":"0.260","YearBuilt":1992,"Units":1,"TargetDistance":0.10,"ListDate":"2018-09-14T00:00:00","ListPrice":115000.00,"SoldDate":"2018-10-19T00:00:00","SoldPrice":117000.00,"ActDom":3,"TotDom":35,"SqftPrice":78.37,"PercentOfValuation":0.473182,"IncludedInCalculation":true,"CompType":"Sold"},{"Address":"1903 Lava Ln","City":"Killeen","State":"TX","Zip":"76549","Image":"https://rbimages.blob.core.windows.net/rb-images/US/real-estate/mls-homes/single-family-property/for-sale/TX/Killeen/76549/1472-3336880-20180531-1903-Lava-Ln-0.jpg","Bed":4,"Bath":2.00,"Sqft":1570,"Garage":2.00,"LotSize":"0.196","YearBuilt":1997,"Units":1,"TargetDistance":0.19,"ListDate":"2018-05-31T00:00:00","ListPrice":130000.00,"SoldDate":"2018-09-17T00:00:00","SoldPrice":125000.00,"ActDom":67,"TotDom":109,"SqftPrice":79.62,"PercentOfValuation":0.272997,"IncludedInCalculation":true,"CompType":"Sold"},{"Address":"2301 Ledgestone Drive","City":"Killeen","State":"TX","Zip":"76549","Image":"https://rbimages.blob.core.windows.net/rb-images/US/real-estate/mls-homes/single-family-property/for-sale/TX/Killeen/76549/1644-349722-0-2301-Ledgestone-Drive-0.jpg","Bed":3,"Bath":2.00,"Sqft":1620,"Garage":2.00,"LotSize":"0.29860","YearBuilt":1996,"Units":1,"TargetDistance":0.29,"ListDate":"2018-06-12T00:00:00","ListPrice":124900.00,"SoldDate":"2018-07-31T00:00:00","SoldPrice":122000.00,"ActDom":10,"TotDom":49,"SqftPrice":75.31,"PercentOfValuation":0.253821,"IncludedInCalculation":true,"CompType":"Sold"}],"Subject":{"PoolName":"Default","LoanNumber":null,"Address":"1810 LEDGESTONE DRIVE","City":"KILLEEN","State":"TX","Zip":"76549","Subdivision":null,"Image":null,"Bed":3,"Bath":2.00,"Sqft":1656,"Garage":2.00,"LotSize":"0","YearBuilt":1996,"DnaSource":"Public Record","Reo":false,"PropertyType":"Single Family","MarketArea":"AVE Default - 1 mile","CompsGoingBack":6,"AsOfDate":"2018-11-19T00:00:00","AveDate":"2018-11-19T00:00:00","CalculatedPrice":130003.0,"PricePerSqft":78.50,"RetailMarket":0.8898,"DistressedMarket":0.1102,"SummaryComments":"","APN":null,"SoldDate":null,"SoldPrice":null}},"Status":0,"RbOrderId":"818057-4","Message":"Order placed successfully"}'
      );
      response.setHeader('Content-Type', 'application/json');
      response.setStatusCode(200);

      return response;
    }
  }
}
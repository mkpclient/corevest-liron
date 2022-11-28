@isTest
public with sharing class CLOAsset_HelperTests {
  @TestSetup
  static void makeData() {
    Test_Helper.createDealLoanNumber();
    Test_Helper.setupProduct2();
    Test_Helper.createRate();

    Account a = Test_Helper.createAccount();
    Contact c = Test_Helper.createContact(a);
    Opportunity o = Test_Helper.createOpportunity(a, c);

    List<Property__c> props = Test_Helper.createProperties(o);
  }

  @isTest
  public static void testAfterInsert() {
    Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
    Property__c p = [SELECT Id FROM Property__c LIMIT 1];
    CLO_Asset_Details__c cad = new CLO_Asset_Details__c(
      Deal_ID__c = o.Id,
      Related_Property__c = p.Id,
      Interest_Rate_Cap_Reserve__c = 1000,
      Reserve_Cap_Ex__c = 2000,
      Reserve_Insurance__c = 3000,
      Reserve_Tax__c = 4000
    );
    Test.startTest();
    insert cad;
    Test.stopTest();

    o = [
      SELECT
        Id,
        Reserve_Insurance__c,
        Reserve_Tax__c,
        Interest_Rate_Cap_Reserve__c,
        Reserve_Cap_Ex__c
      FROM Opportunity
      LIMIT 1
    ];

    System.assertEquals(cad.Reserve_Insurance__c, o.Reserve_Insurance__c, 'Reserve_Insurance__c');
    System.assertEquals(cad.Reserve_Tax__c, o.Reserve_Tax__c, 'Reserve_Tax__c');
    System.assertEquals(cad.Interest_Rate_Cap_Reserve__c, o.Interest_Rate_Cap_Reserve__c, 'Interest_Rate_Cap_Reserve__c');
    System.assertEquals(cad.Reserve_Cap_Ex__c, o.Reserve_Cap_Ex__c, 'Reserve_Cap_Ex__c');
  }

  @isTest
  public static void testAfterUpdate() {
    Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
    Property__c p = [SELECT Id FROM Property__c LIMIT 1];

    CLO_Asset_Details__c cad = new CLO_Asset_Details__c(
      Deal_ID__c = o.Id,
      Related_Property__c = p.Id
    );
    Test.startTest();
    insert cad;

    cad = new CLO_Asset_Details__c(
      Id = cad.Id,
      Interest_Rate_Cap_Reserve__c = 1000,
      Reserve_Cap_Ex__c = 2000,
      Reserve_Insurance__c = 3000,
      Reserve_Tax__c = 4000,
      Property_Name__c = '123 Sesame St',
      Property_City__c = 'Huntington',
      Property_State__c = 'WV',
      Property_Zip_Code__c = '25701',
      Property_County__c = 'Cabell',
      Year_Built__c = '1900',
      Property_Type__c = '2-4 Unit',
      Number_of_Units__c = 2,
      First_Payment_Date__c = System.today().addMonths(-4),
      Engineering_Report_Date__c = System.today().addMonths(-1),
      Environmental_Report_Date_Phase_1__c = System.today().addDays(-20),
      Environmental_Report_Date_Phase_2__c = System.today().addDays(-10),
      Seismic_Report_Date__c = System.today().addMonths(-8)
    );

    update cad;
    Test.stopTest();

    o = [
      SELECT
        Id,
        Reserve_Insurance__c,
        Reserve_Tax__c,
        Interest_Rate_Cap_Reserve__c,
        Reserve_Cap_Ex__c
      FROM Opportunity
      LIMIT 1
    ];

    System.assertEquals(cad.Reserve_Insurance__c, o.Reserve_Insurance__c, 'Reserve_Insurance__c');
    System.assertEquals(cad.Reserve_Tax__c, o.Reserve_Tax__c, 'Reserve_Tax__c');
    System.assertEquals(cad.Interest_Rate_Cap_Reserve__c, o.Interest_Rate_Cap_Reserve__c, 'Interest_Rate_Cap_Reserve__c');
    System.assertEquals(cad.Reserve_Cap_Ex__c, o.Reserve_Cap_Ex__c, 'Reserve_Cap_Ex__c');
  }
}
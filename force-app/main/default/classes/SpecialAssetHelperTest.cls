@isTest
public with sharing class SpecialAssetHelperTest {
  @TestSetup
  static void makeData() {
    Test_Helper.createDealLoanNumber();
    Account a = Test_Helper.createAccount();
    Contact c = Test_Helper.createContact(a);
    Opportunity o = Test_Helper.createOpportunity(a, c);

    List<Property__c> props = Test_Helper.createProperties(o);
  }

  @isTest
  public static void testSpecialAsset() {
    List<Property__c> props = [SELECT Id FROM Property__c];

    List<Special_Asset__c> sas = new List<Special_Asset__c>();

    for (Property__c p : props) {
      sas.add(
        new Special_Asset__c(
          Property__c = p.Id,
          Special_Asset_Manager__c = Userinfo.getUserId(),
          Special_Asset_Reason__c = 'Title',
          Severity_Level__c = 'Decision Required',
          Resolved_Date__c = System.today(),
          Resolution_Type__c = 'Sell REO'
        )
      );
    }

    insert sas;

    List<Special_Asset__c> createdSas = [
      SELECT Id, REO_Date__c
      FROM Special_Asset__c
    ];
    for (Special_Asset__c sa : createdSas) {
      sa.REO_Date__c = System.today();
    }

    update createdSas;
  }
}
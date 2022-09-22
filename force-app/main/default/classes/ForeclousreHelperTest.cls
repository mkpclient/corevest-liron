@isTest
public with sharing class ForeclousreHelperTest {
   @TestSetup
   static void makeData(){
    Test_Helper.createDealLoanNumber();
        Account a = Test_Helper.createAccount();
        Contact c = Test_Helper.createContact(a);
        Opportunity o = Test_Helper.createOpportunity(a, c);

        List<Property__c> props = Test_Helper.createProperties(o);

        List<Special_Asset__c> sas = new List<Special_Asset__c>();

        for(Property__c p : props) {
            sas.add(new Special_Asset__c(
                Property__c = p.Id,
                Special_Asset_Manager__c = Userinfo.getUserId(),
                Special_Asset_Reason__c = 'Title',
                Severity_Level__c = 'Decision Required',
                Resolved_Date__c = System.today(),
                Resolution_Type__c = 'Sell REO',
                REO_Date__c = System.today()
            ));
        }

        insert sas;
   }

   @isTest
   public static void testForeclousreTrigger() {
    Foreclosure__c fc = new Foreclosure__c();

    List<Special_Asset__c> sas = [SELECT Id, Property__c, REO_Date__c FROM Special_Asset__c];

    fc.Special_Asset__c = sas[0].Id;
    fc.Property__c = sas[0].Property__c;

    insert fc;

    fc = [SELECT Id, REO_Date__c, Special_Asset__c FROM Foreclosure__c WHERE Id = :fc.Id];

    System.assertEquals(sas[0].REO_Date__c, fc.REO_Date__c, 'REO dates should match.');

    fc.REO_Date__c = System.today().addDays(-1);

    update fc;

    Special_Asset__c sa = [SELECT REO_Date__c FROM Special_Asset__c WHERE Id = :fc.Special_Asset__c];

    System.assertEquals(fc.REO_Date__c, sa.REO_Date__c, 'REO Dates should still match');


   }
}
@isTest
public with sharing class REOHelperTest {
    @TestSetup
    static void makeData(){
        Test_Helper.createDealLoanNumber();
        Account a = Test_Helper.createAccount();
        Contact c = Test_Helper.createContact(a);
        Opportunity o = Test_Helper.createBridgeDeal(a, c);
        List<Property__c> props = Test_Helper.createProperties(o);
    }

    @isTest
    public static void testReoTrigger() {
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];
        REO__c reo = new REO__c(
            Property__c = prop.Id
        );

        insert reo;

        Property__c updatedProp = [SELECT REO__c FROM Property__c WHERE Id = :prop.Id];

        System.assertEquals(reo.Id, updatedProp.REO__c, 'REO Id should be assigned to REO__c field on property.');
    }
}
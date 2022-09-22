@isTest
public with sharing class PropertyExtensionHelperTests {
    @testSetup
    static void makeData(){
        Test_Helper.createDealLoanNumber();
        Account a = Test_Helper.createAccount();
        Contact c = Test_Helper.createContact(a);
        Opportunity o = Test_Helper.createOpportunity(a, c);

        List<Property__c> props = Test_Helper.createProperties(o);
    }
    @isTest
    public static void testPropExtension() {
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];

        Property_Extension__c pe = new Property_Extension__c(
            Property__c = prop.Id,
            Extension_Date__c = System.today()
        );

        insert pe;

        Property_Extension__c newPe = new Property_Extension__c(
            Property__c = prop.Id
        );

        insert newPe;


        List<Property_Extension__c> propExts = new List<Property_Extension__c>{
            new Property_Extension__c(
                Id = newPe.Id,
                Extension_Date__c = System.today()
            ),
            new Property_Extension__c(
            Id = pe.Id,
            Extension_Date__c = System.today().addDays(-1)
             )
        };

        update propExts;
    }
}
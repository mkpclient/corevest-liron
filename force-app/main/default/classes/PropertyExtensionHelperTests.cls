@isTest
public with sharing class PropertyExtensionHelperTests {
    @testSetup
    static void makeData(){
        Test_Helper.createDealLoanNumber();
        Test_Helper.createRate();
        Test_Helper.setupProduct2();
        Account a = Test_Helper.createAccount();
        Contact c = Test_Helper.createContact(a);
        Opportunity o = Test_Helper.createOpportunity(a, c);

        List<Property__c> props = Test_Helper.createProperties(o);
    }
    @isTest
    public static void testPropExtension() {
        Property__c prop = [SELECT Id, Deal__c FROM Property__c LIMIT 1];

        Property_Extension__c pe = new Property_Extension__c(
            Property__c = prop.Id,
            Extension_Date__c = System.today()
        );

        for(String f : PropertyExtensionHelper.FIELDS_FOR_DEAL) {
            pe.put(f, Math.random() * 20);
        }
        Test.startTest();
        insert pe;

        String oppQuery = 'SELECT Id,' + String.join(PropertyExtensionHelper.FIELDS_FOR_DEAL, ',') + ' FROM Opportunity WHERE Id=\'' + prop.Deal__c + '\'';
        Opportunity opp = Database.query(oppQuery);

        for(String f : PropertyExtensionHelper.FIELDS_FOR_DEAL) {
            System.assertEquals(pe.get(f), opp.get(f), f + ' should have been updated on the deal level.');
            pe.put(f, Math.random() * 20);
        }

        update pe;

        Opportunity newOpp = Database.query(oppQuery);

        for(String f : PropertyExtensionHelper.FIELDS_FOR_DEAL) {
            System.assertEquals(pe.get(f), newOpp.get(f), f + ' should have been updated on the deal level.');
        }


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
        Test.stopTest();
    }
}
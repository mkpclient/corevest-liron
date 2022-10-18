@isTest
public with sharing class AdvanceICEmailControllerTests {
    @TestSetup
    static void makeData(){
        Test_Helper.createDealLoanNumber();
        Account a = Test_Helper.createAccount();
        Contact c = Test_Helper.createContact(a);
        Opportunity deal = Test_Helper.createBridgeDeal(a, c);
        List<Property__c> props = Test_Helper.createProperties(deal);
    }

    @isTest
    public static void unitTest1() {
        Property__c prop = [SELECT Id, Deal__c FROM Property__c LIMIT 1];

        Advance__c adv = new Advance__c(Deal__c = prop.Deal__c);
        insert adv;

        Property_Advance__c pAdv = new Property_Advance__c(Advance__c = adv.Id, Property__c = prop.Id);

        insert pAdv;

        AdvanceICEmailController controller = new AdvanceICEmailController();
        controller.recordId = adv.Id;
        
        Advance__c ctAdv = controller.advance;
        String refiAcq = controller.refiAcquisition;
    }
}

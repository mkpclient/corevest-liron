@isTest
public with sharing class UpdateCloseDateBatchTest {
    @TestSetup
    static void makeData(){
        Test_Helper.createDealLoanNumber();

        Account a = Test_Helper.createAccount();
        Contact c = Test_Helper.createContact(a);
        Opportunity o = Test_Helper.createOpportunity(a, c);
        Opportunity loc = Test_Helper.createLOCDeal(a, c);
        Opportunity sab = Test_Helper.createSABDeal(a, c);
    }

    @isTest
    public static void testTerm() {
        Test.startTest();
        Database.executeBatch(new UpdateCloseDateBatch('Term'));
        Test.stopTest();
    }

    @isTest
    public static void testBridge() {
        Test.startTest();
        Database.executeBatch(new UpdateCloseDateBatch('Bridge'));
        Test.stopTest();
    }
}
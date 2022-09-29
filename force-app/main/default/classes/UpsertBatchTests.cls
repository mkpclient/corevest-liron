@isTest
public with sharing class UpsertBatchTests {
    @isTest
    public static void testUpsertBatch() {
        Account a = Test_Helper.createAccount();
        Contact c = Test_Helper.createContact(a);
        

        c.FirstName = 'NewName';

        Test.startTest();
        Database.executeBatch(new UpsertBatch(new List<SObject>{c}), 100);
        Test.stopTest();

        Contact ct = [SELECT Id, FirstName FROM Contact WHERE Id = : c.Id];

        System.assertEquals('NewName', ct.FirstName);
    }
}
@isTest
public with sharing class securitizationHelperTest {
    @isTest
    public static void testMethod1() {
        Account testAcc = Test_Helper.createBrokerAccount();
        Contact testCtc = Test_Helper.createContact(testAcc);
        Opportunity testDeal = Test_Helper.createTermDeal(testAcc, testCtc);
        testDeal.Securitization__c = null;
        update testDeal;

        Securitization__c testSc = Test_Helper.createSecuritization(); 
        Funding_Vehicle__c testFv = [SELECT Id FROM Funding_Vehicle__c WHERE Securitization__c = :testSc.Id];
        testDeal.Securitized__c = true;
        testDeal.Securitization__c = testSc.Id;

        Test.startTest();
        update testDeal;
        Test.stopTest();


        testSc.Status__c = 'Redeemed';
        testSc.Close_Date__c = (Date) system.today();

        update testSc;

        Opportunity returnedDeal = [SELECT Securitization__c, Securitized__c FROM Opportunity WHERE Id = :testDeal.Id LIMIT 1];
        
    }
}
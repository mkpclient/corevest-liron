@isTest
private class SABDealMemoExtensionTest {

    @testSetup static void setup(){
        
    }

    static TestMethod void testMethod1(){
        Test.startTest();
        test_Helper.createDealLoanNumber();
        Account acc = test_Helper.createAccount();
        Contact cont = test_Helper.createContact( acc );
        Opportunity deal = test_Helper.createOpportunity( acc, cont );
        
        ApexPages.StandardController sc = new ApexPages.StandardController(deal);
        SABDealMemoExtension SABDealMemoExtensionInstance = new SABDealMemoExtension(sc);
        
        PageReference pageRef = Page.SABDealMemo;
        pageRef.getParameters().put('id', String.valueOf(deal.Id));
        Test.setCurrentPage(pageRef);
        Test.stopTest();
    }     
}
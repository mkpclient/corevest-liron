@isTest
private class InsuranceReserveCalcTests {
    static TestMethod void lightning_Tests_UnitTest(){
        Test_Helper.createRate();
        test_Helper.createDealLoanNumber();
        Account acc = test_Helper.createAccount();
        Contact cont = test_Helper.createContact( acc );
        Opportunity opp = test_Helper.createOpportunity( acc, cont );
        opp.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Term_Loan' and sobjecttype = 'Opportunity'].Id;
        List<Property__c> properties = test_Helper.createProperties(opp);

        Test.startTest();
            PageReference testpage = Page.InsuranceReserveCalculator;
            testPage.getParameters().put('id', opp.Id);

            InsuranceReserveCalcExtension ext = new InsuranceReserveCalcExtension(new ApexPages.StandardController(opp));

            InsuranceReserveCalcExtension.getDeal(opp.Id);

        Test.stopTest();
    }
}
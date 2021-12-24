@isTest
private class ScheduleOfLenderCostControllerTest {

    static TestMethod void testMethod1(){
        Account acc = test_Helper.createAccount();
        Contact cont = test_Helper.createContact( acc );
        Opportunity opp = test_Helper.createOpportunity( acc, cont );
        opp.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Term_Loan' and sobjecttype = 'Opportunity'].Id;
        List<Property__c> properties = test_Helper.createProperties(opp);
		
		Loan_Fee__c Loan_Fee=new Loan_Fee__c
		(
			Deal__c=opp.Id,
			Fee_Amount__c=1000,
			Reference__c='121212',
			vendor__c=acc.Id
		);

        Test.startTest();
            ScheduleOfLenderCostController obj=new ScheduleOfLenderCostController();
			obj.filtersJSON='{"dealId":"0060a00000ZIMlrAAH","fundingDate2":"2018-03-31","originationfeepercentage":0,"yearSwapRate":0,"installmentcomment":"1111111111","creditSpread":0,"InterestRateTermSheet":0,"InterestRateRateLock":0,"stubInterestDayCount":11,"debtreserve":null,"stubInterest":"10694.37","CorevestProceeds":"5539010.13","cfcorevestpurchaser":"2","taxentry":"11","TotalSources":"5620350.00","totalLender":"81339.87","capexentry":"11","insuranceentry":"11","tax":"0.92","capex":"0.92","totalthirdparty":63000,"insurence":"0.92","totalreserves":33,"netproceedstoborrower":5475977.13,"totaluses":5620350,"reservetax":"1","totalreservetax":"11.00","totalreserveinsurance":"11.00","totalreservecapex":"11.00","rateType":"2","reserveinsurance":"1","reservecapex":"1","titlewiringinstructions":"1111111111111"}';
			obj.getData();
			
			ScheduleOfLenderCostController.getUrlAndInstance();
			ScheduleOfLenderCostController.getDealLoanFees(opp.Id);
			ScheduleOfLenderCostController.saveDealData(opp);
			
			List<sobject> sobjects= Database.query('select id from Loan_Fee__c');
			ScheduleOfLenderCostController.upsertRecords(sobjects);
			ScheduleOfLenderCostController.deleteRecords(sobjects);
        Test.stopTest();
    }

}
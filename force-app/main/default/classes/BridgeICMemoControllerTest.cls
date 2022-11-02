@isTest
private class BridgeICMemoControllerTest {

    static TestMethod void testMethod1(){
        test_Helper.createDealLoanNumber();
        Account acc = test_Helper.createAccount();
        Contact cont = test_Helper.createContact( acc );
        Opportunity opp = test_Helper.createOpportunity( acc, cont );
        opp.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'LOC_Loan' and sobjecttype = 'Opportunity'].Id;
        List<Property__c> properties = test_Helper.createProperties(opp);
		
		Loan_Fee__c Loan_Fee=new Loan_Fee__c
		(
			Deal__c=opp.Id,
			Fee_Amount__c=1000,
			Reference__c='121212',
			vendor__c=acc.Id
		);

        Test.startTest();
            BridgeICMemoController obj=new BridgeICMemoController();
			obj.filtersJSON='{"dealId":"'+opp.Id+'","fundingDate2":"2018-03-31","originationfeepercentage":0,"yearSwapRate":0,"installmentcomment":"1111111111","creditSpread":0,"InterestRateTermSheet":0,"InterestRateRateLock":0,"stubInterestDayCount":11,"debtreserve":null,"stubInterest":"10694.37","CorevestProceeds":"5539010.13","cfcorevestpurchaser":"2","taxentry":"11","TotalSources":"5620350.00","totalLender":"81339.87","capexentry":"11","insuranceentry":"11","tax":"0.92","capex":"0.92","totalthirdparty":63000,"insurence":"0.92","totalreserves":33,"netproceedstoborrower":5475977.13,"totaluses":5620350,"reservetax":"1","totalreservetax":"11.00","totalreserveinsurance":"11.00","totalreservecapex":"11.00","rateType":"2","reserveinsurance":"1","reservecapex":"1","titlewiringinstructions":"1111111111111"}';
			obj.getData();
			BridgeICMemoController.getUrlAndInstance();
        Test.stopTest();
    }
    
    static TestMethod void testMethodSuccess(){
        test_Helper.createDealLoanNumber();
        Account acc = test_Helper.createAccount();
        Contact cont = test_Helper.createContact( acc );
        Opportunity opp = test_Helper.createOpportunity( acc, cont );
        opp.Active_States__c='California;Richmond';
        update opp;
        opp.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'LOC_Loan' and sobjecttype = 'Opportunity'].Id;
        
        insert new deal_contact__c(deal__c=opp.Id, Contact__c=cont.Id, entity_type__c ='Sponsor');
        insert new deal_contact__c(deal__c=opp.Id, Contact__c=cont.Id, entity_type__c ='Guarantor');
        List<Property__c> properties = test_Helper.createProperties(opp);
		Loan_Fee__c Loan_Fee=new Loan_Fee__c
		(
			Deal__c=opp.Id,
			Fee_Amount__c=1000,
			Reference__c='121212',
			vendor__c=acc.Id
		);

        Test.startTest();
            BridgeICMemoController obj=new BridgeICMemoController();
			obj.filtersJSON='{"dealId":"'+opp.Id+'","fundingDate2":"2018-03-31","originationfeepercentage":0,"yearSwapRate":0,"installmentcomment":"1111111111","creditSpread":0,"InterestRateTermSheet":0,"InterestRateRateLock":0,"stubInterestDayCount":11,"debtreserve":null,"stubInterest":"10694.37","CorevestProceeds":"5539010.13","cfcorevestpurchaser":"2","taxentry":"11","TotalSources":"5620350.00","totalLender":"81339.87","capexentry":"11","insuranceentry":"11","tax":"0.92","capex":"0.92","totalthirdparty":63000,"insurence":"0.92","totalreserves":33,"netproceedstoborrower":5475977.13,"totaluses":5620350,"reservetax":"1","totalreservetax":"11.00","totalreserveinsurance":"11.00","totalreservecapex":"11.00","rateType":"2","reserveinsurance":"1","reservecapex":"1","titlewiringinstructions":"1111111111111"}';
			obj.getData();
        	BridgeICMemoController.getData(opp.Id);
			BridgeICMemoController.getUrlAndInstance();
        Test.stopTest();
    }
    
    static TestMethod void testMethodFail(){
        Test.startTest();
        BridgeICMemoController obj=new BridgeICMemoController();
        obj.filtersJSON='{"dealId":"1234","fundingDate2":"2018-03-31","originationfeepercentage":0,"yearSwapRate":0,"installmentcomment":"1111111111","creditSpread":0,"InterestRateTermSheet":0,"InterestRateRateLock":0,"stubInterestDayCount":11,"debtreserve":null,"stubInterest":"10694.37","CorevestProceeds":"5539010.13","cfcorevestpurchaser":"2","taxentry":"11","TotalSources":"5620350.00","totalLender":"81339.87","capexentry":"11","insuranceentry":"11","tax":"0.92","capex":"0.92","totalthirdparty":63000,"insurence":"0.92","totalreserves":33,"netproceedstoborrower":5475977.13,"totaluses":5620350,"reservetax":"1","totalreservetax":"11.00","totalreserveinsurance":"11.00","totalreservecapex":"11.00","rateType":"2","reserveinsurance":"1","reservecapex":"1","titlewiringinstructions":"1111111111111"}';
        obj.getData();
        
        BridgeICMemoController.WrapperData wd=new BridgeICMemoController.WrapperData();
            
        wd.annualincomeyear='1000';
        wd.annualincome='1000';
        wd.repeatborrower='1000';
        wd.recourse='1000';
        wd.glcapproveddate='1000';
        wd.fundedborrower='1000';
        wd.deliquencyhistory='1000';
        wd.valuepsf='1000';
        wd.valueperunit='1000';
        wd.sponsorcostpsf='1000';
        wd.sponsorcpu='1000';
        wd.loanpsf='1000';
        wd.loanperunit='1000';
        
        Test.stopTest();
    }
}
@isTest
private class pres_Tests {

    //static List<Account> testAccounts = testDataFactory.createTestRecords(new Account[10]);

    static TestMethod void pres_Extension_UnitTest(){
        
        Test.startTest();

        List<PRES_Settings__c> settings = test_Helper.createCustomSettings();
		List<Integration_Mapping__c> ims = test_Helper.createIntegrationMappings();

		Account acc = test_Helper.createAccount();
		Contact cont = test_Helper.createContact( acc );
		Opportunity opp = test_Helper.createOpportunity( acc, cont );

		ApexPages.StandardController sc = new ApexPages.StandardController( opp );
		pres_Extension ext = new pres_Extension( sc );
		ext.sendToPres();
		ext.getLocLoanRequestString(opp);

        Test.stopTest();
    }

    static TestMethod void pres_Webservice_UnitTest(){
        
        Test.startTest();

        // Insert variables
		List<PRES_Settings__c> settings = test_Helper.createCustomSettings();
		List<Integration_Mapping__c> mappings = test_Helper.createIntegrationMappings();
		Account acc = test_Helper.createAccount();
		Contact con = test_Helper.createContact( acc );
		Opportunity opp = test_Helper.createOpportunity( acc, con );

		// Test the Webservice method
		RestRequest restReq = new RestRequest();
		RestResponse restRes = new RestResponse();
		restReq.requestURI = '/services/apexrest/test';
		restReq.httpMethod = 'POST';
		restReq.requestBody = Blob.valueOf('{"ObjectName" : "TermLoan","KeyField" : "Id","data" : [ {"Id" : "' + opp.Id + '","AccountName" : "0011100000wbgapAAA","AssetMaturity" : null,"CloseDate" : "2015-07-29","isPrivate" : true,"DepositAmount" : null,"DepositCollected" : null,"Fee" : null,"FundingStatus" : null,"LoanSize" : 5.0,"LOCExtension" : "None","LOCLoanType" : null,"LOCTerm" : null,"LTC" : null,"LTV" : null,"OpportunityName" : "MKP Barry 2 Deal 1","OpportunityOwner" : "005j0000000bPgPAAU","OpportunityRecordType" : "012j0000000WA15AAG","OtherRate" : null,"Rate" : null,"Stage" : "Term Sheet Issued","TermSheetIssued" : null,"TermSheetSigned" : null,"PresDealId" : "123","PresId" : "2272"}]}');
		restRes.responseBody = Blob.valueOf('{"ObjectName" : "TermLoan","KeyField" : "Id","data" : [ {"Id" : "' + opp.Id + '","AccountName" : "0011100000wbgapAAA","AssetMaturity" : null,"CloseDate" : "2015-07-29","isPrivate" : true,"DepositAmount" : null,"DepositCollected" : null,"Fee" : null,"FundingStatus" : null,"LoanSize" : 5.0,"LOCExtension" : "None","LOCLoanType" : null,"LOCTerm" : null,"LTC" : null,"LTV" : null,"OpportunityName" : "MKP Barry 2 Deal 1","OpportunityOwner" : "005j0000000bPgPAAU","OpportunityRecordType" : "012j0000000WA15AAG","OtherRate" : null,"Rate" : null,"Stage" : "Term Sheet Issued","TermSheetIssued" : null,"TermSheetSigned" : null,"PresDealId" : "123","PresId" : "2272"}]}');
		RestContext.request = restReq;
		RestContext.response = restRes;
		SObject bodyMap = pres_Webservice.preciseRE();

        Test.stopTest();
    }

}
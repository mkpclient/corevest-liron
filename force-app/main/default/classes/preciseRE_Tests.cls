@isTest
private class preciseRE_Tests {
	
	static testmethod void preciseRE_API_UnitTest() {

		Test.startTest();

		// Insert variables
		//List<IntegrationSetting__c> settings = test_Helper.createCustomSettings();
		//List<Integration_Mapping__c> mappings = test_Helper.createIntegrationMappings();
		//Account acc = test_Helper.createAccount();
		//Contact con = test_Helper.createContact( acc );
		//Opportunity opp = test_Helper.createOpportunity( acc, con );

		//// Test the Webservice method
		//RestRequest restReq = new RestRequest();
		//RestResponse restRes = new RestResponse();
		//restReq.requestURI = '/services/apexrest/test';
		//restReq.httpMethod = 'POST';
		//restReq.requestBody = Blob.valueOf('{"ObjectName" : "Opportunity","KeyField" : "Id","data" : [ {"Id" : "' + opp.Id + '","AccountName" : "0011100000wbgapAAA","AssetMaturity" : null,"CloseDate" : "2015-07-29","isPrivate" : true,"DepositAmount" : null,"DepositCollected" : null,"Fee" : null,"FundingStatus" : null,"LoanSize" : 5.0,"LOCExtension" : "None","LOCLoanType" : null,"LOCTerm" : null,"LTC" : null,"LTV" : null,"OpportunityName" : "MKP Barry 2 Deal 1","OpportunityOwner" : "005j0000000bPgPAAU","OpportunityRecordType" : "012j0000000WA15AAG","OtherRate" : null,"Rate" : null,"Stage" : "Term Sheet Issued","TermSheetIssued" : null,"TermSheetSigned" : null,"PresDealId" : null,"PresId" : "2272"}]}');
		//RestContext.request = restReq;
		//RestContext.response = restRes;
		

		//// Test other methods
		//preciseRE_API.constructReqeust('test', 'POST', 'test');
		//preciseRE_API.createIntegrationLog('req', 'res', 'pres');		
		//util.getActiveMappingsForObject('Opportunity');
		preciseRE_API api = new preciseRE_API();
		SObject bodyMap = preciseRE_API.preciseRE();

		Test.stopTest();
	}
}
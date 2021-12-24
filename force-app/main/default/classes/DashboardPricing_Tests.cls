@isTest
private class DashboardPricing_Tests {

    static TestMethod void DashboardPricing_LightningController_UnitTest(){
        Account acc = test_Helper.createAccount();
        Contact cont = test_Helper.createContact( acc );
        Opportunity opp = test_Helper.createOpportunity( acc, cont );
        
        // Code Added By Trivikram : Start
        Id termLoanRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Term Loan').getRecordTypeId();
        Id bridgeLoanRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Bridge Loan').getRecordTypeId();
        
        opp.RecordTypeId = termLoanRecordTypeId;
        opp.LOC_Program_Type__c = 'Custom';
        opp.Approved_Term_Sheet_Name__c = null;
        update opp;
        
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(opp.Id);
        Approval.ProcessResult result = Approval.process(req);
        Id processInstanceId = result.getInstanceId();
        // Code Added By Trivikram : End
        
        Approval_History__c testApprovalHistory = new Approval_History__c();
        testApprovalHistory.Process_Id__c = userInfo.getUserId();
        testApprovalHistory.Parent_Status__c = 'Pending';
        testApprovalHistory.Deal__c = opp.Id;
        testApprovalHistory.Process_Instance_Id__c = processInstanceId; // Code Added By Trivikram 
        insert testApprovalHistory;

        Test.startTest();
        DashboardPricing_LightningController.returnApprovals();

        DashboardPricing_LightningController.ahWrapper ahWrapper = new DashboardPricing_LightningController.ahWrapper();
        ahWrapper.oppName = 'Test';
        ahWrapper.lmd = system.now();
        ahWrapper.processStatus = 'Test';
        ahWrapper.processInstance = 'Test';

        DashboardPricing_LightningController.returnWRapper returnWrapper = new DashboardPricing_LightningController.returnWRapper(userInfo.getUserId(), new List<DashboardPricing_LightningController.ahWrapper>());

        Test.stopTest();
    }

}
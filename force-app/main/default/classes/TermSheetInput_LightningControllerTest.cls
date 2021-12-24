/**
* @author MK Partners, Inc.
* @date 2017-12-14
* @group
* @description  Tests for Term Sheet Input Lightning Controller
**/
@isTest
private class TermSheetInput_LightningControllerTest {

    static testMethod void testTermSheet() {
        Account acc = test_Helper.createAccount();
        Contact cont = test_Helper.createContact( acc );
        Opportunity opp = test_Helper.createOpportunity( acc, cont );
        List<Id> ver = new List<Id> {Approval_TestDataFactory.createCv().Id, Approval_TestDataFactory.createCv().Id};
        List<String> dateString = new List<String> {'2017', '01', '09'};
        ContentVersion cv = Approval_TestDataFactory.createCv();
        ContentDocumentLink cdl = Approval_TestDataFactory.createCdl(cv.ContentDocumentId, opp.Id);
        Date d = Date.today();
        List<Boolean> bList = new List<Boolean> {true, true, true};
        Test.startTest();
        TermSheetInput_LightningController.queryContentDocLink(cdl.Id);
        TermSheetInput_LightningController.queryContentVersion(ver);
        TermSheetInput_LightningController.findRecordType(opp.Id);
        TermSheetInput_LightningController.queryOpportunity(opp.Id);
        String term = TermSheetInput_LightningController.stringTerm('/apex/TermSheetDoc?id=', opp.Id, dateString);
        PageReference p = new PageReference(term);
        TermSheetInput_LightningController.updateIfLocLoan(opp, bList, d);
        TermSheetInput_LightningController.updateIfTermLoan(opp, bList, d);
        // TermSheetInput_LightningController.createContent(3, opp, 'Term Loan', p, false);
        
        // Code Start : Trivikram 
        TermSheetInput_LightningController.queryDealDocument(opp.Id);
        
        String termLoanString = '/apex/TermSheetDoc?id=';
        Integer i = 1;
        List<String> splitDate = String.valueOf(system.today()).split('-');
        String strBlobData = 'test';
        String recordType = 'LOC_Loan';
        
        String docReference = TermSheetInput_LightningController.stringTerm(termLoanString, opp.Id, splitDate, i, strBlobData);
        PageReference p2 = new PageReference(docReference);
        TermSheetInput_LightningController.createContent(i, opp, recordType, p2, true);
        //String myJSON = JSON.serialize(opp);  
        String myJSON = '{"Id" : "' + opp.Id + '",';
        myJSON = myJSON + '"Term_Sheet_Expiration_Date__c" : "' + String.valueOf(system.today()) + '",';
        myJSON = myJSON + '"Negotiated_by_Counsel__c" : ""' + ',';
        myJSON = myJSON + '"Include_3_Months_Min_Interest__c" : ""' + ',';
        myJSON = myJSON + '"Generate_Word_Doc" : "true"' + ',';
        myJSON = myJSON + '"LOC_Loan_Type__c " : "Commercial"';
        
        myJSON = myJSON + '}';  
        TermSheetInput_LightningController.generateSheet(myJSON,recordType);
        // Code End : Trivikram 
        
        Test.stopTest();
    }
}
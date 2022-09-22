@isTest
private class TermSheetBypassControllerTest {    
    static TestMethod void testMethod1(){
        test_Helper.createDealLoanNumber();
        Account acc = test_Helper.createAccount();
        Contact cont = test_Helper.createContact( acc );
        Opportunity deal = test_Helper.createOpportunity( acc, cont );
           
        ContentVersion contentVersionRecord = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersionRecord;
        Id docId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionRecord.Id LIMIT 1].ContentDocumentId;
        List<Id> listDocumentId = new List<Id>();
        listDocumentId.add(docId);
        
        
        Attachment att=new Attachment(ParentId=deal.Id, Name = 'Test', Body = Blob.valueOf('Test Data'));
        insert att;
        
        Deal_Document__c termSheet=new Deal_Document__c(
            ContentVersion_Id__c=contentVersionRecord.Id,
            Attachment_Id__c=att.Id,
            Type__c = 'Term Sheet',
            File_Name__c='Penguins.pdf',
            Document_Loaded__c=true,
            Deal__c=deal.Id,
            Is_Deleted__c=false
        );
        insert termSheet;
        
        Test.startTest();
        TermSheetBypassController.createAttachmentFromCV(contentVersionRecord.Id);
        TermSheetBypassController.returnDeal(deal.Id);
        TermSheetBypassController.bypassDeal(deal.Id);
        
        Test.stopTest();
    }
    
    static TestMethod void testMethod2(){
        test_Helper.createDealLoanNumber();
        Account acc = test_Helper.createAccount();
        Contact cont = test_Helper.createContact( acc );
        Opportunity deal = test_Helper.createOpportunity( acc, cont );
           
        ContentVersion contentVersionRecord = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersionRecord;
        Id docId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionRecord.Id LIMIT 1].ContentDocumentId;
        List<Id> listDocumentId = new List<Id>();
        listDocumentId.add(docId);
        
        Test.startTest();
        try{
            TermSheetBypassController.createAttachmentFromCV(contentVersionRecord.Id);
            TermSheetBypassController.returnDeal(deal.Id);
            TermSheetBypassController.bypassDeal(deal.Id);
        }catch(exception e){}
        
        Test.stopTest();
    }
}
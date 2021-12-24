@isTest
private class UploadFile_LightningControllerTest {

    @testSetup static void setup(){
        
    }

    static TestMethod void testMethod1(){
        Test.startTest();
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
        String dealId = deal.Id;
        UploadFile_LightningController.createDealDocuments(listDocumentId,dealId);
        Test.stopTest();
    }     
}
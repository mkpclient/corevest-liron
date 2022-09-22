@isTest
class ContentDocumentLinkArchiverHandlerTest{

    @isTest
    private static void testUpdateDealDocumentWithArchivedFiles(){
        

test_Helper.createDealLoanNumber();
        
        Account dealAccount = new Account(
             Name='Test'
         );
         insert dealAccount;
         
         Contact dealContact = new Contact(
             FirstName='Test', 
             LastName='Test', 
             AccountId=dealAccount.Id
         );
         insert dealContact;
         
         Opportunity deal = New Opportunity(
             Contact__c=dealContact.Id, 
             CloseDate=Date.Today(), 
             AccountId=dealAccount.Id, 
             Name='Test', 
             StageName='Initial Review');
         insert deal;
         
         Deal_Document__c dealDocument = new Deal_Document__c(
             Deal__c=deal.Id
         );
             insert dealDocument;
        
      
         ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = blob.valueof('Test Content Data')     
        );
        insert cv;
        
            ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
             ContentDocumentLink contentlink=new ContentDocumentLink();
             contentlink.LinkedEntityId=dealDocument.id;  
             contentlink.ShareType= 'I';               
             contentlink.ContentDocumentId=documents[0].Id;
             contentlink.Visibility = 'AllUsers'; 
             insert contentlink;
             System.assertEquals(documents.size(), 1);
             
             delete documents;
             
            Deal_Document__c  dealDocumentAfterUpdate = [Select Id, Document_Archived_By_OwnBackup__c From Deal_Document__c Where Id=:dealDocument.id Limit 1][0];
            System.assertEquals(dealDocumentAfterUpdate.Document_Archived_By_OwnBackup__c, true);
        
        
           

    }
   

}
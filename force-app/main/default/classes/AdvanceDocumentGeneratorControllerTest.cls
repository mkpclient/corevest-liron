@isTest
private class AdvanceDocumentGeneratorControllerTest {
  static testMethod void test1() {
    
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact( acc );
    Opportunity deal = test_Helper.createOpportunity( acc, cont );
       
    ContentVersion contentVersion = new ContentVersion(
      Title = 'Penguins',
      PathOnClient = 'Penguins.jpg',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    insert contentVersion;
        
    ContentDocument conD=[select id from ContentDocument limit 1];
    String subject = 'Test Subject';
    String emailBody = 'Test Email Body';
    List<String> listAttributes = new List<String>();
    listAttributes.add(conD.id);
      
    Test.startTest();
        
        Id fileId = AdvanceDocumentGeneratorController.saveChunk(deal.Id, 'TestFileName', 'base64Data', 'pdf', '', false, 'test@gmail.com', 'testcc@gmail.com', 'testcc@gmail.com',subject,emailBody,listAttributes);
        
        AdvanceDocumentGeneratorController.saveChunk(deal.Id, 'TestFileName', 'base64Data', 'pdf', fileId, false, 'test@gmail.com', 'testcc@gmail.com', 'testcc@gmail.com',subject,emailBody,listAttributes);
        try{
            AdvanceDocumentGeneratorController.saveChunk(deal.Id, 'TestFileName', 'base64Data', 'pdf', fileId, true, 'test@gmail.com', 'testcc@gmail.com', 'testcc@gmail.com',subject,emailBody,listAttributes);
        }
      catch(exception e){}
        
        AdvanceDocumentGeneratorController.deleteFile(new List<String>{conD.id});
        
        //to throw exception
        AdvanceDocumentGeneratorController.deleteFile(new List<String>{conD.id});
    Test.stopTest();
  }
    
    
    
}
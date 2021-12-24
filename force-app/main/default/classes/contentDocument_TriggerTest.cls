@isTest
private class contentDocument_TriggerTest {    
    static TestMethod void testMethod1(){
        Test.startTest();         
        ContentVersion contentVersionRecord = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersionRecord;
        
        delete [select id from contentdocument];
        
        Test.stopTest();
    }
}
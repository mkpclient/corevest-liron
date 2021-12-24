@isTest
private with sharing class DocumentInformationHelperTests {
    static TestMethod void ut(){
        Account acc = test_Helper.createAccount();
        Contact cont = test_Helper.createContact( acc );
        Opportunity opp = test_Helper.createOpportunity( acc, cont );
        User u = setupVendor();
        insert new Deal_Contact__c(Account__c = acc.Id, Deal__c = opp.Id, Contact__c = u.ContactId, Entity_Type__c='Portal Access');

        Test.startTest();
            Document_Information__c docInfo = new Document_Information__c(Deal__c = opp.Id, Doc_String__c = 'Loan Document;Title Policies|Miscellaneous');
            insert docInfo;

            docInfo.Doc_String__c = 'Loan Document;Title Policies|Miscellaneous';
            docInfo.External_Comments__c = 'test';

            update docInfo;

        Test.stopTest();


    }

    private static User setupVendor(){
        Id p = [SELECT Id FROM Profile WHERE Name = 'Vendor Portal User'].Id;
        Id recordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Vendor' LIMIT 1].Id;
        Account ac = new Account(name ='Grazitti') ;
        ac.RecordTypeId = recordType;
        insert ac; 
       
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Email = 'test@example.com');
        insert con;
        User user = new User(alias = 'test123', email='test@example.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        return user;
    }
}
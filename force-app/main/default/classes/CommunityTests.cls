@isTest
private class CommunityTests {
    // @TestSetup
    // static void makeData(){
    //   Account acc = test_Helper.createAccount();
    //     Contact cont = test_Helper.createContact( acc );
    // }

    static TestMethod void BorrowerTests(){
        User u = setupBorrower();
        Id i = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Id propertyId = [SELECT Id FROM Property__c LIMIT 1].Id;
        Opportunity testOpportunity = [SELECT id,RecordType__c from Opportunity Limit 1];
        test.startTest();
        system.runAs(u){
            CommunityController.getRelationshipManager();
            CommunityController.getDealMembers(i);
            CommunityController.checkAccess(propertyId);
            RecordDetailsController.getCommunityDetails(i);
            
            //Code Added by Trivikram : Start
            CommunityController.getRecordType(propertyId);
            CommunityController.getDealInfo(testOpportunity.Id);
            CommunityController.getPortalUser();
            Contact testContact = CommunityController.getContactDetails();
            CommunityController.getUnderwriter(testOpportunity.RecordType__c);
            
            try {
                Task testTaskForException = new Task();
                CommunityController.submitRequest(testContact,testTaskForException);
            }
            catch(Exception ex) {
                system.debug('Exception >>>>>> '+ex);
            }
            
            //Code Added by Trivikram : End
        }
        
        test.stopTest();
      
    }

    static TestMethod void VendorTests(){
        User u = setupVendor();
        Id i = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Id propertyId = [SELECT Id FROM Property__c LIMIT 1].Id;
        test.startTest();
        system.runAs(u){
            CommunityController.getRelationshipManager();
            CommunityController.getDealMembers(i);
            CommunityController.checkAccess(propertyId);
            RecordDetailsController.getCommunityDetails(i);
        }
        
        test.stopTest();
      
    }

    // static TestMethod void Test2(){
    //     UserResource u = new UserResource()
    // }

    private static User setupBorrower(){
        Id p = [select id from profile where name='Customer Portal User'].id;

        Account ac = new Account(name ='Grazitti') ;
        insert ac; 
       
        Contact con = new Contact(FirstName = 'test',LastName ='testCon',AccountId = ac.Id);
        insert con;

        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;


test_Helper.createDealLoanNumber();
        Opportunity opp = test_Helper.createOpportunity( ac, con );
        insert new Deal_Contact__c(Account__c = ac.Id, Deal__c = opp.Id);
        insert new Deal_Contact__c(Account__c = ac.Id, Deal__c = opp.Id);
        opp.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Term_Loan' and sobjecttype = 'Opportunity'].Id;
        List<Property__c> properties = test_Helper.createProperties(opp);

        return user; 
    }

    private static User setupVendor(){
        Id p = [SELECT Id FROM Profile WHERE Name = 'Vendor Portal User'].Id;
        Id recordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Vendor' LIMIT 1].Id;
        Account ac = new Account(name ='Grazitti') ;
        ac.RecordTypeId = recordType;
        insert ac; 
       
        Contact con = new Contact(FirstName = 'test',LastName ='testCon',AccountId = ac.Id);
        insert con;

        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;


test_Helper.createDealLoanNumber();
        Opportunity opp = test_Helper.createOpportunity( ac, con );
        insert new Deal_Contact__c(Account__c = ac.Id, Deal__c = opp.Id);
        insert new Deal_Contact__c(Account__c = ac.Id, Deal__c = opp.Id);
        opp.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Term_Loan' and sobjecttype = 'Opportunity'].Id;
        List<Property__c> properties = test_Helper.createProperties(opp);

        return user;
    }

}
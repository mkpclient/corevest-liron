@isTest
private class contact_Tests {

    //static List<Account> testAccounts = testDataFactory.createTestRecords(new Account[10]);

    static TestMethod void contact_Tests_UnitTest(){
        List<User> users = [SELECT Id FROM User];
        Lead l = new Lead(FirstName='Test', LastName='Tester',
            Requested_Loan_Size__c=500, Company='Tester', Introduction_Source__c = 'CAF Website', Email='none@gmail.com');

        insert l;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setDoNotCreateOpportunity(true);
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Lead convertedLead = [SELECT Id, ConvertedContactId FROM Lead WHERE Id = : l.Id];
        Contact c = [SELECT Id, OwnerId FROM Contact WHERE Id = : convertedLead.ConvertedContactId];

        Test.startTest();
            if(c.OwnerId != users[0].Id){
                c.OwnerId = users[0].Id;
            }else{
                c.OwnerId = users[1].Id;
            }

            update c;
        Test.stopTest();

       // Lead updatedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = : l.Id];
        //system.assertEquals(c.OwnerId, updatedLead.OwnerId);
    }
    
    static TestMethod void contact_Tests_UnitTest2(){
        account acc = new account();
        acc.name = 'test123';
        acc.Site = 'California';
        insert acc;
        contact con = new contact();
        con.FirstName = 'testfirst';
        con.LastName = 'testlast';
        con.AccountId = acc.id;
        insert con;
        con.In_Litigation__c = true;
        update con;
        account acc2 = new account();
        acc2.name = 'test456';
        acc2.Site = 'California';
        insert acc2;
        con.AccountId = acc2.Id;
        update con;
        delete con;
    }
       
          
}
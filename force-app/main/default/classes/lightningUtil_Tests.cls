@isTest
private class lightningUtil_Tests {

    @testSetup static void setup(){
        test_Helper.createDealLoanNumber();
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i, BillingCountry = 'United States', BillingState='California',Phone='1122334455'));
        }
        insert testAccts; 

        Contact cont = test_Helper.createContact( testAccts[0] );
        Opportunity opp = test_Helper.createOpportunity( testAccts[0], cont );
    }

    static TestMethod void queryTests(){
        String queryString = 'SELECT Id FROM Account';
        Test.startTest();
        List<sObject> records = lightning_Util.query(queryString);
        lightning_Util.queryJSON(queryString);
        Test.stopTest();
        system.assertEquals(records.size(), 2);
        
        // Code Added By Trivikram : Start
        lightning_Util.getPicklistValues('Opportunity','Lender__c');
        lightning_Util.TPicklistEntry picklistEntryInstance = new lightning_Util.TPicklistEntry();
        picklistEntryInstance.active = 'true';
        picklistEntryInstance.defaultValue = 'test';
        picklistEntryInstance.value = 'test';
        // Code Added By Trivikram : End
    }

    static TestMethod void upsertTests(){
        List<sobject> accounts = database.query('select id,Name,Phone from account');
        
        // Code Added By Trivikram : Start
        List<sobject> listTestAccount = new List<sobject>();
        Account testAccount2 =  (Account)accounts[1];
        testAccount2.Name = 'TestAcct0';
        testAccount2.BillingCountry = 'United States';
        testAccount2.BillingState = 'California';
        testAccount2.Phone = '1122334455';
        
        listTestAccount.add(testAccount2);
        listTestAccount.add(new Account(Name = 'Test'));
        listTestAccount.add(new Account(Name = 'TestAcct0',BillingCountry = 'United States', BillingState='California',Phone='1122334455'));

        Test.startTest();
        try {
            List<sObject> records = lightning_Util.upsertRecords(listTestAccount);
        }
        catch(Exception ex) {
        
        }
        // Code Added By Trivikram : End
        Test.stopTest();
    }

    static TestMethod void deleteTests(){
        List<Account> accs = [SELECT Id FROM Account];
        Contact cont = test_Helper.createContact( accs[0] );
        Test.startTest();
        lightning_Util.deleteRecords(new List<Contact>{cont});
        Test.stopTest();
        // List<sObject> records = database.query('select id from account');
        // system.assertEquals(records.size(), 1);
        
        // Code Added By Trivikram : Start
        try {
            lightning_Util.deleteRecords(new List<sObject>{new Account(Name = 'Test')} );
        }
        catch(Exception ex) {
            
        }
        // Code Added By Trivikram : End
    }

    static TestMethod void queryTest(){
        String sObjectType = 'Account';
        String whereClause = 'WHERE Id != null';
        String orderBy = 'ORDER BY CreatedDate';
        String lim = 'LIMIT 10';
        List<String> fields = new List<String>{'Id', 'Name'};
        Test.startTest();
        List<sObject> records = lightning_Util.queryRecords(sobjectType, whereClause, OrderBy, lim, fields);
        Test.stopTest();
        system.assertEquals(records.size(), 2);
    }

    static testmethod void userTest(){
        Test.startTest();
        lightning_Util.getUserId();
        lightning_Util.getUser();
        lightning_Util.getDependentOptions('Deal_Document__c', 'Type__c', 'Section__c');
        Test.stopTest();
    }

    static testmethod void getFileTest(){
        Test.startTest();
        lightning_util.getFileFromStaticResource('AdvanceDocuments', 'test');
        Test.stopTest();
    }
    static testmethod void getAppnameTypeTest(){
           Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
           //lightning_util.getAppName();
           lightning_util.getType(opp.id);
       
    }

    static testMethod void testCreateDealDocs() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Id> oppIds = new List<Id>{opp.Id};

        lightning_Util.createDealDocumentsFromFile(oppIds, 'test', 'test.txt', 'test');
    }


}
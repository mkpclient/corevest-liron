@isTest
private class TradeTests {

    static testmethod void tradeTest1(){
        RecordType r = [SELECT Id FROM RecordType WHERE DeveloperName = 'Correspondent_Bridge' LIMIT 1];
        Account a = new Account(Name='Test Account', RecordTypeId = r.Id, BillingCountry = 'United States', BillingState = 'California');
        insert a;
        
        Trade__C t1 = new Trade__c(Correspondent__c = a.Id );
        insert t1;

        Test.startTest();
        
        Trade__C t = new Trade__c(Correspondent__c = a.Id );
        insert t;

        List<Trade_Deal__c> deals = new List<Trade_Deal__c>();
        for(Integer i = 0; i < 5; i++){
            Trade_Deal__c deal = new Trade_Deal__c();
            deal.Address__c = i + ' St';
            deal.State__c = 'CA';
            deal.Trade__c = t.Id;
            deals.add(deal);
        }

        insert deals;

        t.Status__c = 'Completed';
        update t;
        
        update deals;

        t.Status__c = 'Pending';
        update t;
        
        delete deals;

        update t;
        
        delete t;
        
        undelete t;
        
        Test.stopTest();
    }
    
    static testmethod void tradeTest2(){
        RecordType r = [SELECT Id FROM RecordType WHERE DeveloperName = 'Correspondent_Bridge' LIMIT 1];
        Account a = new Account(Name='Test Account', RecordTypeId = r.Id, BillingCountry = 'United States', BillingState = 'California');
        insert a;
        
        Trade__C t1 = new Trade__c(Correspondent__c = a.Id );
        insert t1;

        Test.startTest();
        
        Trade__C t = new Trade__c(Correspondent__c = a.Id );
        insert t;

        List<Trade_Deal__c> deals = new List<Trade_Deal__c>();
        for(Integer i = 0; i < 5; i++){
            Trade_Deal__c deal = new Trade_Deal__c();
            deal.Address__c = i + ' St';
            deal.State__c = 'CA';
            deal.Trade__c = t.Id;
            deals.add(deal);
        }
        insert deals;

        t.Status__c = 'Completed';
        update t;
        
        update deals;

        try{
            delete deals;
        }catch(exception e){}
        
        delete t;
        undelete t;
        
        Test.stopTest();
    }

}
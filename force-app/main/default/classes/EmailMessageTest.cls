@isTest

private class EmailMessageTest {
    
    static TestMethod void EmailMessageTest(){
    	Account acc = test_Helper.createAccount();
    	Contact cont = test_Helper.createContact( acc );
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.id;
        opp.Contact__c = cont.id;
        opp.CloseDate = date.today();
        opp.StageName = 'Initial Review';
        insert opp;
            
     EmailMessage em = new EmailMessage();
        em.RelatedToId = opp.id;
        em.Subject = 'Kick-off';
        insert em;
        
        }

    static TestMethod void EmailMessageTest2(){
            Account acc = test_Helper.createAccount();
            Contact cont = test_Helper.createContact( acc );
            
            Opportunity opp = new Opportunity();
            opp.Name = 'test';
            opp.AccountId = acc.id;
            opp.Contact__c = cont.id;
            opp.CloseDate = date.today();
            opp.StageName = 'Initial Review';
            insert opp;
                
            Property__c property = new Property__c();
            property.Name='Test1';
            property.Deal__c = opp.Id;
            property.Escrow_Company_text__c = 'ESCROW';
            property.Insurance_Company_text__c = 'INSURANCE';
            property.Status__c = 'Pending';
            property.Override_Origination_Fee__c = 1000;
            property.RecordTypeId = [SELECT Id FROM RecordType WHERE sobjecttype = 'Property__c' and DeveloperName = 'Bridge_No_Renovation'].Id;
            
    
            insert property;


         EmailMessage em = new EmailMessage();
            em.RelatedToId = property.id;
            em.Subject = 'Title Review Email';
            em.HtmlBody = 'Title Company: test \n Title Contact Name: test \n Appraisal Order Date: today';
            insert em;
            
            }
    
        static TestMethod void EmailMessageTest3(){
            Account acc = test_Helper.createAccount();
            Contact cont = test_Helper.createContact( acc );
            
            Opportunity opp = new Opportunity();
            opp.Name = 'test';
            opp.AccountId = acc.id;
            opp.Contact__c = cont.id;
            opp.CloseDate = date.today();
            opp.StageName = 'Initial Review';
            insert opp;
                
            advance__c adv = new advance__c();
            adv.Name='Test1';
            adv.Deal__c = opp.Id;
            adv.RecordTypeId = [SELECT Id FROM RecordType WHERE sobjecttype = 'Advance__c' and DeveloperName = 'Renovation_Initial'].Id;
            
    
            insert adv;


         EmailMessage em = new EmailMessage();
            em.RelatedToId = adv.id;
            em.Subject = 'Funding Conditions -';
            insert em;
            
            }
}
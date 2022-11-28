@isTest

private class TaskTriggerTest {
    
    static TestMethod void TaskTriggerTest(){

    	Account acc = test_Helper.createAccount();
    	Contact cont = test_Helper.createContact( acc );
    	task t = new task();
    	t.Subject = 'test';
        t.WhoId = cont.id;
       	
        insert t;
        
        contact con = new contact();
        con.FirstName = 'test';
        con.LastName = 'testlast';
        con.AccountId = acc.id;
        
        insert con;
        
        
        lead l = new lead();
        l.FirstName = 'test';
        l.LastName = 'testlast';
        l.Company = 'testcompany';
        l.Introduction_Source__c = 'Email Blast';
     
        insert l;
        
        task t2 = new task();
    	t2.Subject = 'test';
        t2.WhoId = l.id;
        
        insert t2;
        
        task t3 = new task();
    	t3.Subject = 'test';
        t3.Description='Test Descr';
    	Id id1 = [
          SELECT Id
          FROM RecordType
          WHERE sobjecttype = 'Task' AND DeveloperName = 'Draw_Request'
        ]
        .Id;
        t3.RecordTypeId = id1;  
        insert t3;
        
        t3.WhoId = l.Id;
        t3.Status = 'Completed';
        
        update t3;

       t3.WhoId = null;
        update t3;

        
            }
    static TestMethod void TaskTriggerEmailTest(){

        	Account acc = test_Helper.createAccount();
    	Contact cont = test_Helper.createContact( acc );
            
            cont.email = 'testemail@testemail.com';
            update cont;
            system.debug('contemail' + cont.Email);

        contact con = new contact();
        con.FirstName = 'test';
        con.LastName = 'testlast';
        con.Email = 'testing@test.com';
        con.AccountId = acc.id;
        
        insert con;
            
        contact co = new contact();
        co.FirstName = 'test12';
        co.LastName = 'testlast123';
        co.Email = 'testing1@test.com';
        co.AccountId = acc.id;
        
        insert co;
            
    	task t = new task();
    	t.Subject = 'test';
        t.WhoId = cont.id;
        t.Description = 'To: '+cont.Email+'; '+con.Email+'; '+co.Email+' CC:';

        t.Type = 'Email';
        t.TaskSubtype = 'Email';
        t.Priority = 'Normal';
        insert t;
            
        system.debug('emailbody'+t.Description);
        system.debug('type'+t.Type);



        }
}
@isTest
public class CreateSourceFromLeadBatchTest{
	
	@testSetup static void methodName() {
		Lead_Settings__c setting = new Lead_Settings__c(Name='CAF Website', Round_Robin_Max__c = 6, Round_Robin_Value__c = 1);
        insert setting;
        
        Lead l = new Lead(FirstName = 'Test1', LastName = 'Tester',
               Company='Test Company1', Email = 'test111@test.com', Phone = '5555555555', MobilePhone = '5555555555', 
               Introduction_Source__c = 'Event',OwnerId = UserInfo.getUserId());
        Lead l2 = new Lead(FirstName = 'Test2', LastName = 'Tester1', Company='None',Email = 'test222@test.com',
                  Introduction_Source__c = 'Event',OwnerId = UserInfo.getUserId());

        Lead l3 = new Lead(FirstName = 'Test3', LastName = 'Tester3', email = 'test@tester.com',
               Company='Test Company3',
               Introduction_Source__c = 'Event',OwnerId = UserInfo.getUserId());

        List<Lead> leads = new List<Lead>{l};
        insert leads;
        
        Lead testLead4 = new Lead(FirstName = 'Test4', LastName = 'Tester',
               Company='Test Company', Email = 'test111@test.com',
               Introduction_Source__c = 'Event',OwnerId = UserInfo.getUserId());
        insert testLead4;
        testLead4.Phone = '6666666666';
        testLead4.MobilePhone = 'Call: 88888888888888888888';
        testLead4.Status = 'Unqualified';
        testLead4.Disposition__c = 'Low Fico';
        update testLead4;
        
        delete [SELECT id from Master_Source__c LIMIT 10];
        delete [SELECT id from Source__c  LIMIT 10];
	}
	
	static TestMethod void lead_Tests_UnitTest(){
		Test.startTest();
		Database.executeBatch(new CreateSourceFromLeadBatch(),100);
        Test.stopTest();
	}
}
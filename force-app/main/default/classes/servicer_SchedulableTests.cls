@isTest
private class servicer_SchedulableTests {

    //static List<Account> testAccounts = testDataFactory.createTestRecords(new Account[10]);

    static TestMethod void servicer_SchedulableTests_UnitTest(){
        Test.startTest();
        	new servicer_schedulable().execute(null);
        Test.stopTest();
    }

}
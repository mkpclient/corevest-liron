@isTest
private class DebugProcessBuilderTest {

    @testSetup static void setup(){
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            testAccts.add(new Account(Name = 'TestAcct'+i, BillingCountry = 'United States', BillingState='California',Phone='1122334455'));
        }
        insert testAccts; 
    }

    static TestMethod void testMethod1(){
        Test.startTest();
        debugProcessBuilder.processBuilderDebug();
        Test.stopTest();
        
    }    
}
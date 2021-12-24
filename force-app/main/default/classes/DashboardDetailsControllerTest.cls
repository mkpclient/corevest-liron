@isTest
private class DashboardDetailsControllerTest {
	static testMethod void test1() {
		
		Account acc = test_Helper.createAccount();
		Contact cont = test_Helper.createContact( acc );
		Opportunity deal = test_Helper.createOpportunity( acc, cont );
		//deal.Display_Dashboard__c=true;
        
		Test.startTest();
        System.debug('deal.Id--> '+deal.Id);
		//DashboardDetailsController.updateDashboardDisplay(deal.Id);
		//DashboardDetailsController.getDashboardDisplay(deal.Id);
		Test.stopTest();
	}
    
    static testMethod void test2() {
		
		Account acc = test_Helper.createAccount();
		Contact cont = test_Helper.createContact( acc );
		Opportunity deal = test_Helper.createOpportunity( acc, cont );
	//	deal.Display_Dashboard__c=false;
        
		Test.startTest();
        System.debug('deal.Id--> '+deal.Id);
		//DashboardDetailsController.updateDashboardDisplay(deal.Id);
		//DashboardDetailsController.getDashboardDisplay(deal.Id);
		Test.stopTest();
	}
    
}
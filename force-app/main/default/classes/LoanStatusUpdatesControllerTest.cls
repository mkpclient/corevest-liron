@isTest
private class LoanStatusUpdatesControllerTest {
    
     static TestMethod void testMethod1(){
         Account acc = test_Helper.createAccount();
		Contact cont = test_Helper.createContact( acc );
		Opportunity opp = test_Helper.createOpportunity( acc, cont );
         
      //  List<Loan_Status__c> Loanlist = new List<Loan_Status__c>();
        Loan_Status__c Ls= new Loan_Status__c( Subject__c='Test', Comment__c='Test', deal__c= opp.Id);
         insert ls;
         test.startTest();
         LoanStatusUpdatesController.getRecord(opp.Id);
         LoanStatusUpdatesController.deleteRecord(ls.Id,opp.Id);
         test.stopTest();
        
                
    }
}
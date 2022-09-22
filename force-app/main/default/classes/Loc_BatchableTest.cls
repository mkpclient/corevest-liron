@isTest
private class Loc_BatchableTest {
  @testSetup
  static void setup() {
    List<Account> testAccts = new List<Account>();
    for (Integer i = 0; i < 2; i++) {
      testAccts.add(
        new Account(
          Name = 'TestAcct' + i,
          BillingCountry = 'United States',
          BillingState = 'California',
          Phone = '1122334455'
        )
      );
    }
    //insert testAccts;
  }

  static testMethod void testMethod1() {
    test_Helper.createDealLoanNumber();
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);

    Id termLoanRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Bridge Loan')
      .getRecordTypeId();
    opp.RecordTypeId = termLoanRecordTypeId;
    update opp;
    opp.IC_Approval_Date__c = System.today() - 5;
    opp.StageName = 'Closed Won';
    opp.Loan_Effective_Date__c = System.today() - 5;
    opp.Advance_Period__c = 3;
    opp.LOC_Term__c = '12 Months';
    update opp;

    Test.startTest();
    loc_Batchable.reschedule(10);
    List<String> listTestOpportunityId = new List<String>();
    listTestOpportunityId.add(opp.Id);
    loc_Batchable.processIds(listTestOpportunityId);
    Database.executeBatch(new loc_Batchable());
    Test.stopTest();
  }
}
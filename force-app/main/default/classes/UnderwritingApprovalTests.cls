@isTest
private class UnderwritingApprovalTests {
  @isTest(SeeAllData=true)
  static void UnderwritingApprovalTests_UnitTest() {
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    opp.StageName = 'Term Sheet Signed/Deposit Collected';
    update opp;
    Opportunity opp2 = test_Helper.createOpportunity(acc, cont);
    Test.startTest();
    UNderwritingApproval_LightningController.validateRecord(opp.Id);

    UnderWritingApproval_LightningController.startApproval(
      'comments',
      (String) opp2.Id,
      'Term_Loan'
    );

    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void UnderwritingApprovalTests_UnitTest2() {
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    opp.StageName = 'Term Sheet Signed/Deposit Collected';
    opp.RecordTypeId = opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    ]
    .Id;
    update opp;
    Opportunity opp2 = test_Helper.createOpportunity(acc, cont);
    Test.startTest();
    UNderwritingApproval_LightningController.validateRecord(opp.Id);

    UnderwritingApproval_LightningController.startApproval(
      'comments',
      (String) opp.Id,
      'LOC_Loan'
    );

    Test.stopTest();
  }
}
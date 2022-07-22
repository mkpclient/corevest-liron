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

  @isTest(SeeAllData=true)
  static void UnderwritingApprovalTests_UnitTest3() {
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    cont.MailingPostalCode = '11111';
    cont.Email = 'test@cvest.com';
    cont.MailingStreet = '111 test rd';
    cont.MailingCity = 'Testville';
    update cont;
    Opportunity opp = test_Helper.createOpportunity(acc, cont);
    opp.StageName = 'Term Sheet Signed/Deposit Collected';
    opp.RecordTypeId = opp.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE sobjecttype = 'Opportunity' AND DeveloperName = 'LOC_Loan'
    ]
    .Id;
    opp.Deposit_Amount__c = 100000;
    opp.Deposit_Collected__c = System.today();
    opp.Deposit_Fed_Reference__c = 'fsdf';
    opp.Term_Sheet_Issued__c = System.today();
    opp.Term_Sheet_Signed__c = System.today();
    opp.Foreign_National_picklist__c = 'No';
    update opp;
    List<Deal_Document__c> dealDocs = new List<Deal_Document__c>{new Deal_Document__c(
      Document_Loaded__c = true,
      Is_Deleted__c = false,
      Deal__c = opp.Id,
      Document_Type__c = 'Executed Term Sheet'
    ), new Deal_Document__c(
      Document_Loaded__c = true,
      Is_Deleted__c = false,
      Deal__c = opp.Id,
      Document_Type__c = 'Credit Report'
    )};
    insert dealDocs;

    Opportunity opp2 = test_Helper.createOpportunity(acc, cont);
    Test.startTest();
    String resp = UnderwritingApproval_LightningController.validateRecord(opp.Id);
    System.debug(resp);
    UnderwritingApproval_LightningController.startApproval(
      'comments',
      (String) opp.Id,
      'LOC_Loan'
    );

    Test.stopTest();
  }
}
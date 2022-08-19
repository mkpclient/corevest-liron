@isTest
public with sharing class BatchApprovalHelperTests {
  @TestSetup
  static void makeData() {
    Test_Helper.createDealLoanNumber();
    Account a = Test_Helper.createAccount();
    Contact c = Test_Helper.createContact(a);
    Opportunity o = Test_Helper.createOpportunity(a, c);
    List<Property__c> props = Test_Helper.createProperties(o);
    Advance__c adv = new Advance__c(Deal__c = o.Id);
    insert adv;

  }

  @isTest
  public static void testBatchRejection() {
    Batch_Approval__c ba = new Batch_Approval__c(Initial_Comments__c = 'test comments');
    insert ba;

    Advance__c adv = [SELECT Id, Batch_Approval__c from Advance__c LIMIT 1];

    adv.Batch_Approval__c = ba.Id;
    update adv;

    Attachment att = new Attachment(
        ParentId = ba.Id,
        Body = Blob.valueOf('test'),
        Name = 'test.csv',
        ContentType = 'text/csv'
    );

    insert att;
    ba.AttachmentPosted__c = true;

    Test.startTest();
    update ba;

    Batch_Approver__c approver = [SELECT Id, Status__c, Comments__c FROM Batch_Approver__c LIMIT 1];
    approver.Comments__c = 'test reject';
    approver.Status__c = 'Rejected';
    update approver;
    Test.stopTest();

    Batch_Approval__c baResult = [SELECT Approval_Status__c FROM Batch_Approval__c];
    System.assertEquals('Rejected', baResult.Approval_Status__c, 'Status should have been updated to rejected');
    
  }

  @isTest
  public static void testBatchApproval() {
    Batch_Approval__c ba = new Batch_Approval__c(Initial_Comments__c = 'test comments');
    insert ba;

    Advance__c adv = [SELECT Id, Batch_Approval__c from Advance__c LIMIT 1];

    adv.Batch_Approval__c = ba.Id;
    update adv;

    Attachment att = new Attachment(
        ParentId = ba.Id,
        Body = Blob.valueOf('test'),
        Name = 'test.csv',
        ContentType = 'text/csv'
    );

    insert att;
    ba.AttachmentPosted__c = true;

    Test.startTest();
    update ba;

    List<Batch_Approver__c> approvers = [SELECT Id, Status__c, Comments__c FROM Batch_Approver__c];
    for(Batch_Approver__c ap : approvers) {
        ap.Status__c = 'Approved';
    }
    update approvers;
    Test.stopTest();

    Batch_Approval__c baResult = [SELECT Approval_Status__c FROM Batch_Approval__c];
    System.assertEquals('Approved', baResult.Approval_Status__c, 'Status should have been updated to approved');
    
  }
}

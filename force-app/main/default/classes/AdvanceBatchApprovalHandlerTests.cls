@isTest
public with sharing class AdvanceBatchApprovalHandlerTests {
  @TestSetup
  static void makeData() {
    Test_Helper.createDealLoanNumber();
    Account a = Test_Helper.createAccount();
    Contact c = Test_Helper.createContact(a);
    Opportunity o = Test_Helper.createOpportunity(a, c);
    List<Property__c> props = Test_Helper.createProperties(o);
    Advance__c adv = new Advance__c(Deal__c = o.Id);
    insert adv;
    Batch_Approval__c ba = new Batch_Approval__c(Initial_Comments__c = 'test comments');
    insert ba;

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

    update ba;

    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    User u = new User(Alias = 'owner', Email='testowner@cvest.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testowner@cvest.com');

    insert u;

    ba.OwnerId = u.Id;
    ba.Submitted_By__c = u.Id;
    update ba;
   
    List<Email_Addresses__c> settings = new List<Email_Addresses__c>{
        new Email_Addresses__c(
          Email_Address__c = UserInfo.getUserEmail(),
          Value__c = UserInfo.getUserEmail(),
          Approver_Code__c = 'ApprovedMK',
          Name =  UserInfo.getFirstName() + ' ' + UserInfo.getLastName()
        )
      };
  
      insert settings;
  }


  @isTest
  public static void testEmailhandlerSubmission(){
    Batch_Approval__c ba = [SELECT Id, Name FROM Batch_Approval__c LIMIT 1];
    List<Batch_Approver__c> bApprovers = [SELECT Id, Approver__c FROM Batch_Approver__c];

    Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
    h.Name = 'Test';
    h.Value = '      1   1 2000';
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    email.headers = new List<Messaging.InboundEmail.Header>();
    email.headers.add(h);
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

    email.subject = 'Subject subject #' + ba.Name;
    email.fromAddress = 'testowner@cvest.com';
    email.plainTextBody = 'test body';
    email.htmlBody = '<p>testbody</p>';

    email.toAddresses = new List<String>{UserInfo.getUserEmail()};

    AdvanceBatchApprovalEmailHandler cls = new AdvanceBatchApprovalEmailHandler();
    cls.handleInboundEmail(email, env);
  }

  @isTest
  public static void testEmailhandlerApproval(){
    Batch_Approval__c ba = [SELECT Id, Name FROM Batch_Approval__c LIMIT 1];
    List<Batch_Approver__c> bApprovers = [SELECT Id, Approver__c FROM Batch_Approver__c];

    Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
    h.Name = 'Test';
    h.Value = '      1   1 2000';
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    email.headers = new List<Messaging.InboundEmail.Header>();
    email.headers.add(h);
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

    email.subject = 'Subject subject #' + ba.Name;
    email.fromAddress = UserInfo.getUserEmail();
    email.plainTextBody = 'ApprovedMK test';

    email.toAddresses = new List<String>{'testowner@cvest.com'};

    Test.startTest();
    AdvanceBatchApprovalEmailHandler cls = new AdvanceBatchApprovalEmailHandler();
    cls.handleInboundEmail(email, env);
    Test.stopTest();
  }
}

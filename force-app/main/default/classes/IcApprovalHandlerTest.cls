@isTest
private class IcApprovalHandlerTest {
  static testMethod void IcApprovalHandlerTest_UnitTest() {
    Test_helper.setupProduct2();
    Account acc = test_Helper.createAccount();
    Contact cont = test_Helper.createContact(acc);
    Opportunity deal = test_Helper.createOpportunity(acc, cont);
    Contentversion cv = new Contentversion();
    cv.Title = 'test.pdf';
    cv.PathOnClient = 'test.pdf';
    cv.VersionData = EncodingUtil.base64Decode(
      EncodingUtil.urlEncode('Unit Test Attachment Body', 'UTF-8')
    );
    insert cv;
    Id docId = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cv.Id
      LIMIT 1
    ]
    .ContentDocumentId;
    Deal_Document__c doc = new Deal_Document__c(
      Deal__c = deal.Id,
      Document_Type__c = 'Draft IC Memo',
      ContentVersion_Id__c = cv.Id,
      Attachment_Id__c = docId,
      File_Name__c = 'test.pdf'
    );

    insert doc;
    Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
    h.Name = 'Test';
    h.Value = '      1   1 2000';
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    email.headers = new List<Messaging.InboundEmail.Header>();
    email.headers.add(h);
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

    email.subject = 'Create Contact';
    email.fromAddress = UserInfo.getUserEmail();
    email.plainTextBody = 'email body\n2225256325\nTitle';
    String body = '<wbr>';
    body += '--DEALIDSTART--' + deal.id + '--DEALIDEND--';
    body += '--CONTENTIDSTART--' + cv.Id + '--CONTENTIDEND--';
    body += 'CoreVest American Finance Lender LLC. All Rights Reserved.';
    email.htmlBody = body;

    Test.startTest();
    email.toAddresses = new List<String>{ 'test@test.com' };
    Approval_History__c appHis = new Approval_History__c(
      ProcessName__c = 'Bridge IC Process',
      Approval_Type__c = 'IC Memo',
      Status__c = 'Submitted',
      Deal__c = deal.Id
    );
    insert appHis;
    icApprovalHandler cls = new icApprovalHandler();
    cls.handleInboundEmail(email, env);
    icApprovalHandler.postToChatter(deal, 'test');

    Messaging.InboundEmail.TextAttachment t = new Messaging.InboundEmail.TextAttachment();
    t.fileName = 'Test';
    t.mimeTypeSubType = 'Test';
    t.body = 'Test';
    icApprovalHandler.constructFileAttachment(t);

    Messaging.InboundEmail.BinaryAttachment b = new Messaging.InboundEmail.BinaryAttachment();
    b.fileName = 'Test';
    b.mimeTypeSubType = 'Test';
    b.body = blob.valueOf('Test');
    icApprovalHandler.constructFileAttachment(b);

    icApprovalHandler.queryContentVersions(
      new List<Id>{ UserInfo.getUserId() }
    );
    icApprovalHandler.sendReply(deal.Id, UserInfo.getUserId());
    icApprovalHandler.createAttachment(email, deal);

    email.fromAddress = 'fakeFromAddress@fakeDomain.com.ua';
    cls.handleInboundEmail(email, env);

    List<Id> listTestUserid = new List<Id>();
    listTestUserid.add(UserInfo.getUserId());

    icApprovalHandler.createEmailHistory(
      email,
      deal,
      new List<String>{ UserInfo.getUserEmail() },
      new List<String>{ UserInfo.getUserEmail() },
      listTestUserid,
      UserInfo.getUserId(),
      true
    );

    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setObjectId(deal.Id);
    req.setNextApproverIds(new List<Id>{ UserInfo.getUserId() });
    Approval.ProcessResult result = Approval.process(req);
    List<Id> newWorkItemIds = result.getNewWorkitemIds();
    // Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
    // req2.setComments('Approving request.');
    // req2.setAction('Approve');
    // req2.setNextApproverIds(new List<Id>{ UserInfo.getUserId() }); //UserInfo.getUserId()
    // system.debug('req2::' + req2);
    // // Use the ID from the newly created item to specify the item to be worked
    // req2.setWorkitemId(newWorkItemIds.get(0));
    // system.debug('req3::' + req2);
    // Submit the request for approval
    // Approval.ProcessResult result2 = Approval.process(req2);
    List<ProcessInstanceWorkItem> wrkItem = [
      SELECT
        Id,
        ProcessInstance.TargetObjectId,
        ProcessInstance.Status,
        ActorId,
        Actor.Name,
        OriginalActorId,
        ProcessInstanceId,
        ProcessInstance.ProcessDefinition.DeveloperName,
        CreatedDate
      FROM ProcessInstanceWorkItem
      WHERE Id = :newWorkItemIds[0]
      LIMIT 1
    ];

    Approval_History__c appHis2 = new Approval_History__c(
      Actor__c = UserInfo.getUserId(),
      Process_Id__c = newWorkItemIds[0],
      Status__c = 'Pending',
      Comments__c = 'sdfsdf',
      Parent_Status__c = 'Pending',
      Process_Instance_Id__c = wrkItem[0].ProcessInstanceId,
      Deal__c = deal.Id
    );
    insert appHis2;

    icApprovalHandler.handleApproval(
      UserInfo.getUserId(),
      deal,
      wrkItem,
      'Test'
    );
    try {
      Account acct = new Account();

      insert acct;
    } catch (Exception err) {
      icApprovalHandler.sendExceptionEmails(err);
    }
    Test.stopTest();
  }
}
public without sharing class BatchApprovalHelper {
  public static final String APPROVER_GROUP = 'Advance_Batch_Approvers';
  public static final String RECIPIENT_GROUP = 'Advance_Batch_Additional_Recipients';
  public static final Map<String, String> TEMPLATE_MAP = new Map<String, String>{
    'submitted' => 'Advance_Batch_Submitted',
    'approved' => 'Advance_Batch_Approved',
    'rejected' => 'Advance_Batch_Rejected'
  };

  public static void beforeInsert(List<Batch_Approval__c> newList) {
    for (Batch_Approval__c ba : newList) {
      ba.Submitted_By__c = UserInfo.getUserId();
      ba.Week_Of__c = System.today().toStartOfWeek().addDays(1);
    }
  }

  public static void afterInsert(Map<Id, Batch_Approval__c> newMap) {
    createBatchApprovers(newMap.values());
  }

  public static void beforeUpdate(
    Map<Id, Batch_Approval__c> oldMap,
    Map<Id, Batch_Approval__c> newMap
  ) {
    for (Batch_Approval__c newBa : newMap.values()) {
      Batch_Approval__c oldBa = oldMap.get(newBa.Id);

      if (
        oldBa.Approval_Status__c != newBa.Approval_Status__c &&
        (newBa.Approval_Status__c == 'Rejected' ||
        newBa.Approval_Status__c == 'Approved')
      ) {
        newBa.Approved_Rejected_Date__c = System.today();
      }
    }
  }

  public static void afterUpdate(
    Map<Id, Batch_Approval__c> oldMap,
    Map<Id, Batch_Approval__c> newMap
  ) {
    Map<Id, Batch_Approval__c> rejectedBatches = new Map<Id, Batch_Approval__c>();
    Map<Id, Batch_Approval__c> approvedMap = new Map<Id, Batch_Approval__c>();
    Map<Id, Batch_Approval__c> submittedBatches = new Map<Id, Batch_Approval__c>();
    for (Batch_Approval__c newBa : newMap.values()) {
      Batch_Approval__c oldBa = oldMap.get(newBa.Id);

      if (
        newBa.Approval_Status__c != oldBa.Approval_Status__c &&
        newBa.Approval_Status__c == 'Rejected'
      ) {
        rejectedBatches.put(newBa.Id, newBa);
      }

      if (
        newBa.Approval_Status__c != oldBa.Approval_Status__c &&
        newBa.Approval_Status__c == 'Approved'
      ) {
        approvedMap.put(newBa.Id, newBa);
      }

      if (
        oldBa.AttachmentPosted__c != newBa.AttachmentPosted__c &&
        newBa.AttachmentPosted__c
      ) {
        submittedBatches.put(newBa.Id, newBa);
      }
    }

    if (rejectedBatches.size() > 0) {
      updateApprovalHistories(rejectedBatches.keySet(), 'Rejected');
      postApproveRejectChatter(rejectedBatches.keySet());
      updateNonResponse(rejectedBatches.keySet());
      sendEmail(rejectedBatches.values(), 'rejected');
    }

    if (approvedMap.size() > 0) {
      updateApprovalHistories(approvedMap.keySet(), 'Approved');
      postApproveRejectChatter(approvedMap.keySet());
      updateNonResponse(approvedMap.keySet());
      sendEmail(approvedMap.values(), 'approved');
    }

    if (submittedBatches.size() > 0) {
      aggregateAdvances(submittedBatches.keySet());
      sendEmail(submittedBatches.values(), 'submitted');
    }
  }

  public static void sendEmail(
    List<Batch_Approval__c> batchRecords,
    String type
  ) {
    Set<Id> sendTo = retrieveGroupMembers(
      new List<String>{ APPROVER_GROUP, RECIPIENT_GROUP }
    );
    String templateName = TEMPLATE_MAP.get(type);
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    Map<Id, Messaging.EmailFileAttachment> attachmentMap = new Map<Id, Messaging.EmailFileAttachment>();
    EmailTemplate temp = [
      SELECT Id, Body, HtmlValue, Subject
      FROM EmailTemplate
      WHERE DeveloperName = :templateName
    ];

    Contact dummyContact = new Contact();
    if (test.isRunningTest()) {
      dummyContact = [SELECT Id FROM Contact LIMIT 1];
    } else {
      dummyContact = [
        SELECT Id
        FROM Contact
        WHERE Account.Name LIKE 'inhouse test%' AND Email != NULL
        LIMIT 1
      ];
    }
    String handlerAddress = AdvanceBatchApprovalEmailHandler.retrieveEmailServiceAddress();
    for (Attachment file : [
      SELECT Id, Body, Name, ContentType, ParentId
      FROM Attachment
      WHERE ParentId IN :batchRecords AND ContentType LIKE '%csv%'
    ]) {
      Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
      efa.setFileName(file.Name);
      efa.setBody(file.Body);
      efa.setContentType(file.ContentType);
      attachmentMap.put(file.ParentId, efa);
    }

    for (Batch_Approval__c ba : batchRecords) {
      List<String> recipients = new List<String>();
      recipients.addAll(new List<Id>(sendTo));
      if (Test.isRunningTest() && !recipients.contains(UserInfo.getUserId())) {
        recipients.add(UserInfo.getUserId());
      }
      recipients.add(ba.Submitted_By__c);
      Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
      em.setToAddresses(recipients);
      em.setCcAddresses(new List<String>{ handlerAddress });
      em.setReplyTo(handlerAddress);
      em.setTargetObjectId(dummyContact.Id);
      em.setTemplateId(temp.Id);
      em.setWhatId(ba.Id);
      em.setSaveAsActivity(false);
      em.setTreatTargetObjectAsRecipient(false);
      if (attachmentMap.containsKey(ba.Id)) {
        em.setFileAttachments(
          new List<Messaging.EmailFileAttachment>{ attachmentMap.get(ba.Id) }
        );
      }
      emails.add(em);
    }

    List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails);

    for (Messaging.SendEmailResult r : results) {
      if (r.isSuccess()) {
        System.debug('Email success sent.');
        System.debug('Handler address: ' + handlerAddress);
      } else {
        for (Messaging.SendEmailError err : r.getErrors()) {
          System.debug('The following error has occurred.');
          System.debug(err.getStatusCode() + ': ' + err.getMessage());
          System.debug('fields that affected this error: ' + err.getFields());
        }
      }
    }
  }

  public static void postApproveRejectChatter(Set<Id> batchIds) {
    List<ConnectApi.BatchInput> feedElements = new List<ConnectApi.BatchInput>();
    String approvedMessage = 'This batch of advances has been approved by all approvers.';
    String rejectedMessage = 'This batch of advances has been rejected by ';
    for (Batch_Approval__c ba : [
      SELECT
        Id,
        Submitted_By__c,
        Approval_Status__c,
        (
          SELECT Id, Approver__c, Approver__r.Name, Status__c, Comments__c
          FROM Batch_Approvers__r
        )
      FROM Batch_Approval__c
      WHERE Id IN :batchIds
    ]) {
      List<Id> mentionIds = new List<Id>();
      mentionIds.add(ba.Submitted_By__c);
      String message = ba.Approval_Status__c == 'Approved'
        ? approvedMessage
        : rejectedMessage;

      if (ba.Batch_Approvers__r != null && ba.Batch_Approvers__r.size() > 0) {
        for (Batch_Approver__c bapp : ba.Batch_Approvers__r) {
          mentionIds.add(bapp.Approver__c);
          if (
            ba.Approval_Status__c == 'Rejected' &&
            bapp.Status__c == 'Rejected'
          ) {
            message +=
              bapp.Approver__r.Name +
              '\n Comment from Approver: ' +
              bapp.Comments__c;
          }
        }
      }

      feedElements.add(constructBatchChatterPost(message, ba.Id, mentionIds));
    }

    if (!test.isRunningTest()) {
      postChatterBatch(feedElements);
    }
  }

  @future
  public static void updateApprovalHistories(Set<Id> batchIds, String status) {
    List<Approval_History__c> appHistories = [
      SELECT Id, Status__c
      FROM Approval_History__c
      WHERE Status__c != :status AND Batch_Approval__c IN :batchIds
      FOR UPDATE
    ];

    for (Approval_History__c ah : appHistories) {
      ah.Status__c = status;
    }

    update appHistories;
  }

  public static void updateNonResponse(Set<Id> batchIds) {
    List<Batch_Approver__c> bApprovers = [
      SELECT Id, Status__c
      FROM Batch_Approver__c
      WHERE Batch_Approval__c IN :batchIds AND Status__c = 'Pending'
      FOR UPDATE
    ];

    for (Batch_Approver__c ba : bApprovers) {
      ba.Status__c = 'No Response';
    }

    if (bApprovers.size() > 0) {
      update bApprovers;
    }
  }

  public static void createBatchApprovers(List<Batch_Approval__c> batchIds) {
    List<Batch_Approver__c> approvers = new List<Batch_Approver__c>();
    Set<Id> apprIds = retrieveGroupMembers(new List<String>{ APPROVER_GROUP });
    List<ConnectApi.BatchInput> feedElements = new List<ConnectApi.BatchInput>();
    for (Batch_Approval__c b : batchIds) {
      for (Id a : apprIds) {
        Batch_Approver__c ba = new Batch_Approver__c();
        ba.Submitted_By__c = UserInfo.getUserId();
        ba.Status__c = 'Pending';
        ba.Approver__c = a;
        ba.Batch_Approval__c = b.Id;

        approvers.add(ba);
      }
      if (!apprIds.contains(UserInfo.getUserId()) && Test.isRunningTest()) {
        Batch_Approver__c ba = new Batch_Approver__c();
        ba.Submitted_By__c = UserInfo.getUserId();
        ba.Status__c = 'Pending';
        ba.Approver__c = UserInfo.getUserId();
        ba.Batch_Approval__c = b.Id;

        approvers.add(ba);
      }
      feedElements.add(
        constructBatchChatterPost(
          'A new batch of advances have entered approval and require your review.\n Submitter Comment: ' +
          b.Initial_Comments__c,
          b.Id,
          new List<Id>(apprIds)
        )
      );
    }

    insert approvers;

    if (!test.isRunningTest()) {
      postChatterBatch(feedElements);
    }
  }

  @future
  public static void aggregateAdvances(Set<Id> batchIds) {
    List<Batch_Approval__c> updBatchApprovals = new List<Batch_Approval__c>();

    for (AggregateResult ar : [
      SELECT
        Batch_Approval__c,
        Count(Id) advCount,
        Sum(Approved_Advance_Amount_Total__c) sumTotal
      FROM Advance__c
      WHERE Batch_Approval__c IN :batchIds
      GROUP BY Batch_Approval__c
    ]) {
      updBatchApprovals.add(
        new Batch_Approval__c(
          Id = (Id) ar.get('Batch_Approval__c'),
          No_of_Advances__c = (Decimal) ar.get('advCount'),
          Total_Funding__c = (Decimal) ar.get('sumTotal')
        )
      );
    }

    update updBatchApprovals;
    createApprovalHistories(batchIds);
  }

  public static void createApprovalHistories(Set<Id> batchIds) {
    Set<Id> apprIds = retrieveGroupMembers(new List<String>{ APPROVER_GROUP });
    List<Approval_History__c> appHistories = new List<Approval_History__c>();
    for (Advance__c adv : [
      SELECT Id, Batch_Approval__c, Batch_Approval__r.Initial_Comments__c
      FROM Advance__c
      WHERE Batch_Approval__c IN :batchIds
    ]) {
      appHistories.add(
        new Approval_History__c(
          Advance__c = adv.Id,
          Batch_Approval__c = adv.Batch_Approval__c,
          Comments__c = adv.Batch_Approval__r.Initial_Comments__c,
          Actor__c = UserInfo.getUserId(),
          Status__c = 'Submitted'
        )
      );

      for (Id aId : apprIds) {
        appHistories.add(
          new Approval_History__c(
            Advance__c = adv.Id,
            Batch_Approval__c = adv.Batch_Approval__c,
            Actor__c = aId,
            Status__c = 'Pending'
          )
        );
      }

      if (test.isRunningTest()) {
        appHistories.add(
          new Approval_History__c(
            Advance__c = adv.Id,
            Batch_Approval__c = adv.Batch_Approval__c,
            Actor__c = UserInfo.getUserId(),
            Status__c = 'Pending'
          )
        );
      }
    }

    insert appHistories;
  }

  public static Set<Id> retrieveGroupMembers(List<String> groupNames) {
    Set<Id> returnSet = new Map<Id, User>(
        [
          SELECT
            id,
            name,
            email,
            isactive,
            profile.name,
            userrole.name,
            usertype
          FROM user
          WHERE
            id IN (
              SELECT userorgroupid
              FROM groupmember
              WHERE group.DeveloperName IN :groupNames
            )
        ]
      )
      .keySet();

    return returnSet;
  }

  public static void postChatterBatch(
    List<ConnectApi.BatchInput> feedElements
  ) {
    ConnectApi.BatchResult[] results = ConnectApi.ChatterFeeds.postFeedElementBatch(
      Network.getNetworkId(),
      feedElements
    );
    for (ConnectApi.BatchResult r : results) {
      if (!r.isSuccess()) {
        System.debug(
          'Failed to insert chatter post with batch: ' + r.getErrorMessage()
        );
      }
    }
  }

  public static ConnectApi.BatchInput constructBatchChatterPost(
    String body,
    Id subjectId,
    List<Id> mentionIds
  ) {
    return new ConnectApi.BatchInput(
      constructChatterPost(body, subjectId, mentionIds)
    );
  }

  public static ConnectApi.FeedItemInput constructChatterPost(
    String body,
    Id subjectId,
    List<Id> mentionIds
  ) {
    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();

    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    if (mentionIds != null) {
      for (Id mentionId : mentionIds) {
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput.id = mentionId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = ' ';
        messageBodyInput.messageSegments.add(textSegmentInput);
      }
    }
    if (String.isNotBlank(body)) {
      ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
      textSegmentInput.text = body;
      messageBodyInput.messageSegments.add(textSegmentInput);
    }

    feedItemInput.body = messageBodyInput;
    feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
    feedItemInput.subjectId = subjectId;
    return feedItemInput;
  }
}

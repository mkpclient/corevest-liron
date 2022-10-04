public without sharing class BatchApprovalHelper {
  public static final Map<String,String> APPROVER_GROUP_MAP = new Map<String,String>{
    'Advance Batch Approval' => 'Advance_Batch_Approvers',
    'Advance IC Approval' => 'Advance_IC_Approvers'
  };

  public static final Map<String,String> CHATTER_MESSAGE_MAP = new Map<String,String>{
    'Advance_Batch_Approvers' => 'A new batch of advances have entered approval and require your review.\n Submitter Comment: ',
    'Advance_IC_Approvers' => 'This Advance has entered IC approval and requires your review. Submitter comment: '
  };

  public static final Map<String,String> RECIPIENT_GROUP_MAP = new Map<String,String>{
    'Advance Batch Approval' => 'Advance_Batch_Additional_Recipients'
  };

  

  public static final Map<String, String> TEMPLATE_MAP = new Map<String, String>{
    'submittedBatch' => 'Advance_Batch_Submitted',
    'approvedBatch' => 'Advance_Batch_Approved',
    'rejectedBatch' => 'Advance_Batch_Rejected',
    'submittedIc' => 'Advance_IC_Submitted',
    'rejectedIc' => 'Advance_IC_Rejected',
    'approvedIc' => 'Advance_IC_Approved',
    'recalledIc' => 'Advance_IC_Recalled'
  };
  //

  public static void beforeInsert(List<Batch_Approval__c> newList) {
    Map<String,Schema.RecordTypeInfo> recTypeMap = Schema.SObjectType.Batch_Approval__c.getRecordTypeInfosByName();
    for (Batch_Approval__c ba : newList) {
      ba.Submitted_By__c = UserInfo.getUserId();
      ba.Week_Of__c = System.today().toStartOfWeek().addDays(1);

      if(ba.Approval_Type__c == 'Advance Batch Approval') {
        ba.RecordTypeId = recTypeMap.get('Batch Approval').getRecordTypeId();//Single Approval	
      } else if (ba.Approval_Type__c == 'Advance IC Approval') {
        ba.RecordTypeId = recTypeMap.get('Single Approval').getRecordTypeId();	
      }
    }
  }

  public static void afterInsert(Map<Id, Batch_Approval__c> newMap) {
    List<Batch_Approval__c> batchApprovals = new List<Batch_Approval__c>();
    List<Batch_Approval__c> icApprovals = new List<Batch_Approval__c>();
    Map<String,List<Batch_Approval__c>> approvalMap = new Map<String, List<Batch_Approval__c>>();
    for(Batch_Approval__c ba: newMap.values()) {
      if(!approvalMap.containsKey(ba.Approval_Type__c)) {
        approvalMap.put(ba.Approval_Type__c, new List<Batch_Approval__c>{ba});
      } else {
        approvalMap.get(ba.Approval_Type__c).add(ba);
      }
      // if(ba.Approval_Type__c == 'Advance Batch Approval') {
      //   batchApprovals.add(ba);
      // }
    }

    if(approvalMap.size() > 0){ 
      for(String appType : approvalMap.keySet()) {
        createBatchApprovers(approvalMap.get(appType), APPROVER_GROUP_MAP.get(appType));
      }
    }
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
    Map<Id, Batch_Approval__c> recalledRecords = new Map<Id, Batch_Approval__c>();

    Map<Id, Batch_Approval__c> submittedIc = new Map<Id, Batch_Approval__c>();
    Map<Id, Batch_Approval__c> approvedIc = new Map<Id, Batch_Approval__c>();
    Map<Id, Batch_Approval__c> rejectedIc = new Map<Id, Batch_Approval__c>();

    List<Batch_Approval__c> advancesToUpdate = new List<Batch_Approval__c>();
    for (Batch_Approval__c newBa : newMap.values()) {
      Batch_Approval__c oldBa = oldMap.get(newBa.Id);

      if (
        newBa.Approval_Status__c != oldBa.Approval_Status__c &&
        newBa.Approval_Status__c == 'Rejected'
      ) {
        if(newBa.Approval_Type__c == 'Advance Batch Approval') {
          rejectedBatches.put(newBa.Id, newBa);
        } else if(newBa.Approval_Type__c == 'Advance IC Approval') {
          rejectedIc.put(newBa.Id, newBa);
          advancesToUpdate.add(newBa);
        }
      }

      if (
        newBa.Approval_Status__c != oldBa.Approval_Status__c &&
        newBa.Approval_Status__c == 'Approved'
      ) {
        if(newBa.Approval_Type__c == 'Advance Batch Approval') {
          approvedMap.put(newBa.Id, newBa);
        } else if(newBa.Approval_Type__c == 'Advance IC Approval') {
          approvedIc.put(newBa.Id, newBa);
          advancesToUpdate.add(newBa);
        }
      }

      if(newBa.Is_Recalled__c != oldBa.Is_Recalled__c &&
      newBa.Is_Recalled__c) {
        recalledRecords.put(newBa.Id, newBa);
        advancesToUpdate.add(newBa);
      }

      if (
        oldBa.AttachmentPosted__c != newBa.AttachmentPosted__c &&
        newBa.AttachmentPosted__c
      ) {
        if(newBa.Approval_Type__c == 'Advance Batch Approval') {
          submittedBatches.put(newBa.Id, newBa);
        } else if (newBa.Approval_Type__c == 'Advance IC Approval') {
          submittedIc.put(newBa.Id, newBa);
          advancesToUpdate.add(newBa);
        }
      }
    }

    if (rejectedBatches.size() > 0) {
      updateApprovalHistories(rejectedBatches.keySet(), 'Rejected');
      postApproveRejectChatter(rejectedBatches.keySet());
      updateNonResponse(rejectedBatches.keySet());
      sendEmail(rejectedBatches.values(), 'rejectedBatch');
    }

    if(rejectedIc.size() > 0) {
      updateApprovalHistories(rejectedIc.keySet(), 'Rejected');
      postApproveRejectChatter(rejectedIc.keySet());
      updateNonResponse(rejectedIc.keySet());
      sendEmail(rejectedIc.values(), 'rejectedIc');
    }

    if (approvedMap.size() > 0) {
      updateApprovalHistories(approvedMap.keySet(), 'Approved');
      postApproveRejectChatter(approvedMap.keySet());
      updateNonResponse(approvedMap.keySet());
      sendEmail(approvedMap.values(), 'approvedBatch');
    }

    if(approvedIc.size() > 0) {
      updateApprovalHistories(approvedIc.keySet(), 'Approved');
      postApproveRejectChatter(approvedIc.keySet());
      updateNonResponse(approvedIc.keySet());
      sendEmail(approvedIc.values(), 'approvedIc');
    }

    if (submittedBatches.size() > 0) {
      aggregateAdvances(submittedBatches.keySet(), submittedBatches.values()[0].Approval_Type__c);
      sendEmail(submittedBatches.values(), 'submittedBatch');
    }
    if(submittedIc.size() > 0) {
      aggregateAdvances(submittedIc.keySet(), submittedIc.values()[0].Approval_Type__c);
      sendEmail(submittedIc.values(), 'submittedIc');
    }

    if(recalledRecords.size() > 0) {
      updateRecalled(recalledRecords.keySet());
      updateApprovalHistories(recalledRecords.keySet(), 'Recalled');
      sendEmail(recalledRecords.values(), 'recalledIc');
    }

    if(advancesToUpdate.size() > 0) {
      updateAdvanceStatus(advancesToUpdate);
    }
  }

  public static void updateAdvanceStatus(List<Batch_Approval__c> approvals) {
    Map<Id,Advance__c> advsToUpdate = new Map<Id,Advance__c>();

    for(Batch_Approval__c a : approvals) {
      if(a.Advance__c != null) {
        advsToUpdate.put(a.Advance__c, new Advance__c(
          Id = a.Advance__c,
          IC_Approval_Status__c = a.Approval_Status__c
        ));
      }
    }

    if(advsToUpdate.size() > 0) {
      update advsToUpdate.values();
    }
  }

  public static void updateRecalled(Set<Id> recIds) {
    Map<Id, ConnectApi.BatchInput> feedElements = new Map<Id, ConnectApi.BatchInput>();
    Map<Id, List<Id>> mentionIdsMap = new Map<Id,List<Id>>();
    List<Batch_Approver__c> bApprovers = [
      SELECT Id, Approver__c,Batch_Approval__r.Submitted_By__c, Status__c, Batch_Approval__c, Batch_Approval__r.Advance__c, Batch_Approval__r.Approval_Type__c
      FROM Batch_Approver__c
      WHERE Batch_Approval__c IN :recIds
      FOR UPDATE
    ];

    for(Batch_Approver__c ba : bApprovers) {
      if(ba.Status__c != 'Rejected') {
        ba.Status__c = 'Recalled';
      }

      if(!mentionIdsMap.containsKey(ba.Batch_Approval__c)) {
        mentionIdsMap.put(ba.Batch_Approval__c, new List<Id>{ba.Approver__c, ba.Batch_Approval__r.Submitted_By__c});
      } else {
        mentionIdsMap.get(ba.Batch_Approval__c).add(ba.Approver__c);
      }

    }

    for(Batch_Approver__c ba: bApprovers) {
      if(feedElements.containsKey(ba.Batch_Approval__c)) {
        continue;
      }
      feedElements.put(ba.Batch_Approval__c, constructBatchChatterPost('This approval has been recalled by ' + UserInfo.getName(), (ba.Batch_Approval__r.Approval_Type__c == 'Advance Batch Approval'?  ba.Batch_Approval__c : ba.Batch_Approval__r.Advance__c), mentionIdsMap.get(ba.Batch_Approval__c)));

    }

    update bApprovers;
    
    if (!test.isRunningTest()) {
      postChatterBatch(feedElements.values());
    }

    
  }

  public static void sendEmail(
    List<Batch_Approval__c> batchRecords,
    String type
  ) {
    List<String> groupList = new List<String>{APPROVER_GROUP_MAP.get(batchRecords[0].Approval_Type__c)};
    if(RECIPIENT_GROUP_MAP.containsKey(batchRecords[0].Approval_Type__c)) {
      groupList.add(RECIPIENT_GROUP_MAP.get(batchRecords[0].Approval_Type__c));
    }
    Set<Id> sendTo = retrieveGroupMembers(
      groupList
    );
    String templateName = TEMPLATE_MAP.get(type);
    Boolean shouldGetFromAdvance = new List<String>{'submittedIc', 'rejectedIc', 'approvedIc', 'recalledIc'}.contains(type);

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
      em.setWhatId(shouldGetFromAdvance ? ba.Advance__c	 : ba.Id);
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
    Map<String,String> approvedMessage = new Map<String,String>{
      'Advance Batch Approval' => 'This batch of advances has been approved by all approvers.',
      'Advance IC Approval' => 'This advance has been approved by all approvers.'
    };
    Map<String,String> rejectedMessage = new Map<String,String>{
      'Advance Batch Approval' => 'This batch of advances has been rejected by ',
      'Advance IC Approval' => 'This advance has been rejected by '
    };


    for (Batch_Approval__c ba : [
      SELECT
        Id,
        Submitted_By__c,
        Approval_Status__c,
        Approval_Type__c,
        Advance__c,
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
        ? approvedMessage.get(ba.Approval_Type__c)
        : rejectedMessage.get(ba.Approval_Type__c);

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

      feedElements.add(constructBatchChatterPost(message, (ba.Approval_Type__c == 'Advance Batch Approval'?  ba.Id : ba.Advance__c ), mentionIds));
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

  public static void createBatchApprovers(List<Batch_Approval__c> batches, String approverGroup) {
    List<Batch_Approver__c> approvers = new List<Batch_Approver__c>();
    
    Set<Id> apprIds = retrieveGroupMembers(new List<String>{ approverGroup });
    List<ConnectApi.BatchInput> feedElements = new List<ConnectApi.BatchInput>();
    for (Batch_Approval__c b : batches) {
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
          CHATTER_MESSAGE_MAP.get(approverGroup) +
          b.Initial_Comments__c,
          (b.Approval_Type__c == 'Advance Batch Approval' ? b.Id : b.Advance__c),
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
  public static void aggregateAdvances(Set<Id> batchIds, String apprType) {
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
    createApprovalHistories(batchIds, apprType);
  }

  public static void createApprovalHistories(Set<Id> batchIds, String apprType) {
    Set<Id> apprIds = retrieveGroupMembers(new List<String>{ APPROVER_GROUP_MAP.get(apprType) });
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
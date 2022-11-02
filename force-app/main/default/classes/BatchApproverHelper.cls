public without sharing class BatchApproverHelper {
  public static void beforeUpdate(
    Map<Id, Batch_Approver__c> oldMap,
    Map<Id, Batch_Approver__c> newMap
  ) {
    for (Batch_Approver__c newBa : newMap.values()) {
      Batch_Approver__c oldBa = oldMap.get(newBa.Id);

      if (newBa.Status__c == 'Approved' && oldBa.Status__c != newBa.Status__c) {
        newBa.Approval_Date__c = System.today();
      }
    }
  }

  public static void afterUpdate(
    Map<Id, Batch_Approver__c> oldMap,
    Map<Id, Batch_Approver__c> newMap
  ) {
    List<Batch_Approver__c> updateComments = new List<Batch_Approver__c>();
    Map<Id, Map<Id, Batch_Approver__c>> updateStatusMap = new Map<Id, Map<Id, Batch_Approver__c>>();
    Map<Id, String> approvedMap = new Map<Id, String>();
    for (Batch_Approver__c newBa : newMap.values()) {
      Batch_Approver__c oldBa = oldMap.get(newBa.Id);

      if (oldBa.Status__c != newBa.Status__c && newBa.Status__c == 'Approved') {
        approvedMap.put(newBa.Batch_Approval__c, newBa.Approver_Name__c);
      }

      if (
        oldBa.Comments__c != newBa.Comments__c &&
        String.isNotEmpty(newBa.Comments__c)
      ) {
        updateComments.add(newBa);
      }

      if (oldBa.Status__c != newBa.Status__c) {
        if (!updateStatusMap.containsKey(newBa.Batch_Approval__c)) {
          updateStatusMap.put(
            newBa.Batch_Approval__c,
            new Map<Id, Batch_Approver__c>{ newBa.Approver__c => newBa }
          );
        } else {
          Map<Id, Batch_Approver__c> subMap = updateStatusMap.get(
            newBa.Batch_Approval__c
          );
          subMap.put(newBa.Approver__c, newBa);
          updateStatusMap.put(newBa.Batch_Approval__c, subMap);
        }
      }
    }

    if (approvedMap.size() > 0) {
      postApprovalChatter(approvedMap);
    }

    if (updateComments.size() > 0) {
      updateCommentsOnParent(updateComments);
    }

    if (updateStatusMap.size() > 0) {
      updateApprovalHistories(updateStatusMap);
    }
  }

  public static void postApprovalChatter(Map<Id, String> appMap) {
    List<ConnectApi.BatchInput> feedElements = new List<ConnectApi.BatchInput>();

    for (Batch_Approval__c ba : [
      SELECT
        Id,
        Submitted_By__c,
        Approval_Type__c,
        Advance__c,
        (
          SELECT Id, Approver__c, Approver_Name__c, Comments__c, Status__c
          FROM Batch_Approvers__r
        )
      FROM Batch_Approval__c
      WHERE Id IN :appMap.keySet()
    ]) {
      List<Id> mentionIds = new List<Id>();
      mentionIds.add(ba.Submitted_By__c);
      String comment = 'Approver comment: ';
      if (ba.Batch_Approvers__r != null && ba.Batch_Approvers__r.size() > 0) {
        for (Batch_Approver__c bapp : ba.Batch_Approvers__r) {
          mentionIds.add(bapp.Approver__c);
          if (
            appMap.get(ba.Id) == bapp.Approver_Name__c &&
            bapp.Status__c == 'Approved'
          ) {
            comment += bapp.Comments__c;
          }
        }
      }

      feedElements.add(
        BatchApprovalHelper.constructBatchChatterPost(
          'This ' + ba.Approval_Type__c + ' has been approved by ' +
          appMap.get(ba.Id) +
          '.\n' +
          comment,
          (ba.Approval_Type__c == 'Advance Batch Approval'
            ? ba.Id
            : ba.Advance__c),
          mentionIds
        )
      );
    }

    if (!test.isRunningTest()) {
      BatchApprovalHelper.postChatterBatch(feedElements);
    }
  }

  public static void updateApprovalHistories(
    Map<Id, Map<Id, Batch_Approver__c>> objMap
  ) {
    List<Approval_History__c> appHistories = new List<Approval_History__c>();

    for (Approval_History__c appHis : [
      SELECT Id, Batch_Approval__c, Status__c, Actor__c, Comments__c
      FROM Approval_History__c
      WHERE Batch_Approval__c IN :objMap.keySet()
    ]) {
      Map<Id, Batch_Approver__c> actorMap = objMap.get(
        appHis.Batch_Approval__c
      );
      if (actorMap.containsKey(appHis.Actor__c)) {
        Batch_Approver__c ba = actorMap.get(appHis.Actor__c);
        appHistories.add(
          new Approval_History__c(
            Id = appHis.Id,
            Status__c = ba.Status__c,
            Comments__c = ba.Comments__c
          )
        );
      }
    }

    if (appHistories.size() > 0) {
      update appHistories;
    }
  }

  public static void updateCommentsOnParent(
    List<Batch_Approver__c> batchApprovers
  ) {
    Map<Id, Batch_Approval__c> bApprovals = new Map<Id, Batch_Approval__c>(
      [
        SELECT Id, Approval_Comments__c
        FROM Batch_Approval__c
        WHERE
          Id IN (
            SELECT Batch_Approval__c
            FROM Batch_Approver__c
            WHERE Id IN :batchApprovers
          )
        FOR UPDATE
      ]
    );

    for (Batch_Approver__c ba : batchApprovers) {
      Batch_Approval__c b = bApprovals.get(ba.Batch_Approval__c);
      b.Approval_Comments__c =
        (String.isEmpty(b.Approval_Comments__c)
          ? ''
          : b.Approval_Comments__c + '\n\n') +
        System.today().format() +
        ': ' +
        ba.Approver_Name__c +
        ' : "' +
        ba.Comments__c +
        '"';
      bApprovals.put(ba.Batch_Approval__c, b);
    }

    update bApprovals.values();
  }
}
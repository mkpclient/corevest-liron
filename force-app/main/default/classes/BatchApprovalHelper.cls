public without sharing class BatchApprovalHelper {
  public static final String APPROVER_GROUP = 'Advance_Batch_Approvers';

  public static void beforeInsert(List<Batch_Approval__c> newList) {
    for (Batch_Approval__c ba : newList) {
      ba.Submitted_By__c = UserInfo.getUserId();
      ba.Week_Of__c = System.today().toStartOfWeek().addDays(1);
    }
  }

  public static void afterInsert(Map<Id, Batch_Approval__c> newMap) {
    createBatchApprovers(newMap.keySet());
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
    Set<Id> rejectedIds = new Set<Id>();
    Set<Id> approvedIds = new Set<Id>();
    for (Batch_Approval__c newBa : newMap.values()) {
      Batch_Approval__c oldBa = oldMap.get(newBa.Id);

      if (
        newBa.Approval_Status__c != oldBa.Approval_Status__c &&
        newBa.Approval_Status__c == 'Rejected'
      ) {
        rejectedIds.add(newBa.Id);
      }

      if (
        newBa.Approval_Status__c != oldBa.Approval_Status__c &&
        newBa.Approval_Status__c == 'Approved'
      ) {
        approvedIds.add(newBa.Id);
      }
    }

    if (rejectedIds.size() > 0) {
      updateApprovalHistories(rejectedIds, 'Rejected');
      rejectAllApprovers(rejectedIds);
    }

    if (approvedIds.size() > 0) {
      updateApprovalHistories(approvedIds, 'Approved');
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

  public static void rejectAllApprovers(Set<Id> batchIds) {
    List<Batch_Approver__c> bApprovers = [
      SELECT Id, Status__c
      FROM Batch_Approver__c
      WHERE Batch_Approval__c IN :batchIds AND Status__c != 'Rejected'
      FOR UPDATE
    ];

    for(Batch_Approver__c ba : bApprovers) {
      ba.Status__c = 'Rejected';
    }

    if(bApprovers.size() > 0) {
      update bApprovers;
    }
    
  }

  public static void createBatchApprovers(Set<Id> batchIds) {
    List<Batch_Approver__c> approvers = new List<Batch_Approver__c>();
    Set<Id> apprIds = retrieveGroupMembers();

    for (Id b : batchIds) {
      for (Id a : apprIds) {
        Batch_Approver__c ba = new Batch_Approver__c();
        ba.Submitted_By__c = UserInfo.getUserId();
        ba.Status__c = 'Pending';
        ba.Approver__c = a;
        ba.Batch_Approval__c = b;

        approvers.add(ba);
      }
    }

    insert approvers;
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
    Set<Id> apprIds = retrieveGroupMembers();
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
    }

    insert appHistories;
  }

  public static Set<Id> retrieveGroupMembers() {
    return new Map<Id, User>(
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
              WHERE group.DeveloperName = :APPROVER_GROUP
            )
        ]
      )
      .keySet();
  }
}

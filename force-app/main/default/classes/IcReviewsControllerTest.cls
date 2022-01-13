@isTest
private class IcReviewsControllerTest {
  @isTest
  static void IcReviewsControllerTest() {
    Id userId = UserInfo.getUserId();
    String approvalType = 'Bridge IC';
    String processName = 'Bridge_IC_Approval';
    Account testAcct = Test_Helper.createAccount();
    Contact testContact = Test_Helper.createContact(testAcct);
    Opportunity testDeal = Test_Helper.createBridgeDeal(testAcct, testContact);
    testDeal.StageName = 'Underwriting';
    testDeal.Amount = 245000;
    testDeal.Estimated_Sponsor_Tier__c = 'Tier 1';
    testDeal.Final_Sponsor_Tier__c = 'Tier 1';
    update testDeal;
    Id recordId = testDeal.Id;
    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setObjectId(recordId);
    req.setSubmitterId(userId);
    req.setSkipEntryCriteria(true);
    req.setProcessDefinitionNameOrId(processName);
    Approval.ProcessResult result = Approval.process(req);
    Id processInstanceId = result.getInstanceId();
    String status = result.getInstanceStatus();
    List<Id> workItemIds = result.getNewWorkitemIds();

    Opportunity deal = IcApprovalController.queryOpportunity(recordId);

    String dealStage = deal.StageName;

    String ahProcessName = approvalType != 'Term Sub-IC'
      ? approvalType + ' Process'
      : approvalType;
    List<Approval_History__c> ahList = new List<Approval_History__c>();
    Approval_History__c ahc = new Approval_History__c(
      Process_Instance_Id__c = processInstanceId,
      Parent_Status__c = status,
      Deal__c = recordId,
      Name = 'Approval Request: ' + deal.Name.left(50),
      ProcessName__c = ahProcessName,
      Approver__c = UserInfo.getName(),
      Actor__c = UserInfo.getUserId(),
      Role__c = 'Submitter',
      Date_Acted__c = System.now(),
      Status__c = 'Submitted',
      Status_Text__c = 'Submitted',
      Approval_Type__c = 'IC Memo',
      Tracking_Status__c = 'Closer',
      Deal_Stage_At_Time_of_Submission__c = dealStage
    );

    ahc.Spread__c = deal.Final_Spread__c;
    if (ahc.Spread__c != null) {
      ahc.Spread__c *= 100;
    }

    ahc.Origination_Fee__c = deal.CAF_Upfront_Fee__c;

    ahList.add(ahc);

    for (ProcessInstanceWorkitem workItem : [
      SELECT Id, ActorId, Actor.Name
      FROM ProcessInstanceWorkItem
      WHERE Id IN :workItemIds
    ]) {
      Approval_History__c a = new Approval_History__c(
        Process_Instance_Id__c = processInstanceId,
        Process_Id__c = workItem.Id,
        ProcessName__c = ahProcessName,
        Actor__c = workItem.ActorId,
        Parent_Status__c = status,
        Deal__c = recordId,
        Name = 'Approval Request: ' + deal.Name.left(50),
        Approver__c = workItem.Actor.Name, // actor.name
        Status__c = 'Pending',
        Status_Text__c = 'Pending: Committee Review',
        Date_Acted__c = System.now(),
        Approval_Type__c = 'IC Memo',
        Deal_Stage_At_Time_of_Submission__c = dealStage,
        Tracking_Status__c = 'Committee'
      );

      a.Spread__c = deal.Final_Spread__c;
      if (a.Spread__c != null) {
        a.Spread__c *= 100;
      }

      ahList.add(a);
    }
    insert ahList;
    Test.startTest();
        List<Map<String, Object>> approvalHistories = IcReviewsLwcController.getApprovalHistories();
        System.assertEquals(true, approvalHistories.size() > 0, 'Some approval histories should have been returned.');
    Test.stopTest();
  }
}
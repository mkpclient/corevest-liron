public without sharing class IcRejectionLinkController {
  public static Opportunity deal { get; set; }
  public static String toastTitle { get; set; }
  public static String toastMessage { get; set; }
  public static String toastVariant { get; set; }
  public static final String DEAL_EMAIL_HANDLER_DEVNAME = 'Deal_Email_Handler';

  public static final String IC_REJECTED_TEMPLATE = 'IC_Reversed_Email';

  public static final String PERMISSION_SET_NAME = 'IC_Approval_Allow_Rejection_Through_Link';

  public static Boolean unhideToast {
    get {
      return toastTitle != null && toastMessage != null && toastVariant != null;
    }
    set;
  }

  public IcRejectionLinkController() {
    deal = [
      SELECT
        Id,
        Name,
        Underwriter__c,
        OwnerId,
        Record_Type_Name__c,
        Contact__c,
        IC_Approval__c,
        IC_Approval_Date__c,
        Final_Spread__c,
        CAF_Upfront_Fee__c,
        (
          SELECT Id, OpportunityId, UserId
          FROM OpportunityTeamMembers
          WHERE UserId != NULL
        )
      FROM Opportunity
      WHERE Id = :ApexPages.currentPage().getParameters().get('id')
    ];
  }

  public static void emailReversedIcApprovalAlert() {
    List<EmailServicesAddress> esas = [
      SELECT Id, LocalPart, EmailDomainName, DeveloperName
      FROM EmailServicesAddress
      WHERE DeveloperName = :DEAL_EMAIL_HANDLER_DEVNAME
    ];

    Map<Id, Set<Id>> termDealIdsByRecipients = new Map<Id, Set<Id>>();
    Map<Id, Set<Id>> bridgeDealIdsByRecipients = new Map<Id, Set<Id>>();

    List<String> ccNames = new List<String>{
      'Libby Burgeson',
      'Micaela Lumpkin'
    };

    Set<Id> recipientIds = new Set<Id>();

    Group gp = [
      SELECT DeveloperName, (SELECT UserOrGroupId FROM GroupMembers)
      FROM Group
      WHERE DeveloperName = 'Term_IC_Approval'
    ];

    Map<Id, User> ccusers = new Map<Id, User>(
      [SELECT Id, Name FROM User WHERE Name IN :ccNames]
    );

    recipientIds.addAll(ccusers.keySet());

    for (GroupMember gm : gp.GroupMembers) {
      recipientIds.add(gm.UserOrGroupId);
    }

    Set<Id> addlRecipIds = new Set<Id>();

    addlRecipIds.addAll(recipientIds);

    if (deal.OpportunityTeamMembers != null) {
      for (OpportunityTeamMember otm : deal.OpportunityTeamMembers) {
        addlRecipIds.add(otm.UserId);
      }

      addlRecipIds.add(deal.OwnerId);
      if(String.isNotEmpty(deal.Underwriter__c)) {
        addlRecipIds.add(deal.Underwriter__c);
      }

      if (deal.Record_Type_Name__c == 'Term_Loan') {
        termDealIdsByRecipients.put(deal.Id, addlRecipIds);
      } else if (deal.Record_Type_Name__c == 'LOC_Loan') {
        bridgeDealIdsByRecipients.put(deal.Id, addlRecipIds);
      }
    }

    List<EmailTemplate> templates = [
      SELECT Id
      FROM EmailTemplate
      WHERE DeveloperName = :IC_REJECTED_TEMPLATE
      LIMIT 1
    ];

    if (templates.size() == 0) {
      toastTitle = 'Error';
      toastMessage = 'No email template found for IC Rejected Alert';
      toastVariant = 'error';
      return;
    }

    Id tempId = templates[0].Id;

    String handlerAddress = '';

    if (esas.size() > 0) {
      handlerAddress =
        esas[0].LocalPart +
        '@' +
        esas[0].EmailDomainName;
    }

    List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

    if (termDealIdsByRecipients.size() > 0) {
      for (Id tOpptId : termDealIdsByRecipients.keySet()) {
        List<Id> recpIds = new List<Id>();
        recpIds.addAll(termDealIdsByRecipients.get(tOpptId));
        Messaging.SingleEmailMessage termEmail = new Messaging.SingleEmailMessage();
        termEmail.setTemplateId(tempId);
        termEmail.setTargetObjectId(deal.Contact__c);
        termEmail.setTreatTargetObjectAsRecipient(false);
        if(recpIds.size() > 0) {
          termEmail.setToAddresses(recpIds);
        }
        termEmail.setWhatId(tOpptId);
        termEmail.setReplyTo('caf-apps@cvest.com');
        if (handlerAddress != '') {
          termEmail.setCcAddresses(new List<String>{ handlerAddress });
        }
        termEmail.setSaveAsActivity(true);
        messages.add(termEmail);
      }
    }

    if (bridgeDealIdsByRecipients.size() > 0) {
      for (Id bOpptId : bridgeDealIdsByRecipients.keySet()) {
        List<Id> recpIds = new List<Id>();
        recpIds.addAll(bridgeDealIdsByRecipients.get(bOpptId));
        Messaging.SingleEmailMessage bridgeEmail = new Messaging.SingleEmailMessage();
        bridgeEmail.setTemplateId(tempId);
        bridgeEmail.setTargetObjectId(deal.Contact__c);
        bridgeEmail.setTreatTargetObjectAsRecipient(false);
        if(recpIds.size() > 0) {
          bridgeEmail.setToAddresses(recpIds);
        }
        bridgeEmail.setWhatId(bOpptId);
        bridgeEmail.setReplyTo('caf-apps@cvest.com');
        if (handlerAddress != '') {
          bridgeEmail.setCcAddresses(new List<String>{ handlerAddress });
        }
        bridgeEmail.setSaveAsActivity(true);
        messages.add(bridgeEmail);
      }
    }

    if (messages.size() > 0 && !Test.isRunningTest()) {
      List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages);

      if (results[0].success) {
        System.debug('The email was sent successfully.');
      } else {
        System.debug(
          'The email failed to send: ' + results[0].errors[0].message
        );
      }
    } else if (Test.isRunningTest()) {
      System.debug('The email would have been sent.');
      System.debug(messages);
    }
  }

  public static void rejectDeal() {
    List<ProcessInstance> processInstances = [
      SELECT
        Id,
        Status,
        ProcessDefinition.Name
        // ,
        // (
        //   SELECT Id, StepStatus, Actor.Name, Comments
        //   FROM StepsAndWorkitems
        //   WHERE ActorId = :UserInfo.getUserId()
        // )
      FROM ProcessInstance
      WHERE
        ProcessDefinition.Name LIKE '%IC%'
        AND Status = 'Approved'
        AND TargetObjectId = :deal.Id
        ORDER BY CreatedDate Desc
    ];

    if (processInstances.size() > 0) {

      List<PermissionSetAssignment> permissionAssignments = [
        SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId() AND PermissionSet.Name = :PERMISSION_SET_NAME
      ];

      Boolean allowRejectionByUser = permissionAssignments.size() > 0;

      if (allowRejectionByUser || Test.isRunningTest()) {
        if (deal.IC_Approval__c != 'Approved') {
          toastTitle = 'Error';
          toastMessage = 'Deal is currently not approved';
          toastVariant = 'error';
          return;
        }
        
        Opportunity o = new Opportunity(
          Id = deal.Id,
          IC_Approval__c = null,
          IC_Approval_Date__c = null,
          StageName = 'Underwriting'
        );
        Savepoint sp = Database.setSavepoint();

        try {
          update o;
          createApprovalHistory(processInstances[0].ProcessDefinition.Name);
          emailReversedIcApprovalAlert();
          toastTitle = 'Success';
          toastMessage = 'This deal\'s IC approval has been reversed.';
          toastVariant = 'success';
        } catch (Exception e) {
          Database.rollback(sp);
          toastTitle = 'Deal Rejection Failed. Error on Line ' + e.getLineNumber();
          toastMessage = e.getMessage();
          toastVariant = 'error';
        }
      } else {
        toastTitle = 'Deal Rejection Failed';
        toastMessage = 'You are not authorized to reject this deal.';
        toastVariant = 'error';
      }
    } else {
      toastTitle = 'No Prior IC Approval Found';
      toastMessage = 'This deal has no prior IC approval to reject.';
      toastVariant = 'error';
    }
  }

  public static void createApprovalHistory(String approvalType) {
    String ahProcessName = (approvalType != 'Term Sub-IC' || approvalType != 'Bridge Sub-IC')
    ? approvalType + ' Process'
    : approvalType;
    Approval_History__c ahc = new Approval_History__c(
      Parent_Status__c = 'Rejected',
      Deal__c = deal.Id,
      Name = 'Approval Request: ' + deal.Name.left(50),
      ProcessName__c = ahProcessName,
      Approver__c = UserInfo.getName(),
      Actor__c = UserInfo.getUserId(),
      Date_Acted__c = System.now(),
      Status__c = 'Rejected',
      Status_Text__c = 'Rejected',
      Approval_Type__c = approvalType,
      Tracking_Status__c = 'Committee',
      Deal_Stage_At_Time_of_Submission__c = 'Underwriting',
      Comments__c = 'Approval is overridden by ' + UserInfo.getName()
    );

    if (deal.Final_Spread__c != null) {
      ahc.Spread__c = deal.Final_Spread__c;
      // ahc.Spread__c *= 100;
    }

    if(deal.CAF_Upfront_Fee__c != null) {
      ahc.Origination_Fee__c = deal.CAF_Upfront_Fee__c;
    }

    insert ahc;
  }
}
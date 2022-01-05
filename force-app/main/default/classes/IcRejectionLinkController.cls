public without sharing class IcRejectionLinkController {
  public static Opportunity deal { get; set; }
  public static String toastTitle { get; set; }
  public static String toastMessage { get; set; }
  public static String toastVariant { get; set; }
  public static Boolean unhideToast {
      get {
          return toastTitle != null && toastMessage != null && toastVariant != null;
      } set;
  }

  public IcRejectionLinkController() {
    deal = [
      SELECT Id, Name
      FROM Opportunity
      WHERE Id = :ApexPages.currentPage().getParameters().get('id')
    ];

  }

  public static void rejectDeal() {
    List<ProcessInstance> processInstances = [
      SELECT
        Id,
        Status,
        (
          SELECT Id, StepStatus, Actor.Name, Comments
          FROM StepsAndWorkitems
          WHERE ActorId = :UserInfo.getUserId()
        )
      FROM ProcessInstance
      WHERE ProcessDefinition.Name LIKE '%IC%' AND Status = 'Approved'
      AND TargetObjectId = :deal.Id
    ];

    if(processInstances.size() > 0) {
      Boolean allowRejectionByUser = false;

      for(ProcessInstance pi : processInstances) {
        if(pi.StepsAndWorkitems.size() > 0) {
          allowRejectionByUser = true;
          break;
        }
      }

      if(allowRejectionByUser) {
        Opportunity o = new Opportunity(
            Id = deal.Id,
            IC_Approval__c = null,
            IC_Approval_Date__c = null,
            StageName = 'Underwriting'
        );

        update o;


        toastTitle = 'Success';
        toastMessage = 'This deal\'s IC approval has been reversed.';
        toastVariant = 'success';


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
}

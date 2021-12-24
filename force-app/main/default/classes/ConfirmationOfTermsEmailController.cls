public class ConfirmationOfTermsEmailController {
  public Id historyId { get; set; }
  public ConfirmationOfTermsController.Panels panels;

  public ConfirmationOfTermsController.SubmissionPanel submissionDetails;
  public ConfirmationOfTermsController.CurrentPanel currentDetails;
  public ConfirmationOfTermsController.Comments comments;
  public Opportunity deal;
  public ConfirmationOfTermsController.Panels getPanels() {
    if (this.historyId != null && this.panels == null) {
      Approval_History__c hist = [
        SELECT Id, Deal__c, Process_Instance_Id__c
        FROM Approval_History__c
        WHERE Id = :this.historyId
      ];
      Id dealId = hist.Deal__c;
      this.panels = (ConfirmationOfTermsController.Panels) JSON.deserialize(
        ConfirmationOfTermsController.getRecordDetails(
          dealId,
          hist.Process_Instance_Id__c
        ),
        ConfirmationOfTermsController.Panels.class
      );
    }

    return this.panels;
  }

  public Opportunity getDeal() {
    if (this.historyId != null && this.deal == null) {
      Approval_History__c hist = [
        SELECT Id, Deal__c
        FROM Approval_History__c
        WHERE Id = :this.historyId
      ];
      this.deal = [SELECT Id, Name, Deal_Loan_NUmber__c FROM Opportunity WHERE Id = :hist.Deal__c];
    }
    return this.deal;
  }
}
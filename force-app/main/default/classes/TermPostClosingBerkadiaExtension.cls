public with sharing class TermPostClosingBerkadiaExtension {
  public String recId { get; set; }
  public Opportunity Opportunity { get; set; }
  public static final string ONBOARDING = 'LoanOnboarding';

  public Boolean isClo { 
    get {
      if(isClo == null && recId != null) {
        List<CLO_Asset_Details__c> cads = [
          SELECT Id
          FROM CLO_Asset_Details__c
          WHERE Deal_ID__c = :recId
          AND (Interest_Rate_Cap_Reserve__c != null
          OR Reserve_Cap_Ex__c != null
          OR Reserve_Insurance__c != null
          OR Reserve_Tax__c != null)
        ];
        return cads.size() > 0;
      } else {
        return null;
      }
    } private set;
  }

  public Loan_Version__c loanVersion {
    get {
      return recid != null
        ? [
            SELECT
              Holdback_Reserve__c,
              Initial_Monthly_Tax_Reserve_Deposit__c,
              Monthly_Cap_Ex__c,
              Monthly_Tax__c,
              Required_Holdback_Reserve__c,
              Monthly_Interest_Rate_Cap_Constants__c,
              Recourse__c,
              RecordType.DeveloperName,
              Monthly_Insurance__c,
              Monthly_Payment__c,
              Tax_Payment_Recurrence__c,
              First_Tax_Installment_Due__c,
              Taxes_Paid_at_Closing__c
            FROM Loan_Version__c
            WHERE RecordType.DeveloperName = :ONBOARDING AND Deal__c = :recId
            LIMIT 1
          ]
        : new Loan_Version__c();
    }
    private set;
  }

  public TermPostClosingBerkadiaExtension(
    ApexPages.standardController standardController
  ) {
    this.Opportunity = (Opportunity) standardController.getRecord();
    this.recId = (String) this.Opportunity.Id;
  }
}
public class update_Swap_Rate {
  @AuraEnabled
  public static String UpdateRate(id opportunityId) {
    Opportunity Oppor;
    try {
      Oppor = [
        SELECT
          Swap_Rate__c,
          RecordType__c,
          Rate_Locked__c,
          Floor__c,
          Term_Loan_Type__c
        FROM Opportunity
        WHERE
          id = :opportunityId
          AND RecordType__c = 'Term'
          AND Rate_Locked__c = FALSE
          AND StageName NOT IN ('Withdrawn', 'Rejected')
          AND Term_Loan_Type__c != NULL
      ];
    } catch (System.QueryException e) {
      return 'No Updates';
    }
    if (Oppor != null) {
      Swap_Rate__c SwapRate = [
        SELECT
          Five_Year_Swap__c,
          Seven_Year_Swap__c,
          Ten_Year_Swap__c,
          Thirty_Year_Swap__c
        FROM Swap_Rate__c
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];
      decimal floor;
      if (Oppor.Floor__c != null)
        floor = Oppor.Floor__c;
      else
        floor = 0;

      Boolean updateOpportunity = false;
      switch on Oppor.Term_Loan_Type__c {
        when '5 Year' {
          if (SwapRate.Five_Year_Swap__c != null) {
            if (SwapRate.Five_Year_Swap__c > floor) {
              Oppor.Swap_Rate__c = SwapRate.Five_Year_Swap__c;
              updateOpportunity = true;
            } else {
              Oppor.Swap_Rate__c = floor;
              updateOpportunity = true;
            }
          }
        }
        when '7 Year' {
          if (SwapRate.Seven_Year_Swap__c != null) {
            if (SwapRate.Seven_Year_Swap__c > floor) {
              Oppor.Swap_Rate__c = SwapRate.Seven_Year_Swap__c;
              updateOpportunity = true;
            } else {
              Oppor.Swap_Rate__c = floor;
              updateOpportunity = true;
            }
          }
        }
        when '10 Year' {
          if (SwapRate.Ten_Year_Swap__c != null) {
            if (SwapRate.Ten_Year_Swap__c > floor) {
              Oppor.Swap_Rate__c = SwapRate.Ten_Year_Swap__c;
              updateOpportunity = true;
            } else {
              Oppor.Swap_Rate__c = floor;
              updateOpportunity = true;
            }
          }
        }
        when '30 Year' {
          if (SwapRate.Thirty_Year_Swap__c != null) {
            if (SwapRate.Thirty_Year_Swap__c > floor) {
              Oppor.Swap_Rate__c = SwapRate.Thirty_Year_Swap__c;
              updateOpportunity = true;
            } else {
              Oppor.Swap_Rate__c = floor;
              updateOpportunity = true;
            }
          }
        }
      } //switch

      if (updateOpportunity) {
        try {
          update Oppor;
          return 'Success';
        } catch (DmlException e) {
          throw new AuraHandledException(e.getDmlMessage(0));
        }
      } else {
        return 'No Updates';
      }
    } else {
      return 'No Updates';
    }
  } //UpdateRate method
}
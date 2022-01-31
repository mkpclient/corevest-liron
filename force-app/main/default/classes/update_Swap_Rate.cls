public class update_Swap_Rate {
    
	@AuraEnabled
    public Static String UpdateRate(id opportunityId) {
         Opportunity Oppor= [Select Swap_Rate__c,RecordType__c, Rate_Locked__c, Floor__c, Term_Loan_Type__c,Current_Stage__c 
                       from Opportunity where id = :opportunityId and RecordType__c = 'Term' and Rate_Locked__c = false];
		Swap_Rate__c SwapRate = [select Five_Year_Swap__c,Seven_Year_Swap__c,Ten_Year_Swap__c,Thirty_Year_Swap__c 
                         from Swap_Rate__c order by CreatedDate desc limit 1];
        
       Boolean updateOpportunity = false;
       switch on Oppor.Term_Loan_Type__c {
       when '5 Year' {
           if (SwapRate.Five_Year_Swap__c > Oppor.Floor__c)
           {
               Oppor.Swap_Rate__c = SwapRate.Five_Year_Swap__c;
               updateOpportunity = True;
           }
           else
           {
               Oppor.Swap_Rate__c = Oppor.Floor__c;
               updateOpportunity = True;
           }
       }
       when '7 Year' {
           if (SwapRate.Seven_Year_Swap__c > Oppor.Floor__c)
           {
               Oppor.Swap_Rate__c = SwapRate.Seven_Year_Swap__c;
               updateOpportunity = True;
           }
           else
           {
               Oppor.Swap_Rate__c = Oppor.Floor__c;
               updateOpportunity = True;
           }
       }
       when '10 Year' {
           if (SwapRate.Ten_Year_Swap__c > Oppor.Floor__c)
           {
               Oppor.Swap_Rate__c = SwapRate.Ten_Year_Swap__c;
               updateOpportunity = True;
           }
           else
           {
               Oppor.Swap_Rate__c = Oppor.Floor__c;
               updateOpportunity = True;
           }
       }
       when '30 Year' {
           if (SwapRate.Thirty_Year_Swap__c > Oppor.Floor__c)
           {
               Oppor.Swap_Rate__c = SwapRate.Thirty_Year_Swap__c;
               updateOpportunity = True;
           }
           else
           {
               Oppor.Swap_Rate__c = Oppor.Floor__c;
               updateOpportunity = True;
           }
       }           
	  } //switch
       
      if (updateOpportunity)
      {
       try {
       update Oppor;
       return 'Success';
       } catch (DmlException e) {
       throw new AuraHandledException(e.getDmlMessage(0));
       }
	 } 
     Else
     {
       return 'No Updates';  
     }
    } //UpdateRate method
}
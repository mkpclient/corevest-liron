public class dealSwapRateUpdate implements Database.Batchable<sObject>{

     public Database.QueryLocator start(Database.BatchableContext BC){
	 String query = 'Select Swap_Rate__c,RecordType__c, Rate_Locked__c, Floor__c, Term_Loan_Type__c,Current_Stage__c from Opportunity where RecordType__c = \'Term\' and Rate_Locked__c = false and StageName  not in (\'Withdrawn\', \'Rejected\') and Term_Loan_Type__c != NULL';
     return Database.getQueryLocator(query);
   }
     
     public void execute(Database.BatchableContext BC, List<opportunity> processingDeals){
     

	List<opportunity> dealsToUpdate = new List<opportunity>();
	Boolean updateOpportunity = false; 
	Swap_Rate__c SwapRate = [select Five_Year_Swap__c,Seven_Year_Swap__c,Ten_Year_Swap__c,Thirty_Year_Swap__c from Swap_Rate__c where CreatedDateTime__c != null order by CreatedDateTime__c desc limit 1];                           
     for(opportunity Oppor : processingDeals){
 
        decimal floor; 
		if (Oppor.Floor__c != null)
            floor = Oppor.Floor__c;
        else
            floor = 0;
         
       switch on Oppor.Term_Loan_Type__c {
       when '5 Year' {
           if (SwapRate.Five_Year_Swap__c != null)
           {
           if (SwapRate.Five_Year_Swap__c > floor)
           {
               Oppor.Swap_Rate__c = SwapRate.Five_Year_Swap__c;
               updateOpportunity = True;
           }
           else
           {
               Oppor.Swap_Rate__c = floor;
               updateOpportunity = True;
           }
           }
       }
       when '7 Year' {
           if (SwapRate.Seven_Year_Swap__c != null)
           {
           if (SwapRate.Seven_Year_Swap__c > floor )
           {
               Oppor.Swap_Rate__c = SwapRate.Seven_Year_Swap__c;
               updateOpportunity = True;
           }
           else
           {
               Oppor.Swap_Rate__c = floor;
               updateOpportunity = True;
           }
           }
       }
       when '10 Year' {
           if (SwapRate.Ten_Year_Swap__c != null )
           {
           if (SwapRate.Ten_Year_Swap__c > floor)
           {
               Oppor.Swap_Rate__c = SwapRate.Ten_Year_Swap__c;
               updateOpportunity = True;
           }
           else
           {
               Oppor.Swap_Rate__c = floor;
               updateOpportunity = True;
           }
           }
       }
       when '30 Year' {
		   if (SwapRate.Thirty_Year_Swap__c != null)
           {
           if (SwapRate.Thirty_Year_Swap__c > floor)
           {
               Oppor.Swap_Rate__c = SwapRate.Thirty_Year_Swap__c;
               updateOpportunity = True;
           }
           else
           {
               Oppor.Swap_Rate__c = floor;
               updateOpportunity = True;
           }
           }
       }           
	  } //switch 
      if (updateOpportunity)
      {
       dealsToUpdate.add(Oppor);
       updateOpportunity = False;
      }
     } //for

       system.debug('dealsToUpdate :' +dealsToUpdate);
                    
	if (dealsToUpdate.size() > 0)
	{
        try 
        {
        update dealsToUpdate;
        } 
        catch (DmlException e)
        {
        System.debug( 'Error updating Swap Rates on deal' + e.getMessage());
        }                
	}
	} //method

   public void finish(Database.BatchableContext BC){
              system.debug('finish:' );
   }
    
}
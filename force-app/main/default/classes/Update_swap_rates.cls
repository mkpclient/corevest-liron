public class Update_swap_rates {
    
	public Id opportunityId;
    
    public Update_swap_rates(ApexPages.standardController standardController)
    {
        opportunityId = standardController.getId();
       
    }

    public void UpdateRate() {
         Opportunity Oppor= [Select Swap_Rate__c,RecordType__c, Rate_Locked__c, Floor__c, Term_Loan_Type__c,Current_Stage__c 
                       from Opportunity where id = :opportunityId and RecordType__c = 'Term' and Rate_Locked__c = false];
		Swap_Rate__c SwapRate = [select Five_Year_Swap__c,Seven_Year_Swap__c,Ten_Year_Swap__c,Thirty_Year_Swap__c 
                         from Swap_Rate__c order by CreatedDate desc limit 1];
		System.Debug('RS123 SwapRate :' +SwapRate);
        System.Debug('RS Oppor :' +Oppor);
        System.Debug('RS123 Oppor.Term_Loan_Type__c :' +Oppor.Term_Loan_Type__c);
        System.Debug('RS123 Oppor.Floor__c :' +Oppor.Floor__c);
         System.Debug('RS123 SwapRate.Five_Year_Swap__c :' +SwapRate.Five_Year_Swap__c);
        
        if (Oppor.Term_Loan_Type__c == '5 Year')
        {
            if (SwapRate.Five_Year_Swap__c > Oppor.Floor__c)
            {
                Oppor.Swap_Rate__c = SwapRate.Five_Year_Swap__c;
            }
            else
            {
               Oppor.Swap_Rate__c = Oppor.Floor__c;
            }
        }
		update Oppor;        
    }

}
public class dealswapRateUpdate implements Database.Batchable<sObject>{

     public Database.QueryLocator start(Database.BatchableContext BC){
	 String query = 'Select Swap_Rate__c,RecordType__c, Rate_Locked__c, Floor__c, Term_Loan_Type__c,Current_Stage__c,StageName,Interest_Rate_Type__c,Index__c,Index_Floor__c,Index_Margin__c,Other_Index__c,Rate__c,Other_Rate__c ';
     query = query + ' from Opportunity'; 
     query = query + ' where (RecordType__c = \'Term\' and Rate_Locked__c = false and StageName  not in (\'Withdrawn\', \'Rejected\') and Term_Loan_Type__c != NULL) OR ';
     query = query + ' (RecordType__c = \'Bridge\' and Index__c in (\'1M Term SOFR\',\'1M LIBOR\') and Interest_Rate_Type__c = \'Floating\') ';
    //  query = query + ' Limit 1 ';
    // query = query + ' where id in (\'0065b00000tscjPAAQ\',\'0065b00000rtqzCAAQ\',\'0065b00000tvZ3WAAU\', \'0065b00000tvPbiAAE\')';
    // query = query + ' where id in (\'00676000004M5L4AAK\')';
     return Database.getQueryLocator(query);
   }
     
    public void execute(Database.BatchableContext BC, List<opportunity> processingDeals){
     
	List<opportunity> dealsToUpdate = new List<opportunity>();
	Boolean updateOpportunity = false; 
    Boolean validFirstDayData = false;
	Swap_Rate__c swapRate = [select Five_Year_Swap__c,Seven_Year_Swap__c,Ten_Year_Swap__c,Thirty_Year_Swap__c,OneM_LIBOR__c,OneM_SOFR__c,CreatedDateTime__c from Swap_Rate__c where CreatedDateTime__c != null order by CreatedDateTime__c desc limit 1];                           
    Integer mnth = System.Today().MOnth();
    Integer yr = System.Today().Year(); 
	List<Swap_Rate__c> swapRateMinForMonth = [Select ID,CreatedDateTime__c from Swap_Rate__c where CreatedDateTime__c <= Today 
                                        		and CALENDAR_MONTH(CreatedDate) = :mnth and CALENDAR_YEAR(CreatedDate) = :yr order by CreatedDateTime__c asc limit 1 ];
        
       
    if (swapRateMinForMonth.size() > 0)
    {
        Date firstDateOfMonth = swapRateMinForMonth[0].CreatedDateTime__c.Date();
        Date currentProcessingRecordDate = swapRate.CreatedDateTime__c.Date();
		System.debug('RS999 firstDateOfMonth : ' +firstDateOfMonth);        
		System.debug('RS999 currentProcessingRecordDate : ' +currentProcessingRecordDate);           
        if (firstDateOfMonth == currentProcessingRecordDate)
        {
			validFirstDayData = True;
            System.debug('RS999 validFirstDayData : ' +validFirstDayData);             
        }
    }
  

	System.Debug('RS999 swapRate :' +swapRate);
	System.Debug('RS999 swapRateMinForMonth :' +swapRateMinForMonth);        
         
     for(opportunity Oppor : processingDeals){
 
     if (Oppor.RecordType__c == 'Term')
     {
        decimal floor; 
		if (Oppor.Floor__c != null)
            floor = Oppor.Floor__c;
        else
            floor = 0;
         
       switch on Oppor.Term_Loan_Type__c {
       when '5 Year' {
           if (swapRate.Five_Year_Swap__c != null)
           {
           if (swapRate.Five_Year_Swap__c > floor)
           {
               Oppor.Swap_Rate__c = swapRate.Five_Year_Swap__c;
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
           if (swapRate.Seven_Year_Swap__c != null)
           {
           if (swapRate.Seven_Year_Swap__c > floor )
           {
               Oppor.Swap_Rate__c = swapRate.Seven_Year_Swap__c;
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
           if (swapRate.Ten_Year_Swap__c != null )
           {
           if (swapRate.Ten_Year_Swap__c > floor)
           {
               Oppor.Swap_Rate__c = swapRate.Ten_Year_Swap__c;
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
		   if (swapRate.Thirty_Year_Swap__c != null)
           {
           if (swapRate.Thirty_Year_Swap__c > floor)
           {
               Oppor.Swap_Rate__c = swapRate.Thirty_Year_Swap__c;
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
     } //term if
     
 	System.Debug('RS999 Oppor.RecordType__c  :' +Oppor.RecordType__c );        
 	System.Debug('RS999 Oppor.Current_Stage__c  :' +Oppor.Current_Stage__c );           
 	System.Debug('RS999 swapRate.OneM_SOFR__c   :' +swapRate.OneM_SOFR__c  );           
 	System.Debug('RS999 swapRate.OneM_LIBOR__c  :' +swapRate.OneM_LIBOR__c  );            
 	System.Debug('RS999 Oppor.Index__c   :' +Oppor.Index__c  );           
     if (Oppor.RecordType__c == 'Bridge')
     {
         if (Oppor.Current_Stage__c != 'Closed Won' )
         {
         if (Oppor.Index__c == '1M Term SOFR') 
         {
 			System.Debug('RS999 into Oppor.Other_Rate__c = swapRate.OneM_SOFR__c');               
            Oppor.Other_Rate__c = swapRate.OneM_SOFR__c;  
            updateOpportunity = True;             
         }
         if (Oppor.Index__c == '1M LIBOR') 
         {
 			System.Debug('RS999 into  Oppor.Other_Rate__c = swapRate.OneM_LIBOR__c');               
            Oppor.Other_Rate__c = swapRate.OneM_LIBOR__c;     
            updateOpportunity = True;             
         }   
         }
         Else
         {
             if (Oppor.Current_Stage__c == 'Closed Won' && validFirstDayData)
     		 {
                 if (Oppor.Index__c == '1M Term SOFR') 
                 {
 					System.Debug('RS999 into  Oppor.Other_Rate__c = swapRate.OneM_SOFR__c');                      
                    Oppor.Other_Rate__c = swapRate.OneM_SOFR__c;  
              		updateOpportunity = True;                     
                 }
                 if (Oppor.Index__c == '1M LIBOR') 
                 {
 					System.Debug('RS999 into  Oppor.Other_Rate__c = swapRate.OneM_LIBOR__c');                      
                    Oppor.Other_Rate__c = swapRate.OneM_LIBOR__c;          
              		updateOpportunity = True;                     
                 } 
             }
             
             
         }
		
         if (Oppor.Interest_Rate_Type__c == 'Floating')    
         {
             Decimal indexMargin;
             Decimal indexFloor;
             Decimal otherRate;
             if (Oppor.Index_Floor__c != null) 
             {
               indexFloor = Decimal.Valueof(Oppor.Index_Floor__c.replace('%',''));
             }
             else
             {
               indexFloor = 0;  
             }
             
             if (Oppor.Other_Rate__c != null)
             {
                 otherRate = Oppor.Other_Rate__c;
             }
             else
             {
               otherRate = 0;  
             }
                 

             if (Oppor.Index_Margin__c != null)
             {
              indexMargin = Oppor.Index_Margin__c;
             }
             else
             {
             indexMargin = 0;
             }  
             
             
             System.Debug('RS999 indexFloor :' +indexFloor);
             if (otherRate >= indexFloor)
             {
 			 System.Debug('RS999 into  Oppor.Rate__c = otherRate + indexMargin;'); 
             Oppor.Rate__c = otherRate + indexMargin;
             updateOpportunity = True;                   
             }
             Else
             {
			 System.Debug('RS999 into  Oppor.Rate__c = indexFloor + indexMargin'); 
             Oppor.Rate__c = indexFloor + indexMargin;
             updateOpportunity = True;                   
             }
         }
     } //Bridge if
         
      if (updateOpportunity)
      {
       dealsToUpdate.add(Oppor);
       updateOpportunity = False;
      }  
         
     } //for

       system.debug('dealsToUpdate :' +dealsToUpdate);
                    
	if (dealsToUpdate.size() > 0)
	{
    //    try 
    //    {
       // update dealsToUpdate;
        database.update(dealsToUpdate ,false);
     //   } 
      /*  catch (DmlException e)
        {
        System.debug( 'Error updating Swap Rates on deal' + e.getMessage());
        }     */           
	}
	} //method

   public void finish(Database.BatchableContext BC){
              system.debug('finish:' );
   }
    
}
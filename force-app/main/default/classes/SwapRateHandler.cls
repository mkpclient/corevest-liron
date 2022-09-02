global class SwapRateHandler implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    string rateerror = '';
    Decimal rate_5;
    Decimal rate_7;
    Decimal rate_10;
    Decimal rate_30;
    Decimal rate_1M;
    Decimal rate_1S;      
    Boolean rate_5_valid = false;
    Boolean rate_7_valid = false;
    Boolean rate_10_valid = false;
    Boolean rate_30_valid = false;
    Boolean rate_1ML_valid = false;
    Boolean rate_1SF_valid = false;      

   String emailsubject = email.subject.normalizeSpace().toLowerCase();
   String emailBody = email.plainTextBody.toLowerCase();   
    
    List<String> emailBodyLines = emailBody.split('\n');        
	Integer indexRate = 0;
        
    for(string emailLine : emailBodyLines)
    {

        indexRate = emailLine.indexOf('5yr:', 0);
        if (indexRate != -1 && !rate_5_valid )
        {
		String  rate_5yr = getRate(emailLine,'5yr:');

        if (rate_5yr == 'Error')
        {
           rateerror = rateerror + 'Invalid 5 years rate :';
        }
        Else
        {
         rate_5_valid = True;
         try {    
               rate_5 = Decimal.valueOf(rate_5yr.trim());
             }
         catch (TypeException e) 
             {
                rate_5_valid = False;  
            }            
        }
        }
        
        indexRate = emailLine.indexOf('7yr:', 0);
        if (indexRate != -1 && !rate_7_valid )
        {
		String  rate_7yr = getRate(emailLine,'7yr:');

        if (rate_7yr == 'Error')
        {
           rateerror = rateerror + 'Invalid 7 years rate :';
        }
        Else
        {
        rate_7_valid = True;
         try {    
               rate_7 = Decimal.valueOf(rate_7yr.trim());
             }
         catch (TypeException e) 
             {
                rate_7_valid = False;  
            }                
        }            
        }
        
        indexRate = emailLine.indexOf('10yr:', 0);
        if (indexRate != -1 && !rate_10_valid )
        {
		String  rate_10yr = getRate(emailLine,'10yr:');

        if (rate_10yr == 'Error')
        {
           rateerror = rateerror + 'Invalid 10 years rate :';
        }
        Else
        {
        rate_10_valid = True;
         try {    
               rate_10 = Decimal.valueOf(rate_10yr.trim());
             }
         catch (TypeException e) 
             {
                rate_10_valid = False;  
            }             
        }            
        }
        
        indexRate = emailLine.indexOf('30yr:', 0);
        if (indexRate != -1 && !rate_30_valid )
        {
		String  rate_30yr = getRate(emailLine,'30yr:');

        if (rate_30yr == 'Error')
        {
           rateerror = rateerror + 'Invalid 30 years rate :';
        }
        Else
        {
        rate_30_valid = True;
         try {    
               rate_30 = Decimal.valueOf(rate_30yr.trim());
             }
         catch (TypeException e) 
             {
                rate_30_valid = False;  
            }             
        }             

        }      
        
        indexRate = emailLine.indexOf('1m libor:', 0);
        if (indexRate != -1 && !rate_1ML_valid )
        {
		String  rate_1ML = getRate(emailLine,'1m libor:');

        if (rate_1ML == 'Error')
        {
           rateerror = rateerror + 'Invalid 1 Month Libor :';
        }
        Else
        {
        rate_1ML_valid = True;
         try {    
               rate_1M = Decimal.valueOf(rate_1ML.trim());
             }
         catch (TypeException e) 
             {
                rate_1ML_valid = False;  
            }             
        }             

        }         

        indexRate = emailLine.indexOf('1m term sofr swap:', 0);
        if (indexRate != -1 && !rate_1SF_valid )
        {
		String  rate_1SF = getRate(emailLine,'1m term sofr swap:');

        if (rate_1SF == 'Error')
        {
           rateerror = rateerror + 'Invalid 1 Month Term Soft Swap rate :';
        }
        Else
        {
        rate_1SF_valid = True;
         try {    
               rate_1S = Decimal.valueOf(rate_1SF.trim());
             }
         catch (TypeException e) 
             {
                rate_1SF_valid = False;  
            }             
        }             

        }
        
    }
    Swap_Rate__c S = new Swap_Rate__c();
    if (rate_5_valid)
      S.Five_Year_Swap__c = rate_5;
    else
      S.Five_Year_Swap__c = null;
    if (rate_7_valid)
      S.Seven_Year_Swap__c = rate_7;
    else
      S.Seven_Year_Swap__c = null;
    if (rate_10_valid)
      S.Ten_Year_Swap__c = rate_10;
    else
      S.Ten_Year_Swap__c = null;
    if (rate_30_valid)
      S.Thirty_Year_Swap__c = rate_30;
    else
      S.Thirty_Year_Swap__c = null;
    if (rate_1ML_valid)
      S.OneM_LIBOR__c = rate_1M;
    else
      S.OneM_LIBOR__c = null; 
    if (rate_1SF_valid)
      S.OneM_SOFR__c = rate_1S;
    else
      S.OneM_SOFR__c = null;        

    S.CreatedDateTime__c = DateTime.now();
    Date createdate = date.today();
   
    if (rate_5_valid && rate_7_valid && rate_10_valid && rate_30_valid  && rate_1ML_valid && rate_1SF_valid)
    {
            
            List<Swap_Rate__c> todaysswaprate = [select id from Swap_Rate__c where Five_Year_Swap__c = :rate_5 and Seven_Year_Swap__c =:rate_7 
                                                  and Ten_Year_Swap__c =:rate_10 and Thirty_Year_Swap__c = :rate_30 
                                                  and OneM_LIBOR__c = :rate_1M and OneM_SOFR__c = :rate_1S and CreatedDateTime__c = TODAY];
        
            if (todaysswaprate.size() == 0)
            {        
                try {
    				if (rate_5_valid && rate_7_valid && rate_10_valid && rate_30_valid  && rate_1ML_valid && rate_1SF_valid)                     
                    {
                    	insert S;
                    	dealSwapRateUpdate updateDeal = new dealSwapRateUpdate();
       					Id batchId = Database.executeBatch(updateDeal, 25);
                    }
                    Else
                    {
            			System.debug(' rateerror : ' + rateerror);
            			sendEmailMessage(email, rateerror);                        
                    }
                } catch (DmlException e) {
                    System.debug('Error Inserting Swap Rates' + e.getMessage());
                }
                
        
            }
    }
    else 
    {
            System.debug(' rateerror : ' + rateerror);
            sendEmailMessage(email, rateerror);
     }
        
    return new Messaging.InboundEmailResult();
  } //method

//////////////////////////////////////////////////////////////////////////
    
Private String getRate(String emailLine,String searchRateString)
 {
     String returnValue;
     
    
     returnValue = emailLine.normalizeSpace().substringBetween(searchRateString, '(');

     
     if (returnValue == null)
     {
	//emailLine= emailLine.substring(emailLine.indexOf(searchRateString, 0)+searchRateString.length(),emailLine.length());
	emailLine= emailLine.substring(emailLine.indexOf(searchRateString, 0)+searchRateString.length(),emailLine.indexOf(searchRateString, 0)+searchRateString.length()+5);

    	if (emailLine != Null)     
    	{
        String  rate_sub = emailLine.deleteWhitespace();
           
		String  rate_subdot = rate_sub.remove('.');            

            if (rate_subdot.isNumeric())
            {

             rate_sub = rate_sub.rightPad(5);

             String rate_ret;
             For (integer i = 0;i <= 4;i++)  
              {

                  if (rate_sub.substring(i,i+1).isNumeric())
                  {

                        if (rate_ret== null)
                        {
                        rate_ret=   rate_sub.substring(i,i+1);                    
                        }
                        Else
                        {
                        rate_ret=  rate_ret + rate_sub.substring(i,i+1);
        
                        }
                  }
                  else
                  {
                      if (rate_sub.substring(i,i+1) == '.')
                        {

                            if (rate_ret != null)
                            {
                            rate_ret=  rate_ret+ rate_sub.substring(i,i+1);
                            }
                            Else
                            {
                             rate_ret=  rate_sub.substring(i,i+1);   
                            }
        
                        }          
                  }              
              }
              returnValue = rate_ret;
            }
        }         
     }
     
     if (returnValue == null)
     {
         returnValue = 'Error';
     }

     Return returnValue;
 }

//////////////////////////////////////////////////////////////////////////    

    public static void sendEmailMessage(
    Messaging.InboundEmail email,
    String rateerror
  ) {
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    OrgWideEmailAddress[] owea = [
      SELECT Id
      FROM OrgWideEmailAddress
      WHERE DisplayName = 'Integrations User'
    ];
    message.ToAddresses = new List<String>{
     'support@cvest.com',email.fromAddress
    };
   // message.CcAddresses = ccAddresses;
    message.subject = 'Errors found in the Swap Rate Email from ' + date.today();
    message.plainTextBody = 'Following errors were found in the Swap Rate Email. \n \n';
    message.plainTextBody = message.plainTextBody + rateerror;
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
    message
    };
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

    if (results[0].success) {
      System.debug('The email was sent successfully.');
    } else {
      System.debug('The email failed to send: ' + results[0].errors[0].message);
    }
  }
}
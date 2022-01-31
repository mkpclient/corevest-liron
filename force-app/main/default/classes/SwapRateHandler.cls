global class SwapRateHandler implements Messaging.InboundEmailHandler {
    
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
   	string rateerror;
	Decimal rate_5;
	Decimal rate_7;
	Decimal rate_10;
	Decimal rate_30;
	Boolean rate_5_valid = false;
	Boolean rate_7_valid= false;
	Boolean rate_10_valid= false;
	Boolean rate_30_valid= false;      
      
   	String emailBody = email.plainTextBody.normalizeSpace().toLowerCase();
      
   	String rate_5yr = emailBody.substringBetween('5yr:', '(').normalizeSpace();
      
	System.debug(  'rate_5yr  : '   +rate_5yr);

    if (!string.isBlank(rate_5yr))
    {
        
		String rate_5yr_ns = rate_5yr.replace(' ','');
        if (isNumericOrDecimal(rate_5yr_ns))
        {
        rate_5  = Decimal.ValueOf(rate_5yr);
        rate_5_valid = true;
        }
        else
        {
        rateerror = 'Invalid 5 years rate :' +rate_5yr;
        } 
    }
    else
    {
    rateerror = 'Invalid 5 years rate :' +rate_5yr;
    }          

	String rate_7yr = emailBody.substringBetween('7yr:', '(').normalizeSpace();      
 	if (!string.isBlank(rate_7yr))
    {
        
		String rate_7yr_ns = rate_7yr.replace(' ','');
        if (isNumericOrDecimal(rate_7yr_ns))
        {
        rate_7  = Decimal.ValueOf(rate_7yr);
        rate_7_valid = true;
        }
        else
        {
        rateerror = rateerror + 'Invalid 7 years rate :' +rate_7yr;
        } 
    }
    else
    {
    rateerror = rateerror + 'Invalid 7 years rate :' +rate_7yr;
    }   

	String rate_10yr = emailBody.substringBetween('10yr:', '(').normalizeSpace();      
 	if (!string.isBlank(rate_10yr))
    {
        
		//String rate_10yr_ns = removespaces(rate_10yr);
        String rate_10yr_ns = rate_10yr.replace(' ','');
        if (isNumericOrDecimal(rate_10yr_ns))
        {
        rate_10  = Decimal.ValueOf(rate_10yr);
        rate_10_valid = true;
        }
        else
        {
        rateerror = rateerror + 'Invalid 10 years rate :' +rate_10yr;
        } 
    }
    else
    {
    rateerror = rateerror + 'Invalid 10 years rate :' +rate_10yr;
    }         

	String rate_30yr = emailBody.substringBetween('30yr:', '(').normalizeSpace();      
 	if (!string.isBlank(rate_30yr))
    {
        
		//String rate_30yr_ns = removespaces(rate_30yr);
        String rate_30yr_ns = rate_30yr.replace(' ','');
        if (isNumericOrDecimal(rate_30yr_ns))
        {
        rate_30  = Decimal.ValueOf(rate_30yr);
        rate_30_valid = true;
        }
        else
        {
        rateerror = rateerror + 'Invalid 30 years rate :' +rate_30yr;
        } 
    }
    else
    {
    rateerror = rateerror + 'Invalid 30 years rate :' +rate_30yr;
    }       
      
	if(rate_5_valid && rate_7_valid && rate_10_valid && rate_30_valid)
    {
    Swap_Rate__c S = new Swap_Rate__c();
    S.Five_Year_Swap__c =  rate_5;
    S.Seven_Year_Swap__c =  rate_7;
    S.Ten_Year_Swap__c =  rate_10;
    S.Thirty_Year_Swap__c =  rate_30;
    S.CreatedDateTime__c = DateTime.now();
        try 
        {
        Insert S;
        } 
        catch (DmlException e)
        {
        System.debug( 'Error Inserting Swap Rates' + e.getMessage());
        }          
  	}
	else
	{
	System.debug(' rateerror : ' +rateerror);
	}
      
      dealSwapRateUpdate updateDeal = new dealSwapRateUpdate(); 
	  Id batchId = Database.executeBatch(updateDeal,25);

	return new Messaging.InboundEmailResult();      
    
	} //method
    
    public Boolean isNumericOrDecimal(String s)
    {
        system.debug('Rs123 s :' +s);        
        if(s == null) return false;
        else if(s.contains('.') && s.indexOf('.') == s.lastIndexOf('.'))
            s = s.replace('.','');
        system.debug('rs123 s :' +s + ' ' +s.isNumeric());
        return s.isNumeric();
    } 
    
    
}
global class DrawAdvanceProcessHandler implements Messaging.InboundEmailHandler {
    
List<Task> taskList = new List<Task>();      
Map<string,Task> taskMap = new Map<string,Task>();
Settings__mdt settings 	= Settings__mdt.getInstance('Universal_Settings');
id bridgeCustodinUserId = settings.Bridge_Cptl_Market_Post_Closing_Custodin__c;
id termCustodinUserId 	= settings.Term_Captl_Markets_Post_Closing_Custodin__c;
//string returnemails		= settings.Capital_Markets_Post_Closing_return_emai__c;
Boolean errorsFound = False;   
String errorString = '';    
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
	System.Debug('RS999 Start email' );
    String emailsubject = email.subject.normalizeSpace().toLowerCase();
    if (emailsubject.startsWithIgnoreCase('re:') || emailsubject.startsWithIgnoreCase('fw:')) 
    {
        errorsFound = True;
        errorString = 'Replied or Forwarded email cannot be processed';
    }
    else
    {
    String emailBody = email.plainTextBody.normalizeSpace().toLowerCase();
	Messaging.InboundEmail.TextAttachment[] tAttachments = email.textAttachments;
    Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;
    System.Debug('RS999 tAttachments :' +tAttachments );  
    System.Debug('RS999 bAttachments :' +bAttachments ); 
	String csvbody='';   
    if(bAttachments !=null)
    {
    Boolean allAttachedFilesAreValidCsvs = True;
    for(Messaging.InboundEmail.BinaryAttachment btt : bAttachments)
    {
        if(!btt.filename.endsWithIgnoreCase('.csv'))
     	{
            allAttachedFilesAreValidCsvs = False;
            System.Debug('RS999 - not a csv file');
        	errorsFound = True;
        	errorString = 'Only CSV files name starting with bridge or term will be processed';  
        }
    } 
    
    if (allAttachedFilesAreValidCsvs)
    {
    for(Messaging.InboundEmail.BinaryAttachment btt : bAttachments)
    {
/////////////////////////Process Bridge file        
        System.debug('RS999 this looks like a binary attachment :' +btt.filename); 
     	if(btt.filename.startsWithIgnoreCase('bridge') && btt.filename.endsWithIgnoreCase('.csv'))
     	{
    	csvbody = btt.body.toString();
       	List<String> fileLineList = csvbody.split('\r\n');
        System.Debug('RS999 bridgeDraws : ' +fileLineList.size()); 
        Boolean validHeaderLineFound = False;
        Boolean validBridgeLineFound = False;
        String errorStringfile = '\n Bridge File :';    
        List<String> fileHeaderLine;
            for(integer i = 0;i <fileLineList.size();i++)              
            {
            	String reformatedLine = ReformatLine(fileLineList[i]);
            	List<String> fileLineFields =  reformatedLine.split(',');                
                System.Debug('RS999 fileLineFields.size : ' +fileLineFields.size());
                System.Debug('RS999 fileLineFields : ' +fileLineFields);                
                if (fileLineFields.size() >= 8 && validHeaderLineFound)
                {
                   id validAdvanceId = null;
                   System.Debug('RS999 fileLineFields[8] : ' +fileLineFields[8] );
                   if (fileLineFields[8] != null)
                   {
                   validBridgeLineFound = True;
                   System.Debug('RS999 Calling validateAdvance :');
                   validAdvanceId =  ValidateAdvance(fileLineFields[0],fileLineFields[8]); //Validate Advance and deal id(loan idamazon)
                   }
                   System.Debug('RS999 returned validAdvanceId : ' +validAdvanceId);
                   if (validAdvanceId != null)
                   {
                    String description ='';
                    integer noOfColumns;
                    
                     if (fileHeaderLine.size() < fileLineFields.size()) 
                     {
                         noOfColumns = fileHeaderLine.size();
                     }
                     else
                     {
                        noOfColumns = fileLineFields.size(); 
                     }
                       
                    for(integer j = 0;j<noOfColumns;j++)
                    {
                        description = fileHeaderLine[j] + ' : ' + fileLineFields[j] + ';\n' + description;
                    }                   
                   CreateTask('B',fileLineFields[0],fileLineFields[8],bridgeCustodinUserId,validAdvanceId,description); //Create a task if valid asset;
                   }
                   Else
                   {
                      errorsFound = True;
                      errorString = 'Invalid Deal/Advance Id = ' + fileLineFields[0] + ' : ' + fileLineFields[8] + '; ' + errorString;
                   }
                }
                
                if (fileLineFields.size() >= 8 && validHeaderLineFound == False)
                {
					System.Debug('RS999 fileLineFields[0] :' + fileLineFields[0]);
					System.Debug('RS999 fileLineFields[8] :' + fileLineFields[8]);                    
                    if (fileLineFields[0] == 'Loan ID' && fileLineFields[8] == 'Advance #')
                    {
                        System.Debug('RS999 Into Valid Header line found bridge');
                        validHeaderLineFound = True; 
                       	fileHeaderLine = fileLineFields;
                    }
                } 
            } //Lines loop - For
        
        if (validBridgeLineFound == False )
        {
           errorsFound = True;
           errorString = 'No Valid Line found in Bridge File' ;
        }
        if (errorsFound) errorString = errorStringfile + errorString;
		System.Debug('RS999 Binary csvbody :' +csvbody);
    	} // Bridge Attachement - if

/////////////////////////Process Term file
     	if(btt.filename.startsWithIgnoreCase('term') && btt.filename.endsWithIgnoreCase('.csv'))
     	{
    	csvbody = btt.body.toString();
       	List<String> fileLineList = csvbody.split('\r\n');
        System.Debug('RS999 termDraws : ' +fileLineList.size()); 
        Boolean validHeaderLineFound = False;
        Boolean validTermLineFound = False;            
        String errorStringfile = 'Term File : ';                
        List<String> fileHeaderLine;
        for(integer i = 0;i < fileLineList.size();i++)              
        {
            String reformatedLine = ReformatLine(fileLineList[i]);
            List<String> fileLineFields =  reformatedLine.split(','); 
            System.Debug('RS999 term fileLineFields : ' +fileLineFields.size());
            System.Debug('RS999 term fileLineFields : ' +fileLineFields);            
            if (fileLineFields.size() >= 0 && validHeaderLineFound)
            {
               id validDealId = null;
               if (fileLineFields[0] != null)
               {
				System.Debug('RS999 term ValidateLoanID fileLineFields[0]  : ' +fileLineFields[0] );  
               validTermLineFound = True; 
               validDealId =  ValidateLoanID(fileLineFields[0]); //Validate loan id
               }
               System.Debug('RS999 term returned validDealId : ' +validDealId);
               if (validDealId != null)
               {
                String description ='';
 				integer noOfColumns;
                    
                   if (fileHeaderLine.size() < fileLineFields.size()) 
                   {
                       noOfColumns = fileHeaderLine.size();
                   }
                   else
                   {
                       noOfColumns = fileLineFields.size(); 
                   }
                       
                for(integer j = 0;j<noOfColumns;j++)
                {
                    description = fileHeaderLine[j] + ' : ' + fileLineFields[j] + ';\n' + description;
					//description = fileLineFields[j] + ';' + description;
                }                   
                CreateTask('T',fileLineFields[0],'',termCustodinUserId,validDealId,description); //Create a task if valid asset;
               }
               Else
               {
                  errorsFound = True;
				  errorString = 'Invalid Loan Id = ' + fileLineFields[0] + '; ' + errorString;
               }
            }
             System.Debug('RS999 term fileLineFields[0]  : ' +fileLineFields[0] );
            
            if (fileLineFields.size() >= 2 && validHeaderLineFound == False)
            {
                if (fileLineFields[0] == 'Loan ID')
                {
             		System.Debug('RS999 term into valid load id term file: ');
                    validHeaderLineFound = True; 
                    fileHeaderLine = fileLineFields;
                }
            } 
        } //Lines loop - For
		System.Debug('RS999 Binary csvbody :' +csvbody);
        if (validTermLineFound == False )
        {
           errorsFound = True;
           errorString = 'No Valid Line found in Bridge File' ;
        }            
		if (errorsFound) errorString = errorStringfile + errorString;
    	} // Term Attachement - if
    }//Main attachement - for
    } // not valid CSV files  
        
    } //are there any attachements - if   
        
		if(!errorsFound && taskMap.size()>0) 
        {
            For(id id :taskMap.keySet())
            {
                taskList.add(taskMap.get(id));
            }
         if (taskList.size() > 0)    insert taskList;  
        }
                   
        System.Debug('RS999 taskList :' +taskList);  
        
    } // else of RE or FD emails

    if (errorsFound)
    {      
     sendEmailMessage(email, errorString);
    }
    return new Messaging.InboundEmailResult();
  } //method

    
id ValidateLoanID(string loanID) 
{
    if (!string.isBlank(loanID))
    {
    List<Opportunity> validLoadDeal = [SELECT Id FROM opportunity where Deal_Loan_Number__c = :loanID];
    System.Debug('RS999 validLoadDeal :' +validLoadDeal);    
    if (validLoadDeal.size() > 0)
    {
        return validLoadDeal[0].id;
    }
    }
    return null;
}    
    
id ValidateAdvance(string loanID,string advance)    
{
    System.Debug('RS999 passed loanID :' +loanID);
    System.Debug('RS999 passed advance :' +advance);  
    if (!String.isblank(loanID) && !String.isBlank(advance))
    {
    Integer advanceNo = 0;
    if (advance.isNumeric()) advanceNo = Integer.valueOf(advance);
 	List<Opportunity> validLoadDeal = [SELECT Id FROM opportunity where Deal_Loan_Number__c = :loanID];
    List<Advance__c> validAdvance = [SELECT Id FROM Advance__c where Advance_Num__c = :advanceNo and deal__c = :validLoadDeal[0].id];
    System.Debug('RS999 validAdvance :' +validAdvance);
    if (validAdvance.size() > 0)
    {
        Return validAdvance[0].id;
    }
   }
    return null;
}

String ReformatLine(String currentLine)
{
    String processedLine = '';
    Boolean foundDblQt = False;
    System.Debug('RS999 currentLine : ' +currentLine);
    
    List<string> linecharacters = currentLine.split('');
    
    for (string eachChar :linecharacters )
    {
        System.Debug('RS999 eachChar : ' +eachChar);
        if (eachChar == '"')
        {
          if (foundDblQt)
          {
            foundDblQt = False;   
          }
          else
          {
           foundDblQt = True; 
          }
        System.Debug('RS999 foundDblQt : ' +foundDblQt);            
        }
        
       if (foundDblQt)
       {
         if (eachChar != ',' && eachChar != '"')
         {
           processedLine = processedLine +  eachChar;   
         }
       }
       Else
       {
         if ( eachChar != '"') processedLine = processedLine +  eachChar; 
       }
    System.Debug('RS999 processedLine : ' +processedLine);         
    }
    
    System.Debug('RS999 currentLine Final : ' +currentLine); 
    System.Debug('RS999 processedLine Final : ' +processedLine);      
    Return processedLine;
}
    
void CreateTask(String FileType,String loanId,String advanceID,id ownerId,id whatId,String description)    
{
    System.Debug('RS999 passed loanId 		:' +loanId);    
    System.Debug('RS999 passed AssetId 		:' +advanceID); 
    System.Debug('RS999 passed ownerId 		:' +ownerId); 
    System.Debug('RS999 passed whatId 		:' +whatId); 
    System.Debug('RS999 passed description 	:' +description);     
    
	if (whatId != null)    
    {
	if (!taskMap.containsKey(whatId))
    {
    Task tsk = new Task();
    String Subject;
    
    If (!String.isBlank(loanId))
    {
       Subject = 'Draw Request for Deal #' +  loanId;
    }
    
    if (!String.isBlank(advanceID)) 
    {
        Subject = Subject + ' and Advance No : ' + advanceID;
    }
    tsk.Subject 		= 	 Subject;
    tsk.Status 			= 	'Open';
    tsk.Priority 		= 	'Normal';
    tsk.WhatId 			= 	whatId;
    tsk.OwnerId 		= 	ownerId;
    tsk.ActivityDate 	= 	date.today() + 1;
    tsk.Description 	= 	description;
    tsk.RecordTypeId 	= 	[SELECT Id FROM RecordType WHERE sobjecttype = 'Task' and DeveloperName  = 'Draw_Request'].id;
    taskMap.put(whatId,tsk);
    }        
	Else
    {
        taskMap.Get(whatId).Description = taskMap.Get(whatId).Description + '\n' + '----------------------------------------' + '\n' + Description;
    }        
	}

    
}    
  public static void sendEmailMessage(
    Messaging.InboundEmail email,
    String rateerror) 
  {
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
   // List<String> ccAddresses = email.ccAddresses != null ? email.ccAddresses : new List<String>();
    //List<String> toAddresses = email.toAddresses != null ? email.toAddresses : new List<String>();
  //  message.ToAddresses = new List<String>{'raj.sirivolu@cvest.com'};
    message.ToAddresses = new List<String>{
     // 'support@cvest.com',email.fromAddress
     email.fromAddress
    };        
   // message.CcAddresses = ccAddresses;
    message.subject = 'Errors found in the Draw/Advance Process Email from ' + date.today();
    message.plainTextBody = 'Following errors were found in the Draw/Advance Process Email. \n \n';
    message.plainTextBody = message.plainTextBody + rateerror;
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

    if (results[0].success) {
      System.debug('The email was sent successfully.');
    } else {
      System.debug('The email failed to send: ' + results[0].errors[0].message);
    }
  }
}
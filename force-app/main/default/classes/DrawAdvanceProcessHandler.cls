global class DrawAdvanceProcessHandler implements Messaging.InboundEmailHandler {
    
List<Task> taskList = new List<Task>();      
Map<string,Task> taskMap = new Map<string,Task>();
Settings__mdt settings 	= Settings__mdt.getInstance('Universal_Settings');
id bridgeCustodinUserId = settings.Bridge_Cptl_Market_Post_Closing_Custodin__c;
id termCustodinUserId 	= settings.Term_Captl_Markets_Post_Closing_Custodin__c;
//string returnemails		= settings.Capital_Markets_Post_Closing_return_emai__c;
Boolean errorsFound = False;   
String errorString = '';    
Boolean Custodial_File_Sent_to_Custodian = False;    
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
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
	String csvbody='';   
    if(bAttachments !=null)
    {
    Boolean allAttachedFilesAreValidCsvs = True;
    for(Messaging.InboundEmail.BinaryAttachment btt : bAttachments)
    {
        if(!btt.filename.endsWithIgnoreCase('.csv'))
     	{
            allAttachedFilesAreValidCsvs = False;
        	errorsFound = True;
        	errorString = 'Only CSV files name starting with bridge or term will be processed';  
        }
        Else
        {
            allAttachedFilesAreValidCsvs = True;
        	errorsFound = False;
        	errorString = '';   
            Break;
        }        
    } 
    
    if (allAttachedFilesAreValidCsvs)
    {
    for(Messaging.InboundEmail.BinaryAttachment btt : bAttachments)
    {
/////////////////////////Process Bridge file        
     	if(btt.filename.startsWithIgnoreCase('bridge') && btt.filename.endsWithIgnoreCase('.csv'))
     	{
    	csvbody = btt.body.toString();
       	List<String> fileLineList = csvbody.split('\r\n');
        Boolean validHeaderLineFound = False;
        Boolean validBridgeLineFound = False;
        String errorStringfile = '\n Bridge File :';    
        List<String> fileHeaderLine;
            for(integer i = 1;i <fileLineList.size();i++)              
            {
            	String reformatedLine = ReformatLine(fileLineList[i]);
            	List<String> fileLineFields =  reformatedLine.split(',');                
              
                if (fileLineFields.size() >= 10 && validHeaderLineFound)
                {
                 if (fileLineFields[10] == 'Y')
                 {
                   id validAdvanceId = null;
                   if (fileLineFields[8] != null)
                   {
                   validBridgeLineFound = True;
                   Custodial_File_Sent_to_Custodian = False;
                   validAdvanceId =  ValidateAdvance(fileLineFields[0],fileLineFields[8]); //Validate Advance and deal id(loan idamazon)
                   }
                   if (validAdvanceId != null && Custodial_File_Sent_to_Custodian == False)
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
                      if (Custodial_File_Sent_to_Custodian == False)
                      {
                      errorsFound = True;
                      errorString = 'Invalid Deal/Advance Id = ' + fileLineFields[0] + ' : ' + fileLineFields[8] + '; ' + errorString;
                      }
                   }
                } //if (fileLineFields[10] == 'Y')
                } //if (fileLineFields.size() >= 10 && validHeaderLineFound)
                
                if (fileLineFields.size() >= 10 && validHeaderLineFound == False)
                {
                  
                    if (fileLineFields[0] == 'Loan ID' && fileLineFields[8] == 'Advance #')
                    {
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
    	} // Bridge Attachement - if

/////////////////////////Process Term file
     	if(btt.filename.startsWithIgnoreCase('term') && btt.filename.endsWithIgnoreCase('.csv'))
     	{
    	csvbody = btt.body.toString();
       	List<String> fileLineList = csvbody.split('\r\n');
        Boolean validHeaderLineFound = False;
        Boolean validTermLineFound = False;            
        String errorStringfile = 'Term File : ';                
        List<String> fileHeaderLine;
        for(integer i = 1;i < fileLineList.size();i++)              
        {
            String reformatedLine = ReformatLine(fileLineList[i]);
            List<String> fileLineFields =  reformatedLine.split(','); 
          
            if (fileLineFields.size() >= 0 && validHeaderLineFound)
            {
               id validDealId = null;
               if (fileLineFields[0] != null)
               {
               validTermLineFound = True; 
               validDealId =  ValidateLoanID(fileLineFields[0]); //Validate loan id
               }
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
            
            if (fileLineFields.size() >= 2 && validHeaderLineFound == False)
            {
                if (fileLineFields[0] == 'Loan_ID')
                {
                    validHeaderLineFound = True; 
                    fileHeaderLine = fileLineFields;
                }
            } 
        } //Lines loop - For
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
                   
        System.Debug('taskList :' +taskList);  
        
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
    if (validLoadDeal.size() > 0)
    {
        return validLoadDeal[0].id;
    }
    }
    return null;
}    
    
id ValidateAdvance(string loanID,string advance)    
{

    if (!String.isblank(loanID) && !String.isBlank(advance))
    {
    Integer advanceNo = 0;
    if (advance.isNumeric()) advanceNo = Integer.valueOf(advance);
 	List<Opportunity> validLoadDeal = [SELECT Id FROM opportunity where Deal_Loan_Number__c = :loanID];
       
    if (validLoadDeal.size() > 0)
    {
     
    List<Advance__c> validAdvance = [SELECT Id,Custodial_File_Sent_to_Custodian__c FROM Advance__c where Advance_Num__c = :advanceNo and deal__c = :validLoadDeal[0].id];
    
    if (validAdvance[0].Custodial_File_Sent_to_Custodian__c != Null)
    {
        Custodial_File_Sent_to_Custodian = True;
    }
    Else
    {
       Custodial_File_Sent_to_Custodian = False; 
    }
    if (validAdvance.size() > 0)
    {
        Return validAdvance[0].id;
    }
    }
   }
    return null;
}

String ReformatLine(String currentLine)
{
    String processedLine = '';
    Boolean foundDblQt = False;
   
    List<string> linecharacters = currentLine.split('');
    
    for (string eachChar :linecharacters )
    {
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
    }
    
    Return processedLine;
}
    
void CreateTask(String FileType,String loanId,String advanceID,id ownerId,id whatId,String description)    
{
     
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
  //  message.ToAddresses = new List<String>{'raj.sirivolu@cvest.com'};
    message.ToAddresses = new List<String>{
     // 'support@cvest.com',email.fromAddress
     email.fromAddress
    };        
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
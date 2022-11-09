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
    String bridgeSubjectLine1='';    
    String bridgeSubjectLine2='';     
    String termeSubjectLine='';
    String termeSubjectLine2='';
    List<DrawAdvance_File_Data__c> listDAFileData = new List<DrawAdvance_File_Data__c>();

      global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email,
        Messaging.InboundEnvelope envelope
      ) {
        String emailsubject = email.subject.normalizeSpace().toLowerCase();
        if (emailsubject.startsWithIgnoreCase('re:') || emailsubject.startsWithIgnoreCase('fw:')) 
        {
           // errorsFound = True;
           // errorString = 'Replied or Forwarded email cannot be processed';
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
                        if (fileLineFields[0] != Null )
                        {
                        validBridgeLineFound = True;
                        DrawAdvance_File_Data__c dAFileData = new DrawAdvance_File_Data__c();
                        dAFileData.File_Name__c = btt.filename;
                        dAFileData.File_From_Bridge_Term__c = 'Bridge';
                        dAFileData.Field_Line_Value__c = reformatedLine;
                        dAFileData.Field_Loan_ID__c = fileLineFields[0];		
                        dAFileData.Field_Advance_Num__c = fileLineFields[8];
                        dAFileData.From_Email__c = email.fromAddress;
                        if (fileLineFields[10] == 'Y') 
                        {
                        dAFileData.Create_Task__c = True ;
                        }
                        else
                        { 
                        dAFileData.Create_Task__c = False;
                        }
                        dAFileData.Line_Type__c = 'D';
                        listDAFileData.add(dAFileData);
                        } //(fileLineFields[0] != Null && fileLineFields[8] != Null)
                    } //if (fileLineFields.size() >= 10 && validHeaderLineFound)
                    
                    if (fileLineFields.size() >= 10 && validHeaderLineFound == False)
                    {
                        if (fileLineFields[0] == 'Loan ID' && fileLineFields[8] == 'Advance #')
                        {
                            validHeaderLineFound = True; 
                            fileHeaderLine = fileLineFields;
                            DrawAdvance_File_Data__c dAFileData = new DrawAdvance_File_Data__c();
                            dAFileData.File_Name__c = btt.filename;
                            dAFileData.File_From_Bridge_Term__c = 'Bridge';
                            dAFileData.Field_Line_Value__c = reformatedLine;
                            dAFileData.From_Email__c = email.fromAddress;
                            dAFileData.Line_Type__c = 'H';
                            listDAFileData.add(dAFileData);                            
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
                   DrawAdvance_File_Data__c dAFileData = new DrawAdvance_File_Data__c();
                   dAFileData.File_Name__c = btt.filename;
                   dAFileData.File_From_Bridge_Term__c = 'Term';
                   dAFileData.Field_Line_Value__c = reformatedLine;
                   dAFileData.Field_Loan_ID__c = fileLineFields[0];		
                   dAFileData.Line_Type__c = 'D';
                   dAFileData.From_Email__c = email.fromAddress; 
                   dAFileData.Create_Task__c = True ;                   
                   listDAFileData.add(dAFileData);
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
                        validHeaderLineFound = True; 
                        fileHeaderLine = fileLineFields;
                        DrawAdvance_File_Data__c dAFileData = new DrawAdvance_File_Data__c();
                        dAFileData.File_Name__c = btt.filename;
                        dAFileData.File_From_Bridge_Term__c = 'Term';
                        dAFileData.Field_Line_Value__c = reformatedLine;
                        dAFileData.From_Email__c = email.fromAddress;                        
                        dAFileData.Line_Type__c = 'H';
                        listDAFileData.add(dAFileData);                         
                    }
                } 
            } //Lines loop - For
    
            if (validTermLineFound == False )
            {
               errorsFound = True;
               errorString = 'No Valid Line found in Term File' ;
            }            
            if (errorsFound) errorString = errorStringfile + errorString;
            } // Term Attachement - if
        }//Main attachement - for
        } // not valid CSV files  
        } //are there any attachements - if   
            
            if(!errorsFound ) 
            {
                List<DrawAdvance_File_Data__c> listDAFileDataDel = [Select id from DrawAdvance_File_Data__c];
                delete listDAFileDataDel;                
                System.debug('RS999 listDAFileData :' +listDAFileData);
                insert listDAFileData;
                DrawAdvanceProcessBatch processDrawAdv = new DrawAdvanceProcessBatch();
                Id batchId = Database.executeBatch(processDrawAdv, 1);
            }
        } // else of RE or FD emails
    
        if (errorsFound)
        {      
         sendEmailMessage(email, errorString);
        }
        return new Messaging.InboundEmailResult();
      } //method
    
    
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
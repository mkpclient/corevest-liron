public class DrawAdvanceProcessBatch implements Database.Batchable<sObject>, Database.Stateful{

    
    public String bridgeSubjectLine1='';    
    public String bridgeSubjectLine2=''; 
    public String termeSubjectLine='';
    public String termeSubjectLine2='';
    public id bridgeCustodinUserId;
    public  id termCustodinUserId;
    public List<Task> listtsk = new List<Task>();
    Set<String> setLoanAdv = new Set<String>();

    public Database.QueryLocator start(Database.BatchableContext BC){
        Settings__mdt settings 	= Settings__mdt.getInstance('Universal_Settings');
        bridgeCustodinUserId = settings.Bridge_Cptl_Market_Post_Closing_Custodin__c;
        termCustodinUserId 	= settings.Term_Captl_Markets_Post_Closing_Custodin__c;
        System.Debug('RS999 bridgeCustodinUserId ' +bridgeCustodinUserId);        
        System.Debug('RS999 termCustodinUserId ' +termCustodinUserId);

        String query = 'select  id,Line_Type__c,File_From_Bridge_Term__c,Create_Task__c, Field_Loan_ID__c, Field_Advance_Num__c,Field_Line_Value__c,File_Name__c,From_Email__c   from DrawAdvance_File_Data__c where ((File_From_Bridge_Term__c = \'Bridge\' and Create_Task__c = True) OR (File_From_Bridge_Term__c = \'Term\' )) and Line_Type__c = \'D\' order by File_From_Bridge_Term__c,Field_Loan_ID__c,Field_Advance_Num__c';
        return Database.getQueryLocator(query);
    }

public void execute(Database.BatchableContext BC, List<DrawAdvance_File_Data__c> processingDrawAdv){

    bridgeSubjectLine1='';    
    bridgeSubjectLine2=''; 
    termeSubjectLine='';
    termeSubjectLine2='';
    boolean processLine = True;        
    System.Debug('RS999 processingDrawAdv ' +processingDrawAdv);    
    System.Debug('RS999 processingDrawAdv[0].File_From_Bridge_Term__c ' +processingDrawAdv[0].File_From_Bridge_Term__c);
    System.Debug('RS999 processingDrawAdv[0].Field_Loan_ID__c ' +processingDrawAdv[0].Field_Loan_ID__c); 
    System.Debug('RS999 processingDrawAdv[0].Field_Advance_Num__c ' +processingDrawAdv[0].Field_Advance_Num__c); 

    if (processingDrawAdv[0].Field_Loan_ID__c != Null)
    {
        string combostring = processingDrawAdv[0].File_From_Bridge_Term__c + processingDrawAdv[0].Field_Loan_ID__c + processingDrawAdv[0].Field_Advance_Num__c;
        if (setLoanAdv.contains(combostring))
            {
                processLine = False;
            }
        else 
            {
                setLoanAdv.add(combostring);
            }
        System.Debug('RS99 combostring :' +combostring);            
    }

    System.Debug('RS99 processLine :' +processLine);
    if (processLine)
    {    
        if (processingDrawAdv[0].File_From_Bridge_Term__c == 'Bridge')
        {
            Boolean invalidBridgeData = True;  
            if (processingDrawAdv[0].Field_Loan_ID__c != Null &&  processingDrawAdv[0].Field_Advance_Num__c != Null)
            {
                    String filename = processingDrawAdv[0].File_Name__c.normalizeSpace();
                    bridgeSubjectLine1 = filename.toUpperCase().substringBetween('BRIDGE','ASSETS'); 
                    if (bridgeSubjectLine1 != Null ) bridgeSubjectLine1 = bridgeSubjectLine1.normalizeSpace();            
                    bridgeSubjectLine2 = 'DRAW ' + filename.toUpperCase().substringBetween('DRAW','.CSV');  
                    if (bridgeSubjectLine2 != Null ) bridgeSubjectLine2 = bridgeSubjectLine2.normalizeSpace();   
                    System.Debug('RS999 bridgeSubjectLine1 ' +bridgeSubjectLine1); 
                    System.Debug('RS999 bridgeSubjectLine2 ' +bridgeSubjectLine2); 
                
                    String loanID = processingDrawAdv[0].Field_Loan_ID__c.normalizeSpace();
                    List<Opportunity> validLoadDeal = [SELECT Id FROM opportunity where Deal_Loan_Number__c = :loanID];
                    string advance = processingDrawAdv[0].Field_Advance_Num__c.normalizeSpace(); 
                    Integer advanceNo = 0;
                    if (advance.isNumeric()) advanceNo = Integer.valueOf(advance);
                    if (validLoadDeal.size() > 0)
                    {
                        List<Advance__c> validAdvance = [SELECT Id,Custodial_File_Sent_to_Custodian__c FROM Advance__c where Advance_Num__c = :advanceNo and deal__c = :validLoadDeal[0].id];
                        if (validAdvance.size() > 0)
                        {
                            invalidBridgeData = False;
                            if (validAdvance[0].Custodial_File_Sent_to_Custodian__c == Null)
                            {
                                String description ='';
                                integer noOfColumns;
                                DrawAdvance_File_Data__c daHdr = [select Field_Line_Value__c from DrawAdvance_File_Data__c where File_From_Bridge_Term__c = 'Bridge' and Line_Type__c = 'H'];
                                List<String> fileHeaderLine = daHdr.Field_Line_Value__c.split(',');
                                List<String> fileLineFields =  processingDrawAdv[0].Field_Line_Value__c.split(',');
                                
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
                                System.Debug('RS999 Calling Create Task');
                                System.Debug('RS999 loanID ' +loanID);                        
                                System.Debug('RS999 advance ' +advance);                                                
                                System.Debug('RS999 bridgeCustodinUserId ' +bridgeCustodinUserId);                          
                                System.Debug('RS999 validAdvance[0].id ' +validAdvance[0].id);                        
                                System.Debug('RS999 description ' +description);                          
                                CreateTask('B',loanID,advance,bridgeCustodinUserId,validAdvance[0].id,description);
                            }            
                        }
                    }
                
            }
            if (invalidBridgeData)
            {
                DrawAdvance_File_Data__c updateerror = new DrawAdvance_File_Data__c();
                updateerror.id = processingDrawAdv[0].id;
                updateerror.ErrorMessages__c = ' Bridge : InValid Loan Id = ' + processingDrawAdv[0].Field_Loan_ID__c + ' and Advance Number = ' +processingDrawAdv[0].Field_Advance_Num__c;
                update updateerror;
            }        
        } //if (processingDrawAdv[0].File_From_Bridge_Term__c == 'Bridge')

    ////////////////////////////////////////////////////////    
        if (processingDrawAdv[0].File_From_Bridge_Term__c == 'Term')
        {
            Boolean invalidTermData = True;
            System.Debug('RS999 processingDrawAdv[0].Field_Loan_ID__c ' +processingDrawAdv[0].Field_Loan_ID__c); 
                
            if (processingDrawAdv[0].Field_Loan_ID__c != Null )
            {
                String filename = processingDrawAdv[0].File_Name__c.normalizeSpace();
                termeSubjectLine = filename.toupperCase().substringBetween('TERM','CUSTODIAN'); 
                if (termeSubjectLine != Null ) termeSubjectLine = termeSubjectLine.normalizeSpace();
                termeSubjectLine2 = 'DRAW ' + filename.toUpperCase().substringBetween('DRAW','.CSV'); 
                if (termeSubjectLine2 != Null ) termeSubjectLine2 = termeSubjectLine2.normalizeSpace();    
                System.Debug('RS999 termeSubjectLine ' +termeSubjectLine); 
                System.Debug('RS999 termeSubjectLine2 ' +termeSubjectLine2); 
                String loanID = processingDrawAdv[0].Field_Loan_ID__c.normalizeSpace();  
                List<Opportunity> validLoadDeal = [SELECT Id FROM opportunity where Deal_Loan_Number__c = :loanID];            
                if (validLoadDeal.size() > 0)
                {
                    invalidTermData = False;
                    String description ='';
                    integer noOfColumns;
                    DrawAdvance_File_Data__c daHdr = [select Field_Line_Value__c from DrawAdvance_File_Data__c where File_From_Bridge_Term__c = 'Term' and Line_Type__c = 'H'];
                    List<String> fileHeaderLine = daHdr.Field_Line_Value__c.split(',');
                    List<String> fileLineFields =  processingDrawAdv[0].Field_Line_Value__c.split(',');
                    
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
                    System.Debug('RS999 Calling Create Task');
                    System.Debug('RS999 loanID ' +loanID);                        
                    System.Debug('RS999 termCustodinUserId ' +termCustodinUserId);                          
                    System.Debug('RS999 description ' +description);                          
                    CreateTask('T',loanID,'',termCustodinUserId,validLoadDeal[0].id,description);
                }
            } //if (processingDrawAdv[0].Field_Loan_ID__c != Null )
            if (invalidTermData)
            {
                DrawAdvance_File_Data__c updateerror = new DrawAdvance_File_Data__c();
                updateerror.id = processingDrawAdv[0].id;
                updateerror.ErrorMessages__c = ' Term : InValid Loan Id = ' + processingDrawAdv[0].Field_Loan_ID__c;
                update updateerror;
            }
        } //if (processingDrawAdv[0].File_From_Bridge_Term__c == 'Term')    
    } //if (setLoanAdv.contains(combostring))
} //Execute method

public void finish(Database.BatchableContext BC){
system.debug('finish:' );
List<DrawAdvance_File_Data__c> listErrors = [select ErrorMessages__c,From_Email__c from DrawAdvance_File_Data__c where  Line_Type__c = 'D' and ErrorMessages__c  != Null];
if (listErrors.size() > 0)
{
String rateerror='';
for (DrawAdvance_File_Data__c error : listErrors)
{
    rateerror = rateerror + '\n' + error.ErrorMessages__c;
}
Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
message.ToAddresses = new List<String>{
// 'support@cvest.com',email.fromAddress
listErrors[0].From_Email__c
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
// else
// {
//     insert listtsk;    
//     System.Debug('RS999 listtsk in Finish :' +listtsk);        
// }
} //execute method

void CreateTask(String FileType,String loanId,String advanceID,id ownerId,id whatId,String description)    
{
	if (whatId != null)    
    {
    Task tsk = new Task();
    String Subject;
    
    If (!String.isBlank(loanId) && FileType == 'T')
    {
       Subject = termeSubjectLine + ' ' + termeSubjectLine2 + ' Request for Deal #' +  loanId;
    }
    
    if (!String.isBlank(advanceID) && FileType == 'B') 
    {
        Subject = bridgeSubjectLine1 + ' ' + bridgeSubjectLine2 + ' Request for Deal #' +  loanId + ' and Advance No : ' + advanceID;
    }

    tsk.Subject 		= 	 Subject;
    tsk.Status 			= 	'Open';
    tsk.Priority 		= 	'Normal';
    tsk.WhatId 			= 	whatId;
    tsk.OwnerId 		= 	ownerId;
    tsk.ActivityDate 	= 	date.today() + 1;
    tsk.Description 	= 	description;
    tsk.RecordTypeId 	= 	[SELECT Id FROM RecordType WHERE sobjecttype = 'Task' and DeveloperName  = 'Draw_Request'].id;
    listtsk.add(tsk);
    insert tsk;
    System.Debug('RS999 tsk :' +tsk);
    System.Debug('RS999 listtsk :' +listtsk);
	} //(whatId != null) 
} //task method
} //class
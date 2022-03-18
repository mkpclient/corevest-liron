global class OpenPeriodTaskEmailScheduled implements Schedulable{
    global void execute(SchedulableContext SC) {

        List<User> usersToEmail = new List<User>();
        List<Task> myTasks = new List<Task>();
       //Query for sender email 
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'integrations@cvest.com'];

        //Email message list
       	Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();

        
		//Query for records
        List<Opportunity> myDeals = new List<Opportunity>([Select ID,Type,Owner.FirstName,
                                                           Owner.LastName,CloseDate, OwnerID, Deal_Intro_Source__c,
                                                           Owner.isActive, Owner.Email,
                                                           Account.OwnerId, Account.Owner.Email,Account.Owner.LastName,
                                                           Account.Owner.FirstName, Name, Open_Period_Begins__c, YM_Prepayment_Penalty__c, 
                                                           Stepdown_Prepayment_Period__c, YM_Prepayment_Penalty_Description__c, Deal_Intro_Sub_Source__c,
                                                           CAF_YSP__c, Referral_Source__c, Referral_Source_Contact__c, Account.Name, Account_Introduction_Source__c
        FROM Opportunity 
        WHERE Type = 'Term Loan'
		AND StageName = 'Closed Won'
		AND Open_Period_Begins__c != null 
		AND (Open_Period_Begins__c =: System.today() 
		OR Open_Period_Begins__c =: System.today().addMonths(12)
		OR Open_Period_Begins__c =: System.today().addMonths(9)
		OR Open_Period_Begins__c =: System.today().addMonths(6)
		OR Open_Period_Begins__c =: System.today().addMonths(3))
		AND Loan_in_Default__c	= false
		AND Account.In_Litigation__c = false
		AND Account.Do_Not_Lend__c = false
		AND Account.In_Foreclosure__c = false
		AND	Current_UPB__c > 0
        ]);
        system.debug('# of Deals'+myDeals.size());
        
        if(myDeals.size()>0){
           
            for(integer i=0;i < myDeals.size();i++){
                 system.debug('open period'+myDeals[i].Open_Period_Begins__c );
                
    date openPeriodDt = myDeals[i].Open_Period_Begins__c;
    date closeDateDt = myDeals[i].CloseDate;
                
    //for date format            
    string openPeriodDtString = openPeriodDt.month()+'/'+openPeriodDt.day()+'/'+openPeriodDt.year();
    string closeDateDtString = closeDateDt.month()+'/'+closeDateDt.day()+'/'+closeDateDt.year();
                
    //replaces origininal if statement
    string originatorId = myDeals[i].Owner.IsActive == true? myDeals[i].OwnerId : myDeals[i].Account.Owner.Id; 
    //string originatorName = myDeals[i].Owner.IsActive == true? myDeals[i].Owner.FirstName + ' ' + myDeals[i].Owner.LastName : myDeals[i].Account.Owner.FirstName + ' ' + myDeals[i].Account.Owner.LastName;
        
               // if(myDeals[i].Owner.isActive == true){
               
                    Task myTask = new Task();
                    myTask.OwnerId = originatorId;
                    myTask.Subject = 'Deal'+ myDeals[i].Name +' Open period starts on ' + openPeriodDtString;
                    myTask.WhatId = myDeals[i].Id;
                    myTask.Status = 'Open';
                    myTask.Type = 'Reminder';
                    myTasks.add(myTask);
                    
                //single email message 
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    string toEmailAddresses = myDeals[i].Owner.IsActive == true? myDeals[i].Owner.Email:myDeals[i].Account.Owner.Email;
    message.toAddresses = new String[] { toEmailAddresses , 'nadeem.elsewehy@cvest.com' };
	message.setReplyTo('integrations@cvest.com');
	//message.setSenderDisplayName('Cvest Reminders');
	
    //set to true and uncomment line below to save email record            
    message.setSaveAsActivity(false);
    //message.setWhatId(myDeals[i].id);        
                
    message.subject = 'Deal '+ myDeals[i].Name +' Open period starts on ' + openPeriodDtString;
    	
    if ( owea.size() > 0 ) {
    message.setOrgWideEmailAddressId(owea.get(0).Id);
    					}
                    
                    
    message.plainTextBody = 'Hello,\n\n' + 
'This is an update regarding the Maturity Date for your deal.\n\n'+

'Deal: ' + myDeals[i].Name + '\n\n'+

'Loan Type: ' + myDeals[i].Type + '\n\n'+
        
'Originator: ' + myDeals[i].Owner.FirstName + ' ' + myDeals[i].Owner.LastName +'\n\n'+

'Close Date: ' + closeDateDtString + '\n\n'+

'Open Period Begins: '+ openPeriodDtString + '\n\n'+

'YM Par Prepayment Period: '+ myDeals[i].YM_Prepayment_Penalty__c +'\n\n'+

'Stepdown Prepayment Period:' +myDeals[i].Stepdown_Prepayment_Period__c +'\n\n'+

'Stepdown Prepayment Period Description: '+ myDeals[i].YM_Prepayment_Penalty_Description__c +'\n\n'+
                    
'Deal Intro Source: '+ myDeals[i].Deal_Intro_Source__c +';' + myDeals[i].Deal_Intro_Sub_Source__c +'\n\n'+

'CAF YSP: '+myDeals[i].CAF_YSP__c+ '\n\n'+

'Referral Source Account: '+myDeals[i].Referral_Source__c +'\n\n'+

'Referral Source Contact: '+myDeals[i].Referral_Source_Contact__c +'\n\n'+

'Account Name: '+myDeals[i].Account.Name +'\n\n'+
    
'Account Intro Source: '+ myDeals[i].Account_Introduction_Source__c+'\n\n'+
                
 '# of Deals'+myDeals.size();

    
	messages.add(message);
   // }
                
             /*   else{
                    Task myTask = new Task();
                    myTask.OwnerId = myDeals[i].Account.Owner.Id;
                    myTask.Subject = 'Deal'+ myDeals[i].Name +' Open period starts on ' +myDeals[i].Open_Period_Begins__c;
                    myTask.WhatId = myDeals[i].Id;
                    myTask.Status = 'Open';
                    myTask.Type = 'Reminder';
                    myTasks.add(myTask);
                    
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.toAddresses = new String[] { myDeals[i].Account.Owner.Email, 'nadeem.elsewehy@cvest.com' };
	message.setSaveAsActivity(false);
	message.setReplyTo('integrations@cvest.com');
	//message.setSenderDisplayName('Cvest Reminders');
    message.subject = 'Deal'+ myDeals[i].Name +' Open period starts on ' +myDeals[i].Open_Period_Begins__c;
                    
    if ( owea.size() > 0 ) {
        message.setOrgWideEmailAddressId(owea.get(0).Id);}
                    
    date openPeriodDt = myDeals[i].Open_Period_Begins__c;
    date closeDateDt = myDeals[i].CloseDate;
    string openPeriodDtString = openPeriodDt.month()+'/'+openPeriodDt.day()+'/'+openPeriodDt.year();
    string closeDateDtString = closeDateDt.month()+'/'+closeDateDt.day()+'/'+closeDateDt.year();
                    
    message.plainTextBody = 'Hello,\n\n' + 
'This is an update regarding the Maturity Date for your deal.\n\n'+

'Deal: ' + myDeals[i].Name + '\n\n'+

'Loan Type: ' + myDeals[i].Type + '\n\n'+
        
'Originator: ' + myDeals[i].Account.Owner.FirstName + ' ' + myDeals[i].Account.Owner.LastName +'\n\n'+

'Close Date: ' + closeDateDtString + '\n\n'+

'Open Period Begins: '+ openPeriodDtString + '\n\n'+

'YM Par Prepayment Period: '+ myDeals[i].YM_Prepayment_Penalty__c +'\n\n'+

'Stepdown Prepayment Period:' +myDeals[i].Stepdown_Prepayment_Period__c +'\n\n'+

'Stepdown Prepayment Period Description: '+ myDeals[i].YM_Prepayment_Penalty_Description__c +'\n\n'+
                    
'Deal Intro Source: '+ myDeals[i].Deal_Intro_Source__c +';' + myDeals[i].Deal_Intro_Sub_Source__c +'\n\n'+

'CAF YSP: '+myDeals[i].CAF_YSP__c+ '\n\n'+

'Referral Source Account: '+myDeals[i].Referral_Source__c +'\n\n'+

'Referral Source Contact: '+myDeals[i].Referral_Source_Contact__c +'\n\n'+

'Account Name: '+myDeals[i].Account.Name +'\n\n'+
    
'Account Intro Source: '+ myDeals[i].Account_Introduction_Source__c;
	messages.add(message);
                }*/

            }
        }
        if(myTasks.size()>0){
            insert myTasks;
            system.debug('# Tasks Created'+ myTasks.size());
        }
        
        if(messages.size()>0){
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
         system.debug('# emails Created'+ messages.size());

            
if (results[0].success) {
    System.debug('The email was sent successfully.');
} else {
    System.debug('The email failed to send: ' + results[0].errors[0].message);
}
        }


    
}
}
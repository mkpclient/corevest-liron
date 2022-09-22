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
                                                           CAF_YSP__c, Referral_Source__c,Referral_Source__r.Name, Referral_Source_Contact__c, Referral_Source_Contact__r.Name, Account.Name, Account_Introduction_Source__c
        FROM Opportunity 
        WHERE Type = 'Term Loan'
		AND StageName = 'Closed Won'
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
    String openPeriodDtString = myDeals[i].Open_Period_Begins__c ==null?' ':openPeriodDt.month()+'/'+openPeriodDt.day()+'/'+openPeriodDt.year();
    String closeDateDtString = myDeals[i].CloseDate==null?' ' : closeDateDt.month()+'/'+closeDateDt.day()+'/'+closeDateDt.year();

    String loanType =  myDeals[i].Type == null? ' ':myDeals[i].Type;      
    String originatorFirstName = myDeals[i].Owner.FirstName== null? ' ': myDeals[i].Owner.FirstName;
    String originatorLastName = myDeals[i].Owner.LastName== null? ' ': myDeals[i].Owner.LastName;
    String ymParPrepaymentPeriod = myDeals[i].YM_Prepayment_Penalty__c== null? ' ': myDeals[i].YM_Prepayment_Penalty__c;
    String stepdownPrepaymentPeriod = myDeals[i].Stepdown_Prepayment_Period__c== null? ' ': myDeals[i].Stepdown_Prepayment_Period__c;
    String stepdownPrepaymentPeriodDescription = myDeals[i].YM_Prepayment_Penalty_Description__c== null? ' ': myDeals[i].YM_Prepayment_Penalty_Description__c;                    
    String dealIntroSource= myDeals[i].Deal_Intro_Source__c == null? ' ': myDeals[i].Deal_Intro_Source__c;
    String dealIntroSubSource= myDeals[i].Deal_Intro_Sub_Source__c == null? ' ': myDeals[i].Deal_Intro_Sub_Source__c;              
    String cafYsp = myDeals[i].CAF_YSP__c == null? ' ': myDeals[i].CAF_YSP__c ;
    String referralSourceAccount = myDeals[i].Referral_Source__c== null? ' ': myDeals[i].Referral_Source__r.Name;
    String referralSourceContact = myDeals[i].Referral_Source_Contact__c== null? ' ': myDeals[i].Referral_Source_Contact__r.Name;
    String accountName = myDeals[i].Account.Name == null? ' ': myDeals[i].Account.Name ;                
    String accountIntroSource = myDeals[i].Account_Introduction_Source__c == null? ' ' : myDeals[i].Account_Introduction_Source__c;
                
                
    string originatorId = myDeals[i].Owner.IsActive == true? myDeals[i].OwnerId : myDeals[i].Account.Owner.Id; 
        
               
                    Task myTask = new Task();
                    myTask.OwnerId = originatorId;
                    myTask.Subject = 'Deal '+ myDeals[i].Name +' Open period starts on ' + openPeriodDtString;
                    myTask.WhatId = myDeals[i].Id;
                    myTask.Status = 'Open';
                    myTask.Type = 'Reminder';
                    myTasks.add(myTask);
                    
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

'Loan Type: ' + loanType + '\n\n'+
        
'Originator: ' + originatorFirstName + ' ' + originatorLastName +'\n\n'+

'Close Date: ' + closeDateDtString + '\n\n'+

'Open Period Begins: '+ openPeriodDtString + '\n\n'+

'YM Par Prepayment Period: '+ ymParPrepaymentPeriod +'\n\n'+

'Stepdown Prepayment Period:' +stepdownPrepaymentPeriod +'\n\n'+

'Stepdown Prepayment Period Description: '+ stepdownPrepaymentPeriodDescription +'\n\n'+
                    
'Deal Intro Source: '+ dealIntroSource +'; ' + dealIntroSubSource +'\n\n'+

'CAF YSP: '+cafYsp+ '\n\n'+

'Referral Source Account: '+referralSourceAccount +'\n\n'+

'Referral Source Contact: ' + referralSourceContact +'\n\n'+

'Account Name: '+accountName +'\n\n'+
    
'Account Intro Source: '+ accountIntroSource;

    
	messages.add(message);
  

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
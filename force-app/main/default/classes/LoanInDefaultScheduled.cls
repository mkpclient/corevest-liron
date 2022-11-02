global class LoanInDefaultScheduled implements Schedulable {
    global void execute(SchedulableContext SC) {
                List<User> usersToEmail = new List<User>();
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
                                                           FROM Opportunity WHERE Loan_in_Default__c	= true
                                                           ]);
       system.debug('# of Deals'+myDeals.size());
                                                            
       if(myDeals.size()>0){
           
            for(integer i=0;i < myDeals.size();i++){
                
                 Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    string toEmailAddresses = myDeals[i].Owner.IsActive == true? myDeals[i].Owner.Email:myDeals[i].Account.Owner.Email;
    message.toAddresses = new String[] { toEmailAddresses , 'nadeem.elsewehy@cvest.com' };
	message.setReplyTo('integrations@cvest.com');
	//message.setSenderDisplayName('Cvest Reminders');
	
    //set to true and uncomment line below to save email record            
    message.setSaveAsActivity(false);
    //message.setWhatId(myDeals[i].id);        
                
    message.subject = ' The following loan is in default';
    	
    if ( owea.size() > 0 ) {
    message.setOrgWideEmailAddressId(owea.get(0).Id);
    					}
                    
                    
    message.plainTextBody ='The following deal is in default.\n\n'+ 'Deal: '+myDeals[i].Name +'\n\n' +

'Please click on the following link for details.';

    
	messages.add(message);

            }
                
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
global class TermsheetThirtyDayNotification implements Schedulable{
    global void execute(SchedulableContext SC) {
       //Query for sender email 
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'integrations@cvest.com'];

        //Email message list
       	Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();

        
		//Query for records
        List<Opportunity> myDeals = new List<Opportunity>([Select ID,Type, Owner.Email,CloseDate, Owner.FirstName,
                                                           Account.OwnerId, Account.Owner.Email,Account.Owner.LastName,
                                                           Account.Owner.FirstName, Name,Term_Sheet_Signed__c, Underwriter__r.Email,
                                                           Loan_Coordinator__r.Email, Closer__r.Email,LTV__c, Spread_BPS__c,Final_Loan_Amount__c,
                                                           CAF_Analyst__c, CAF_Analyst__r.Email
                                                           
        FROM Opportunity 
        WHERE 
          isClosed != TRUE                                             
          AND                                                 
		 Term_Sheet_Signed__c =: System.today().addDays(-30)
        ]);
        system.debug('# of Deals'+myDeals.size());
        
        if(myDeals.size()>0){
           
            for(integer i=0;i < myDeals.size();i++){
                 system.debug('termsheet signed'+myDeals[i].Term_Sheet_Signed__c );
                
    date termSheetSignedDt = myDeals[i].Term_Sheet_Signed__c;
    date closeDateDt = myDeals[i].CloseDate;
                
    //for date format            
    String termSheetSignedString = myDeals[i].Term_Sheet_Signed__c ==null?' ':termSheetSignedDt.month()+'/'+termSheetSignedDt.day()+'/'+termSheetSignedDt.year();
    String closeDateDtString = myDeals[i].CloseDate==null?' ' : closeDateDt.month()+'/'+closeDateDt.day()+'/'+closeDateDt.year();
    String finAmount = myDeals[i].Final_Loan_Amount__c==null?' ':  String.valueOf(myDeals[i].Final_Loan_Amount__c);
    String ltv = myDeals[i].LTV__c==null?' ':  String.valueOf(myDeals[i].LTV__c);
    String spreadBps = myDeals[i].Spread_BPS__c==null?' ':  String.valueOf(myDeals[i].Spread_BPS__c);
    list<string> sendTo = new List<string>();

                if(myDeals[i].Type.contains('Bridge') || myDeals[i].Type.contains('SAB')){
                if(myDeals[i].Owner.Email != null){
    sendTo.add(myDeals[i].Owner.Email);     
                }
                                if(myDeals[i].Underwriter__r.Email != null){
    sendTo.add(myDeals[i].Underwriter__r.Email);     
                }
                                if(myDeals[i].Loan_Coordinator__r.Email != null){
    sendTo.add(myDeals[i].Loan_Coordinator__r.Email);     
                }
                                if(myDeals[i].Closer__r.Email != null){
    sendTo.add(myDeals[i].Closer__r.Email);     
                }
      sendTo.add('cafcapitalmarkets@redwoodtrust.com');
      sendTo.add('nadeem.elsewehy@cvest.com');
                }
                else if (myDeals[i].Type.contains('Term')){
                    if(myDeals[i].Owner.Email != null){
    sendTo.add(myDeals[i].Owner.Email);     
                }
                                if(myDeals[i].Underwriter__r.Email != null){
    sendTo.add(myDeals[i].Underwriter__r.Email);
                                    if(myDeals[i].CAF_Analyst__r.Email !=null){
                                     sendTo.add(myDeals[i].CAF_Analyst__r.Email);   
                                    }
                }
                                if(myDeals[i].Loan_Coordinator__r.Email != null){
    sendTo.add(myDeals[i].Loan_Coordinator__r.Email);     
                }
                                if(myDeals[i].Closer__r.Email != null){
    sendTo.add(myDeals[i].Closer__r.Email); 
                    
                }
                 sendTo.add('nadeem.elsewehy@cvest.com');
				 sendTo.add('conor.flannery@redwoodtrust.com');
                 sendTo.add('michael.peerson@cvest.com');
                 sendTo.add('micaela.lumpkin@cvest.com');
				 sendTo.add('brad.chmura@cvest.com');
			     sendTo.add('dan.federico@cvest.com');                    
                }
                
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setToAddresses(sendTo);
    // message.toAddresses = new String[] { myDeals[i].Owner.Email, myDeals[i].Underwriter__r.Email, myDeals[i].Loan_Coordinator__r.Email,myDeals[i].Closer__r.Email, 'cafcapitalmarkets@redwoodtrust.com', 'nadeem.elsewehy@cvest.com' };

                system.debug('addys'+ message.toAddresses );
	message.setReplyTo('integrations@cvest.com');
	
    //set to true and uncomment line below to save email record            
    message.setSaveAsActivity(false);
    //message.setWhatId(myDeals[i].id);        
                
    message.subject = 'Deal'+ myDeals[i].Name +' Term Sheet Signed 30 Days Ago On ' + termSheetSignedString;
    	
    if ( owea.size() > 0 ) {
    message.setOrgWideEmailAddressId(owea.get(0).Id);
    					}
                    
                    
    message.plainTextBody = 'Hi '+ myDeals[i].Owner.FirstName+',\n\n' + 
 +  myDeals[i].Name + ' deal has a term sheet signed greater than 30 days ago. This deal may be subject to a reprice. Please check with Capital Markets and Underwriting on if this deal needs to be repriced or if the original pricing can be honored.' 
        +'\n\n'+ 
'Loan Amount: '+ finAmount +'\n\n'+ 

'LTV: '+ ltv +'\n\n'+ 

'Spread: '+ spreadBps +'%\n\n'+ 

'Scheduled Close Date: '+ closeDateDtString +'\n\n'+ 

'Term Sheet Signed Date: '+ termSheetSignedString +
        
 +'\n\n'+ 'Deal Link: https://cvest.lightning.force.com/'+ myDeals[i].id;

    
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
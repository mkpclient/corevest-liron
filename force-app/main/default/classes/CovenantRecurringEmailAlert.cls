global class CovenantRecurringEmailAlert implements Schedulable{

global void execute(SchedulableContext SC) {
 //EmailTemplate template = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'X10dayCovenantEmail'];
 User notificationRecepient = [SELECT id, email FROM User WHERE FirstName = 'George' AND LastName = 'Younes'];
    system.debug(notificationRecepient.email);
 string messageBody;
 //string messageBodyText;
list<task> taskList=new list<task>([select id, ownerId,subject, ActivityDate, Assigned_to_FullName__c from task where 
                                    type='Financial Covenants' 
                                    AND X10_Day_Email_Sent__c = true 
                                    AND Status = 'Open'
                                   AND Covenant_Milestones__c = false]);
    
    List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        
         for(Task t : taskList)
    {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(t.ownerid);
            mail.setCcAddresses(new String[] {notificationRecepient.email});
            mail.setBccAddresses(new String[] {'bryon.harland@cvest.com'});

       			System.debug(t.ownerid);
				System.debug(notificationRecepient.email);
        
            //mail.setTemplateId(template.Id);
        	mail.setSubject('10 days of no Financial Covenants update.');

        	messageBody = '<html><body>George' + '<br/><br/>' + 'It has been ~ 10 days of no activity. ' + t.Assigned_to_FullName__c + ' has not updated the milestone values on this Financial Covenants task.' + '<br/><br/>' + 'Link to Task: '+URL.getSalesforceBaseUrl().toExternalForm() + '/' + t.Id+'<br/><br/>'+ 'Please follow up with '+t.Assigned_to_FullName__c+'.'+'<br/><br/>' + 'Thank you</body></html>';
            //messageBodyText = 'George' + '\n\n' + 'It has been ~ 10 days of no activity. ' + t.Assigned_to_FullName__c + ' has not updated the milestone values on this Financial Covenants task.' + '\n\n' + 'Link to Task: '+URL.getSalesforceBaseUrl().toExternalForm() + '/' + t.Id+'\n\n'+ 'Please follow up with '+t.Assigned_to_FullName__c+'.'+'\n\n' + 'Thank you';
	
            mail.setHtmlBody(messageBody);
        	//mail.setPlainTextBody(messageBodyText);
            mail.saveAsActivity = false;
            mailsToSend.add(mail);
       }
    //Send Email
    if(mailsToSend.size() > 0)
    {
        Messaging.sendEmail(mailsToSend);       
    }
    }
    }
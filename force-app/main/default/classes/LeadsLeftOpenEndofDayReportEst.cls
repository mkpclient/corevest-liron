global class LeadsLeftOpenEndofDayReportEst implements Schedulable{
    global void execute(SchedulableContext SC) {
        string reportLink = 'https://cvest--qa.my.salesforce.com/a17/o' ;
       list<id> leadOwner =new list<id>();
       list<user> ignoreUser = new list<user>([SELECT id FROM user WHERE Full_Name__c = 'Andrea Reed' 
                                                OR Full_Name__c = 'Tuan Pham'
                                                OR Full_Name__c = 'Brad Chmura'
                                                OR Full_Name__c = 'Tom Basmajian'
                                                OR Full_Name__c = 'Liz Roling']);

        //Lead Created Dates Start 3PM CA time to 3PM CA Time
        list<lead> leadList = new list<lead>([SELECT OwnerId FROM lead WHERE Status = 'Open' 
                                              AND Introduction_Source__c != 'Imported Leads'
                                              AND Introduction_Source__c != 'Imported List'
                                              AND Introduction_Source__c != 'Event'
                                              AND Introduction_Source__c != 'Referral'
                                              AND Introduction_Source__c != 'Non-Database'
                                              AND Introduction_Source__c != null
                                              AND  Owner_Timezone__c	!= 'PST'
                                              AND CreatedDate <=: System.now()
                                              AND CreatedDate >=: System.now()-7
                                              AND (NOT Introduction_Subsource__c like '%Tower List%')
                                              AND OwnerId Not IN:ignoreUser
                                             ]); 
        if(leadList.size() > 0){
            for(Lead l : leadList){
                leadOwner.add(l.ownerId);
                    }
        }
        if(leadOwner.size() > 0){
   	sendMail(leadOwner);
        }
    }
    public void sendMail(list<id> leadOwner){
        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'Leads_Left_Open_Report' LIMIT 1];

        list <id> usersToEmail = new list<id>();
        set <Id> listDedupe = new set<id>();
        listDedupe.addAll(leadOwner);
        usersToEmail.addAll(listDedupe);
        
    Messaging.MassEmailMessage reportEmail = new Messaging.MassEmailMessage(); 
	reportEmail.setTargetObjectIds(usersToEmail);
    reportEmail.setTemplateId(et.id);
    reportEmail.setSenderDisplayName('CoreVest');
    reportEmail.saveAsActivity = false;
    Messaging.sendEmail(new Messaging.MassEmailMessage[] {reportEmail});    
    }
}
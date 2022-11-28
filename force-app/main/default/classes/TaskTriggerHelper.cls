public class TaskTriggerHelper {
    
public static void beforeInsert(List<Task> tskList){
    for(Task tsk: tskList) {
      if(tsk.WhoId == null) {
        continue;
      }
      SObjectField lookupField = tsk.WhoId.getSObjectType() == Lead.SObjectType ? Task.Related_to_Lead__c : Task.Related_to_Contact__c;
      tsk.put(lookupField, tsk.WhoId);
    }
}

public static void afterInsert(List<Task> tskList){
    system.debug('into after insert');
    
    list<string> myEmails = new list<string>();
    list<contact> tskContactEmails = new list<contact>();
    list<string> cleanEmails = new list<string>();
    
    for(Task tsk: tskList) { 
        system.debug('in for loop');
        if(tsk.type == 'Email' && tsk.Description !=null){
            String toEmail = tsk.Description.substringAfter('To:').substringBefore('CC:');
            system.debug('toemail'+toEmail);
            
            if(toEmail.contains(';')){  
			myEmails = toEmail.split(';');
                system.debug('myEmails' + myEmails);
                for(Integer i = 0; i < myEmails.size(); i++){
                    system.debug('clean email size'+myEmails.size());
                    cleanEmails.add(myEmails[i].trim());
                }
            system.debug('first email'+cleanEmails[0]);
            system.debug('second email'+cleanEmails[1]);
            }
        }
    }
    system.debug('cleanemails' +cleanEmails);
    

        tskContactEmails = [select Id,Last_Mass_Email_Date__c, Name from Contact where Email in:cleanEmails];
    system.debug(tskContactEmails.size());
    
    if(tskContactEmails.size()>1){
        for(contact myCont : tskContactEmails){
            myCont.Last_Mass_Email_Date__c = date.today();
        }
        update tskContactEmails;
    }
    
    
}
public static void beforeUpdate(List<Task> tskList){
    for(Task tsk: tskList) {
       
      Id recordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByName().get('Draw Request').getRecordTypeId();

     if (recordTypeId != Null && tsk.RecordTypeId == recordTypeId && tsk.Status == 'Completed')
     {
         
//RS.CIP-2751.10/13/22.BEGIN
            ContentNote cn = new ContentNote();
            cn.Title = tsk.Subject;
            cn.Content = Blob.valueOf(tsk.Description);
            insert(cn);
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cn.id; 
            cdl.LinkedEntityId = tsk.WhatId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            if (!test.isRunningTest()) insert(cdl);         
//RS.CIP-2751.10/13/22.END         
         
         
         List<Advance__c> adv = [select id from Advance__c where id = :tsk.WhatId];
         if (adv.Size() > 0)
         {
         adv[0].Custodial_File_Sent_to_Custodian__c = date.today();
         update adv;
         }
     }
        
        
      if(tsk.WhoId == null) {
        continue;
      }
      SObjectField lookupField = tsk.WhoId.getSObjectType() == Lead.SObjectType ? Task.Related_to_Lead__c : Task.Related_to_Contact__c;
      tsk.put(lookupField, tsk.WhoId);
    }
}
}
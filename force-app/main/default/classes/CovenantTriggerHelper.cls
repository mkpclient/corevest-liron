public class CovenantTriggerHelper {
    public static void CreateCovenantTask(list<Covenant__c>newCov){
        list<task>tasksToAdd = new list<task>();
Id recordTypeId = Schema.SObjectType.task.getRecordTypeInfosByDeveloperName()
    .get('Task').getRecordTypeId();
        
        for(Covenant__c cov : newCov){
            if(cov.Due_Date__c != null){
            task newTask = new task();
            newTask.WhatId		 = cov.id ;
            newTask.OwnerId 	 = cov.CreatedById;
            newTask.Subject		 = cov.Name;
            newTask.Type		 = 'Financial Covenants';
            newTask.RecordTypeId = recordTypeId;
            newTask.Priority 	 = 'Normal';
            newTask.Status   	 = 'Open';
            newTask.ActivityDate = cov.Due_Date__c;
            newTask.IsReminderSet = true;
            newTask.ReminderDateTime = cov.Due_Date__c - 15;
            
            tasksToAdd.add(newTask);
            }
            else{
            task newTask = new task();
            newTask.WhatId		 = cov.id ;
            newTask.OwnerId 	 = cov.CreatedById;
            newTask.Subject		 = cov.Name;
            newTask.Type		 = 'Financial Covenants';
            newTask.RecordTypeId = recordTypeId;
            newTask.Priority 	 = 'Normal';
            newTask.Status   	 = 'Open';
                
           	tasksToAdd.add(newTask);
            }
        }
        if(tasksToAdd.size()>0){
            insert tasksToAdd;
        }
    } 
     public static void UpdateCovenantTask(list<Covenant__c>newCov){
     	 list<Covenant__c> myCov = new list<Covenant__c>();
         for(Covenant__c cov : newCov){
             if (cov.Milestones__c != null){
             myCov.add(cov);
         }}
         list<task> tasksToUpdate = [SELECT OwnerID, Covenant_Milestones__c, Status from Task where Type = 'Financial Covenants'and WhatID in:myCov];
         for(task t : tasksToUpdate){
             t.Covenant_Milestones__c = true;
             t.Status = 'Completed';
             
             
         }
         if (tasksToUpdate.size() >0) {
             update tasksToUpdate;
         }
         
             }
}
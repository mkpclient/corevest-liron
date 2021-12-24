trigger CovenantTrigger on Covenant__c (after insert, after update) {
    if(trigger.isInsert){
        CovenantTriggerHelper.CreateCovenantTask(trigger.new);
    }
    else if(trigger.isUpdate){
        CovenantTriggerHelper.UpdateCovenantTask(trigger.new);
    }
}
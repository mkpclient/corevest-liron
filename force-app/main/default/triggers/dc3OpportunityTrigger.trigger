trigger dc3OpportunityTrigger on Opportunity(after delete, after insert, after undelete, after update, before insert, before update) { 

 /*   dupcheck.dc3Trigger triggerTool = new dupcheck.dc3Trigger(trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
    String errorString = triggerTool.processTrigger(trigger.oldMap, trigger.new); 

    if (String.isNotEmpty(errorString)) { trigger.new[0].addError(errorString,false); }  */
}
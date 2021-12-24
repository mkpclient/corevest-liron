trigger TaskTrigger on Task (before insert,after insert, before update) {
    if(Trigger.isBefore && Trigger.isInsert){

        TaskTriggerHelper.beforeInsert(trigger.new);
    }
     if (Trigger.isAfter && Trigger.isInsert){

        TaskTriggerHelper.afterInsert(trigger.new);

   }
    
    if (Trigger.isBefore && Trigger.isUpdate){

        TaskTriggerHelper.beforeUpdate(trigger.new);

   }

}
trigger AppraisalTrigger on Appraisal__c (after update) {
  if(Trigger.isAfter && Trigger.isUpdate) {
    AppraisalTriggerHelper.afterUpdate(Trigger.old, Trigger.new);
  }
}
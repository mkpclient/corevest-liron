trigger AppraisalTrigger on Appraisal__c(after insert, after update) {
  if (Trigger.isAfter && Trigger.isInsert) {
    AppraisalTriggerHelper.afterInsert(Trigger.New);
  }
  if (Trigger.isAfter && Trigger.isUpdate) {
    AppraisalTriggerHelper.afterUpdate(Trigger.old, Trigger.new);
  }
}
trigger BatchApprover on Batch_Approver__c (before update, after update) {
  if(Trigger.isBefore && Trigger.isUpdate) {
    BatchApproverHelper.beforeUpdate(Trigger.oldMap, Trigger.newMap);
  }
  if(Trigger.isAfter && Trigger.isUpdate) {
    BatchApproverHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
  }
}
trigger BatchApproval on Batch_Approval__c(before insert, after insert, before update, after update) {
  if(Trigger.isBefore && Trigger.isInsert) {
    BatchApprovalHelper.beforeInsert(Trigger.new);
  }
  if (Trigger.isAfter && Trigger.isInsert) {
    BatchApprovalHelper.afterInsert(Trigger.newMap);
  }
  if(Trigger.isBefore && Trigger.isUpdate) {
    BatchApprovalHelper.beforeUpdate(Trigger.oldMap, Trigger.newMap);
  }

  if(Trigger.isAfter && Trigger.isUpdate) {
    BatchApprovalHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
  }
}

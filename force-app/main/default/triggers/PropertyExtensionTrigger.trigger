trigger PropertyExtensionTrigger on Property_Extension__c (before insert, after insert, before update, after update) {
  if(Trigger.isAfter) {
    if(Trigger.isInsert) {
      PropertyExtensionHelper.afterInsert(Trigger.newMap);
    }

    if(Trigger.isUpdate) {
      PropertyExtensionHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }
  }

  if(Trigger.isBefore) {
    if(Trigger.isUpdate) {
      PropertyExtensionHelper.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isInsert) {
      PropertyExtensionHelper.beforeInsert(Trigger.new);
    }

  }
}
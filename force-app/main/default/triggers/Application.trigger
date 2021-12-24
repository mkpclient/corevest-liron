trigger Application on Application__c(before insert) {
  if (Trigger.isInsert && Trigger.isBefore) {
    ApplicationHelper.beforeInsert(Trigger.New);
  }
}
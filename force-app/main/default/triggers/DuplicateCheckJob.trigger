trigger DuplicateCheckJob on dupcheck__dcJob__c(after update) {
  system.debug('hit here');
  if (Trigger.isAfter && Trigger.isUpdate) {
    DuplicateCheckJobHelper.afterUpdate(Trigger.New, Trigger.Old);
  }
}
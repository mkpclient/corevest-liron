trigger Foreclosure_Trigger on Foreclosure__c (before insert, after insert, after update) {
  if(Trigger.isBefore && Trigger.isInsert) {
    ForeclosureHelper.beforeInsert(Trigger.new);
  }
   if(Trigger.isAfter && Trigger.isUpdate) {
    ForeclosureHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
  }

  if(Trigger.isAfter && Trigger.isInsert) {
    ForeclosureHelper.afterInsert(Trigger.New);
  }
}
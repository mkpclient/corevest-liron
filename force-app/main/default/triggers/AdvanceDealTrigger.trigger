trigger AdvanceDealTrigger on Advance__c(after insert, after update) {
  Settings__mdt settings = Settings__mdt.getInstance('Universal_Settings');

  if (!settings.Disable_Advance_Trigger__c) {
    if (Trigger.isInsert) {
        AdvanceDealTriggerHelper.advanceDealTriggerHelperMethod(Trigger.newMap, new Map<Id,Advance__c>());
      
    } else if (Trigger.isUpdate) {
      for (integer i = 0; i < Trigger.new.size(); i++) {
        AdvanceDealTriggerHelper.advanceDealTriggerHelperMethod(
          Trigger.newMap,
          Trigger.oldMap
        );
      }
    }
  }
}
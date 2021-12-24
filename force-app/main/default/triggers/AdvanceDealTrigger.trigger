trigger AdvanceDealTrigger on Advance__c(after insert, after update) {
  Settings__mdt settings = Settings__mdt.getInstance('Universal_Settings');

  if (!settings.Disable_Advance_Trigger__c) {
    if (Trigger.isInsert) {
      for (Advance__c adv : Trigger.new) {
        AdvanceDealTriggerHelper.advanceDealTriggerHelperMethod(adv, null);
      }
    } else if (Trigger.isUpdate) {
      for (integer i = 0; i < Trigger.new.size(); i++) {
        AdvanceDealTriggerHelper.advanceDealTriggerHelperMethod(
          Trigger.new[i],
          Trigger.old[i]
        );
      }
    }
  }
}
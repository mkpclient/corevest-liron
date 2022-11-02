trigger Commission_Trigger on Commission__c(
  after insert,
  after update,
  after delete
) {
  Settings__mdt settings = Settings__mdt.getInstance('Universal_Settings');
  if (!settings.Disable_Commissions_Trigger__c) {
    if (Trigger.isAfter && Trigger.isInsert) {
      if (CommissionDetail_TestSkip.shouldRunTrigger()) {
        Commission_Helper.afterInsert(Trigger.new);
      }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
      if (CommissionDetail_TestSkip.shouldRunTrigger()) {
        Commission_Helper.afterUpdate(Trigger.new, Trigger.old);
      }
    }

    if (Trigger.isAfter && Trigger.isDelete) {
      if (CommissionDetail_TestSkip.shouldRunTrigger()) {
        Commission_Helper.afterDelete(Trigger.old);
      }
    }
  }
}
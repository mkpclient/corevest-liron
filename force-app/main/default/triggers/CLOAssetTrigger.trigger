trigger CLOAssetTrigger on CLO_Asset_Details__c(after update, after insert) {
  if (Trigger.isAfter && Trigger.isUpdate && CLOAsset_Helper.runTigger) {
    CLOAsset_Helper.afterUpdate(Trigger.new, Trigger.old);
  }

  if (Trigger.isAfter && Trigger.isInsert && CLOAsset_Helper.runTigger) {
    CLOAsset_Helper.afterInsert(Trigger.New);
  }

}
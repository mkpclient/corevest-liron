trigger CLOAssetTrigger on CLO_Asset_Details__c (After Update) {

    if (
      Trigger.isAfter &&
      Trigger.isUpdate &&
      CLOAsset_Helper.runTigger
    ) {
    	  CLOAsset_Helper.afterUpdate(Trigger.New, Trigger.Old);
      }
        
}
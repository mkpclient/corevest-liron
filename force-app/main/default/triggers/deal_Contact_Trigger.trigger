trigger deal_Contact_Trigger on Deal_Contact__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  Settings__mdt settings = Settings__mdt.getInstance('Universal_Settings');
  if (!settings.Disable_Deal_Contact_Trigger__c) {
    if (Trigger.isBefore && Trigger.isInsert) {
      deal_Contact_Helper.beforeInsert(Trigger.New);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
      deal_Contact_Helper.afterInsert(Trigger.New);
      PostClosingHelper.createPostClosingItems(
        Trigger.newMap,
        new Map<Id, sObject>(),
        'Deal_Contact__c',
        'afterInsert'
      );
      // ChecklistHelper.createChecklistSectionApplicant(Trigger.newMap.keySet());
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
      // Deal_Contact__c_Helper.beforeUpdate(Trigger.New, Trigger.Old);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
      deal_Contact_Helper.afterUpdate(Trigger.NewMap, Trigger.OldMap);
      PostClosingHelper.createPostClosingItems(
        Trigger.newMap,
        Trigger.oldMap,
        'Deal_Contact__c',
        'afterUpdate'
      );
    }
    if (Trigger.isBefore && Trigger.isDelete) {
      //  Deal_Contact__c_Helper.beforeDelete(Trigger.New);
    }
    if (Trigger.isAfter && Trigger.isDelete) {
      //  Deal_Contact__c_Helper.afterDelete(Trigger.New, Trigger.Old);
    }
    if (Trigger.isAfter && Trigger.isUndelete) {
      //  Deal_Contact__c_Helper.afterUndelete(Trigger.Old);
    }
  }
}
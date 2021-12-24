trigger DocumentInformationTrigger on Document_Information__c (after update, before update, before insert) {

    if(Trigger.isBefore && Trigger.isUpdate){
        DocumentInformationHelper.beforeUpdate(Trigger.New, Trigger.Old);
    }

    if(Trigger.isBefore && Trigger.isInsert){
        DocumentInformationHelper.beforeInsert(Trigger.New);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        DocumentInformationHelper.afterUpdate(Trigger.New, Trigger.Old);
    }

}
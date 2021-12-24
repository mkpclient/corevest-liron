trigger UpdateDocusignActiveStatus on User (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        UpdateDocusignActiveStatusHelper.UpdateDocusignUserStatus(Trigger.new, Trigger.oldMap);
    }
}
trigger Account on Account (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {

        if ( Trigger.isBefore && Trigger.isInsert ) {
            AccountHelper.beforeInsert(Trigger.New);
        }
        if ( Trigger.isAfter && Trigger.isInsert ) {
            // AccountHelper.afterInsert(Trigger.New);
        }
        if ( Trigger.isBefore && Trigger.isUpdate ) {
            AccountHelper.beforeUpdate(Trigger.New, Trigger.Old);
        }
        if ( Trigger.isAfter && Trigger.isUpdate ) {
            AccountHelper.afterUpdate(Trigger.New);
        }
        if ( Trigger.isBefore && Trigger.isDelete ) {
        //  AccountHelper.beforeDelete(Trigger.New);
        }
        if ( Trigger.isAfter && Trigger.isDelete ) {
        //  AccountHelper.afterDelete(Trigger.New, Trigger.Old);
        }
        if ( Trigger.isAfter && Trigger.isUndelete ) {
        //  AccountHelper.afterUndelete(Trigger.Old);
        }
}
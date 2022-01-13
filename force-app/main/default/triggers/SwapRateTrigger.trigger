trigger SwapRateTrigger on Swap_Rate__c (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {

        if ( Trigger.isBefore && Trigger.isInsert ) {
            SwapRateHelper.beforeInsert(Trigger.New);
        }
        if ( Trigger.isAfter && Trigger.isInsert ) {
            // SwapRateHelper.afterInsert(Trigger.New);
        }
        if ( Trigger.isBefore && Trigger.isUpdate ) {
            // SwapRateHelper.beforeUpdate(Trigger.New, Trigger.Old);
        }
        if ( Trigger.isAfter && Trigger.isUpdate ) {
            // SwapRateHelper.afterUpdate(Trigger.New);
        }
        if ( Trigger.isBefore && Trigger.isDelete ) {
        //  SwapRateHelper.beforeDelete(Trigger.New);
        }
        if ( Trigger.isAfter && Trigger.isDelete ) {
        //  SwapRateHelper.afterDelete(Trigger.New, Trigger.Old);
        }
        if ( Trigger.isAfter && Trigger.isUndelete ) {
        //  SwapRateHelper.afterUndelete(Trigger.Old);
        }
}
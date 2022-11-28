trigger EBIUpdates on EBI_Updates__c (after update) {
if ( Trigger.isAfter && Trigger.isUpdate ) {
        EBIUpdates.afterUpdate(Trigger.New, Trigger.Old);
    }
}
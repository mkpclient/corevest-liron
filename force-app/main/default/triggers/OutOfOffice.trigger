trigger OutOfOffice on Out_Of_Office__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        OutOfOfficeHelper.afterInsert(Trigger.New);
    }
}
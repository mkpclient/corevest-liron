trigger ContentVersion on ContentVersion (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        ContentVersionHelper.afterInsert(Trigger.New);
    }
}
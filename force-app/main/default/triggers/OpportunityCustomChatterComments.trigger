trigger OpportunityCustomChatterComments on FeedComment (after insert,after update, before delete) {
    if (Trigger.isAfter && Trigger.isInsert) 
    {
        System.debug('Trigger.isAfter && Trigger.isInsert');
        OppCustomChatterCommentsHelper.AfterInsert(Trigger.new,Trigger.old);
    }

    if (Trigger.isAfter && Trigger.isUpdate)
    {
        System.debug('Trigger.isAfter && Trigger.isUpdate');
        OppCustomChatterCommentsHelper.AfterUpdate(Trigger.new,Trigger.old);
    }
    
   if (Trigger.isbefore && Trigger.isdelete)
    {
        System.debug('Trigger.before && Trigger.delet');
        OppCustomChatterCommentsHelper.BeforeDelete(Trigger.old);
    }
}
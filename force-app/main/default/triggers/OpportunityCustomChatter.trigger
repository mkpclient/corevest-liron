trigger OpportunityCustomChatter on FeedItem (after insert,after update, before delete) 
{

    if (Trigger.isAfter && Trigger.isInsert) 
    {
        System.debug('Trigger.isAfter && Trigger.isInsert');
        oppchatterhelper.AfterInsert(Trigger.new,Trigger.old);
    }


    if (Trigger.isAfter && Trigger.isUpdate)
    {
        System.debug('Trigger.isAfter && Trigger.isUpdate');
        oppchatterhelper.AfterUpdate(Trigger.new,Trigger.old);
    }
    
   if (Trigger.isbefore && Trigger.isdelete)
    {
        System.debug('Trigger.before && Trigger.delet');
        oppchatterhelper.BeforeDelete(Trigger.old);
    }
}
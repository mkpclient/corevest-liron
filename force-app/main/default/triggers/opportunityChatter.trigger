trigger opportunityChatter on Custom_Chatter_Mapping__c (after insert,after update) {

if (Trigger.isAfter && Trigger.isInsert) {
/*String status;
FeedItem post = new FeedItem();

    for(Custom_Chatter_Mapping__c  m : Trigger.new) {
        if(Trigger.isInsert) {
            post.ParentId = '00678000002Ste2AAC'; //m.Deal__c;
            post.Body = 'rs testing';
        }
    }
    insert post;
    }*/
    System.debug('RS Trigger.isAfter && Trigger.isInsert');    
}

if (Trigger.isAfter && Trigger.isUpdate)
{
    System.debug('RS Trigger.isAfter && Trigger.isUpdate');
}
}
trigger EmailMessageTrigger on EmailMessage (after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert){

        EmailMessageHelper.afterInsert(trigger.new);
    }
}
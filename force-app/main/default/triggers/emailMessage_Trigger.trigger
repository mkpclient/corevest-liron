trigger emailMessage_Trigger on EmailMessage (after insert) {
    if ( Trigger.isAfter && Trigger.isInsert ) {
        //EmailMessage_Helper.afterInsert(Trigger.New);
        //for ( EmailMessage em : Trigger.new ){
        //    //system.debug(em.ExternalId);
        //}

        //emailMessage_Helper.afterInsert(Trigger.new);
    }
}
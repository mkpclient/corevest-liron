trigger REO on REO__c (after insert) {
  if(Trigger.isAfter && Trigger.isInsert) {
    REOHelper.afterInsert(Trigger.new);
  }
}
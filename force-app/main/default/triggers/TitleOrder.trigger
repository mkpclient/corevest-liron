trigger TitleOrder on Title_Order__c(
  before insert,
  after insert,
  before update,
  after update
) {

  if(Trigger.isBefore && Trigger.isInsert) {
    TitleOrderHelper.beforeInsert(Trigger.new);
  }
}
trigger InterestReservesTrigger on Interest_Reserves__c (before insert, before update) {
 if (Trigger.isBefore && Trigger.isInsert){
 interestReservesHandler.beforeInsert(trigger.new);
}
  if (Trigger.isBefore && Trigger.isUpdate){
   interestReservesHandler.beforeUpdate(trigger.new, trigger.old);

}
}
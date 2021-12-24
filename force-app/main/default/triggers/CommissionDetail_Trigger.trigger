trigger CommissionDetail_Trigger on Commission_Detail__c (after insert, after update) {
  if (Trigger.isAfter && Trigger.isInsert){
    CommissionDetail_Helper.afterInsert(Trigger.new);
 }
   if (Trigger.isAfter && Trigger.isUpdate){
       		//Final Loan Amount 750K or less (term)
             CommissionDetailExt.afterUpdate(Trigger.new, Trigger.Old);
       		//Final Loan Amount Above 750K (Term and more logic)
             CommissionDetail_Helper.afterUpdate(Trigger.new, Trigger.Old);
       
    }
}
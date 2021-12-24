trigger trade_Trigger on Trade__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		if ( Trigger.isBefore && Trigger.isInsert ) {
	    	Trade_Helper.beforeInsert(Trigger.New);
		}
		if ( Trigger.isAfter && Trigger.isInsert ) {
	    //	Trade__c_Helper.afterInsert(Trigger.New);
		}
		if ( Trigger.isBefore && Trigger.isUpdate ) {
	    //	Trade__c_Helper.beforeUpdate(Trigger.New, Trigger.Old);
		}
		if ( Trigger.isAfter && Trigger.isUpdate ) {
	    //	Trade__c_Helper.afterUpdate(Trigger.New, Trigger.Old);
		}
		if ( Trigger.isBefore && Trigger.isDelete ) {
	    //	Trade__c_Helper.beforeDelete(Trigger.New);
		}
		if ( Trigger.isAfter && Trigger.isDelete ) {
	    //	Trade__c_Helper.afterDelete(Trigger.New, Trigger.Old);
		}
		if ( Trigger.isAfter && Trigger.isUndelete ) {
	    //	Trade__c_Helper.afterUndelete(Trigger.Old);
		}
}
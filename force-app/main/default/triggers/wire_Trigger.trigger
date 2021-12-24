trigger wire_Trigger on Wire__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		if ( Trigger.isBefore && Trigger.isInsert ) {
	    	wire_Helper.beforeInsert(Trigger.New);
		}
		if ( Trigger.isAfter && Trigger.isInsert ) {
	    //	Wire__c_Helper.afterInsert(Trigger.New);
		}
		if ( Trigger.isBefore && Trigger.isUpdate ) {
	    	//Wire__c_Helper.beforeUpdate(Trigger.New, Trigger.Old);
		}
		if ( Trigger.isAfter && Trigger.isUpdate ) {
	    	//Wire__c_Helper.afterUpdate(Trigger.New, Trigger.Old);
		}
		if ( Trigger.isBefore && Trigger.isDelete ) {
	    //	Wire__c_Helper.beforeDelete(Trigger.New);
		}
		if ( Trigger.isAfter && Trigger.isDelete ) {
	    	Wire_Helper.afterDelete(Trigger.New, Trigger.Old);
		}
		if ( Trigger.isAfter && Trigger.isUndelete ) {
	    //	Wire__c_Helper.afterUndelete(Trigger.Old);
		}
}
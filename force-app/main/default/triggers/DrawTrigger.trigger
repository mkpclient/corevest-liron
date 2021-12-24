trigger DrawTrigger on Draw__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		if ( Trigger.isBefore && Trigger.isInsert ) {
	    	DrawHelper.beforeInsert(Trigger.New);
		}
		if ( Trigger.isAfter && Trigger.isInsert ) {
	    //	Draw__c_Helper.afterInsert(Trigger.New);
		}
		if ( Trigger.isBefore && Trigger.isUpdate ) {
	    //	Draw__c_Helper.beforeUpdate(Trigger.New, Trigger.Old);
		}
		if ( Trigger.isAfter && Trigger.isUpdate ) {
	    //	Draw__c_Helper.afterUpdate(Trigger.New, Trigger.Old);
		}
		if ( Trigger.isBefore && Trigger.isDelete ) {
	    //	Draw__c_Helper.beforeDelete(Trigger.Old);
		}
		if ( Trigger.isAfter && Trigger.isDelete ) {
	    //	Draw__c_Helper.afterDelete(Trigger.Old);
		}
		if ( Trigger.isAfter && Trigger.isUndelete ) {
	    //	Draw__c_Helper.afterUndelete(Trigger.New);
		}
}
trigger contentDocument_Trigger on ContentDocument (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		if ( Trigger.isBefore && Trigger.isInsert ) {
	    //	ContentDocument_Helper.beforeInsert(Trigger.New);
		}
		if ( Trigger.isAfter && Trigger.isInsert ) {
	    //	ContentDocument_Helper.afterInsert(Trigger.New);
		}
		if ( Trigger.isBefore && Trigger.isUpdate ) {
	    //	ContentDocument_Helper.beforeUpdate(Trigger.New, Trigger.Old);
		}
		if ( Trigger.isAfter && Trigger.isUpdate ) {
	    //	ContentDocument_Helper.afterUpdate(Trigger.New, Trigger.Old);
		}
		if ( Trigger.isBefore && Trigger.isDelete ) {
	    //	ContentDocument_Helper.beforeDelete(Trigger.New);
		}
		if ( Trigger.isAfter && Trigger.isDelete ) {
	    //	ContentDocument_Helper.afterDelete(Trigger.Old);
		}
		if ( Trigger.isAfter && Trigger.isUndelete ) {
	    //	ContentDocument_Helper.afterUndelete(Trigger.Old);
		}
}
trigger tradeDeal_Trigger on Trade_Deal__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		if ( Trigger.isBefore && Trigger.isInsert ) {
	    	//Trade_Deal__c_Helper.beforeInsert(Trigger.New);
		}
		if ( Trigger.isAfter && Trigger.isInsert ) {
	    	TradeDeal_Helper.afterInsert(Trigger.New);
		}
		if ( Trigger.isBefore && Trigger.isUpdate ) {
	    	//Trade_Deal__c_Helper.beforeUpdate(Trigger.New, Trigger.Old);
		}
		if ( Trigger.isAfter && Trigger.isUpdate ) {
	    	TradeDeal_Helper.afterUpdate(Trigger.New, Trigger.Old);
		}
		if ( Trigger.isBefore && Trigger.isDelete ) {
	    	TradeDeal_Helper.beforeDelete(Trigger.old);
		}
		if ( Trigger.isAfter && Trigger.isDelete ) {
	    	TradeDeal_Helper.afterDelete(Trigger.Old);
		}
		if ( Trigger.isAfter && Trigger.isUndelete ) {
	    //	Trade_Deal__c_Helper.afterUndelete(Trigger.Old);
		}
}
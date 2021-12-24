({
    handleRecordUpdated: function(component, event, helper) {
        if (!$A.util.isUndefinedOrNull(component.get("v.ObjRec"))
            && event.getParams().changeType === "CHANGED" 
            && !$A.util.isUndefinedOrNull(event.getParams().changedFields)
            && !$A.util.isUndefinedOrNull(event.getParams().changedFields.Foreign_National__c) 
            && event.getParams().changedFields.Foreign_National__c.value==true 
            && event.getParams().changedFields.Foreign_National__c.oldValue==false
           ) 
        { 
            
             var type = "warning";
        var message = 'A Foreign National will be limited to max 65% LTV and Soft Cash Management.';
        helper.showToast(component, event, helper, type, message);
            
        }
        
    }
})
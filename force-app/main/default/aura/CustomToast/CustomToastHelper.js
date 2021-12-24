({
  /*  ModelToastMsg : function(component, event, helper) {
        var type = "warning";
        var message = 'A Foreign National will be limited to max 65% LTV and Soft Cash Management.';
        helper.showToast(component, event, helper, type, message);
           
    }, */
    
    showToast : function(component, event, helper, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Please Note",
            "type": type,
            "message": message
        });
        toastEvent.fire();
    }
})
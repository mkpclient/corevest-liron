({
    doInit : function(component, event, helper) {
        var action = component.get("c.getRelatedChatterObject");
        action.setParams({
            parentId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS" ) {
                component.set("v.customChatterId", response.getReturnValue());
            }else if(response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                
            }
        });
        
        $A.enqueueAction(action);
    }
})
({
	// Method to toggle filter Section
    helperFilterSection : function(component,event,secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },
    
    getDisplayValue : function(component, event, helper){
        var action = component.get("c.getDashboardDisplay");
        /*action.setParams({
            dealId: component.get("v.recordId")
        });
        */
        action.setCallback(this,function(data){
            var state = data.getState();
            var responseMap = data.getReturnValue();
            if(state == "SUCCESS"){
                console.log('responseMap=>'+JSON.stringify(responseMap));
                //component.set("v.showHidePanel", JSON.parse(responseMap.displayDashBoard));
                component.set("v.displayDensity", responseMap.displayDensity);
            }else if(state = "ERROR"){
                //alert('Unknow error');
            }
            
        });
        $A.enqueueAction(action);
    },
    
    showHideDisplay: function(component, event, helper){
        if(component.get("v.showHidePanel")){
            component.set("v.showHidePanel", false);
        }else{
            component.set("v.showHidePanel", true);
        }
		/*var action = component.get("c.updateDashboardDisplay");
        action.setParams({
            dealId: component.get("v.recordId").
        });
        action.setCallback(this,function(data){
            var state = data.getState();
            var response = data.getReturnValue();
            if(state == "SUCCESS"){
                console.log('update=>'+response);
                component.set("v.showHidePanel", response);
            }else if(state = "ERROR"){
                //alert('Unknow error');
            }
            
        });
        $A.enqueueAction(action);
        */
	},
})
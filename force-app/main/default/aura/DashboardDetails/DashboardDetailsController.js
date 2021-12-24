({
    initRecords : function(component, event, helper) {
        helper.getDisplayValue(component, event, helper);
    },
    
	fiterSection : function(component, event, helper) {
        helper.helperFilterSection(component,event,'filter');
        helper.showHideDisplay(component, event, helper);
    },
})
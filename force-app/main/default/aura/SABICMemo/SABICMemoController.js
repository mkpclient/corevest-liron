({
    init : function(component, event, helper) {
        component.set("v.unsavedObj", {recordId : component.get("v.recordId"),
                                       loantype : null,
                                       liquidcashreserves : null,
                                       corevestapprovalmanager : null,
                                       otheradjustments : null,
                                       otheradjustmentstext : null,
                                       priorcvloans: null,
                                       everdeliquent : null,
                                      });
        //helper.getDealData(component,event);
        helper.attachPrintListener(component);
        helper.initializeIframe(component,event);
        
    },
    
    saveAndPrint: function(component, event, helper) {
        helper.saveAndPrint(component, event, helper);
    },
    cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})
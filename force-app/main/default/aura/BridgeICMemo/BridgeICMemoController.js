({
    init : function(component, event, helper) {
        component.set("v.unsavedObj", {dealId : component.get("v.recordId"),
                                       annualincomeyear : null,
                                       annualincome : null,
                                       recourse : null,
                                       glcapproveddate : null,
                                       repeatborrower: null,
                                       fundedborrower : null,
                                       deliquencyhistory : null,
                                       valuepsf : null,
                                       valueperunit : null,
                                       sponsorcostpsf : null,
                                       sponsorcpu: null,
                                       loanpsf : null,
                                       loanperunit : null
                                      });
        helper.getDealData(component,event);
        helper.attachPrintListener(component);
        helper.initializeIframe(component,event);
        
    },
    
    saveAndPrint: function(component, event, helper) {
        //helper.initializeIframe(component,event);
        helper.saveAndPrint(component, event, helper);
    },
    cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})
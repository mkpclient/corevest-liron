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
                                       loanperunit : null,
                                       exceptionComments: null
                                      });
        helper.getDealData(component,event);
        helper.attachPrintListener(component);
        helper.initializeIframe(component,event);
        
    },
    
    saveAndPrint: function(component, event, helper) {
        //helper.initializeIframe(component,event);
        if(component.get("v.unsavedObj.exceptionComments") != component.get("v.Deal.Exceptions_Comments_Explanations__c")) {
            helper.updateExceptionsComments(component, helper);
        }
        helper.saveAndPrint(component, event, helper);
    },
    cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})
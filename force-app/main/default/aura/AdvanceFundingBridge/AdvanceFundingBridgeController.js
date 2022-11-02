({
    init : function(component, event, helper) {
        component.set("v.details", {
            actualDscr: "",
            actualLtv: null,
            actualDebtYield: null,
            proformaRent: null,
            recordId: component.get("v.recordId")
        })
    },
    generate: function (component, event, helper) {
        if(component.get("v.details").actualDscr != null) {
            let dscrInputField = component.find("actualDscr");
            if(Array.isArray(dscrInputField)) {
                dscrInputField = dscrInputField[0];
            }

            dscrInputField.reportValidity();
            if(!dscrInputField.checkValidity()) {
                dscrInputField.focus();
                return;
            }
        }
        let action = component.get("c.downloadFile");
        action.setParams({ 
            jsonDetails: JSON.stringify(component.get("v.details"))
        });
        action.setCallback(this, result => {
            if(result.getState() === 'SUCCESS') {
                let downloadLink = document.createElement('a');
                downloadLink.download = 'advance-funding.pdf';
                downloadLink.href = 'data:application/pdf;base64,'+result.getReturnValue();
                downloadLink.click();
                $A.get("e.force:closeQuickAction").fire();

              } else {
                console.error(result.getError()[0].message);
              }
        });
        $A.enqueueAction(action);
    },
    cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})
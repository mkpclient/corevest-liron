({
    saveAndPrint : function(cmp, event, helper) {
        // var vfWindow = cmp.find("vfFrame").getElement().contentWindow;
        // console.log('unsavedObj----> '+JSON.stringify(cmp.get("v.unsavedObj")));
        // vfWindow.postMessage(JSON.stringify(cmp.get("v.unsavedObj")),'*');

        const encodedUri = encodeURI(JSON.stringify(cmp.get("v.unsavedObj")));
        const link = cmp.get("v.iframeBaseURL")+'?id='+cmp.get("v.recordId") + "&filtersJSON=" + encodedUri;
        window.open(link, "_blank");
        $A.get("e.force:closeQuickAction").fire();

    },
    getDealData: function(component, event) {
        var action = component.get("c.getData");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if(component.isValid() && response.getState() === "SUCCESS") {
                var responseObj = response.getReturnValue(); 
                component.set("v.Deal", responseObj);
            }else if(response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }else {
                    console.log("Unknown error");                                                         
                }
                
            }
        });
        
        $A.enqueueAction(action);
    },
    initializeIframe : function(cmp,event) {
        var action = cmp.get("c.getUrlAndInstance");
        action.setCallback(this, $A.getCallback(function(response) {
            if(response.getState() === "SUCCESS") {
                cmp.set("v.iframeBaseURL", response.getReturnValue())
                var checkForIframe = setInterval($A.getCallback(function() { 
                    if (typeof cmp.find("vfFrame") != "undefined" && cmp.find("vfFrame").getElement() != null) {
                        cmp.find("vfFrame").getElement().src = cmp.get("v.iframeBaseURL")+'?id='+cmp.get("v.recordId");
                        clearInterval(checkForIframe);
                    } 
                }),10);
            }
            else {
                alert('An error occured while fetching Salesforce URL. Please reload this page.');
                
            }
        }));
        $A.enqueueAction(action);
    },
    
    attachPrintListener : function(cmp,event) {
        var self=this;
        window.addEventListener("message", $A.getCallback(function(event) {
            if (event.data == "finished printing") 
            {
                console.log('Printing done.');
                $A.get("e.force:closeQuickAction").fire();
            }
        }))
    },
    
})
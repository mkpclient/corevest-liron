({
    saveAndPrint : function(cmp, event, helper) {
        var vfWindow = cmp.find("vfFrame").getElement().contentWindow;
        console.log('unsavedObj----> '+JSON.stringify(cmp.get("v.unsavedObj")));
        vfWindow.postMessage(JSON.stringify(cmp.get("v.unsavedObj")),'*');
        
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
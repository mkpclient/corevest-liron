({
    callAction: function(
        component,
        actionName,
        params,
        successCallback,
        failureCallback
    ) {
        //this.showSpinner( component );
        
        var action = component.get(actionName);
        
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this, function(response) {
            //this.hideSpinner( component );
            
            if (component.isValid() && response.getState() === "SUCCESS") {
                if (successCallback) {
                    successCallback(response.getReturnValue());
                }
            } else {
                console.error(
                    'Error calling action "' +
                    actionName +
                    '" with state: ' +
                    response.getState()
                );
                
                if (failureCallback) {
                    failureCallback(response.getError(), response.getState());
                } else {
                    this.logActionErrors(component, response.getError());
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    logActionErrors: function(component, errors) {
        if (errors) {
            for (var index in errors) {
                console.error("Error: " + errors[index].message);
            }
        } else {
            console.error("Unknown error");
        }
    },
    
    base64ToArrayBuffer: function(base64) {
        var binary_string = window.atob(base64);
        var len = binary_string.length;
        var bytes = new Uint8Array(len);
        // console.log(binary_string);
        console.log(len);
        for (var i = 0; i < len; i++) {
            bytes[i] = binary_string.charCodeAt(i);
        }
        return bytes.buffer;
    },
    
    serverSideCall: function(action, component) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else if (component.isValid() && state === "ERROR") {
                    reject(new Error(response.getError()));
                }
            });
            $A.enqueueAction(action);
        });
    }
});
({
    init: function(component, event) {
        var action = component.get("c.getRecord");
        action.setParams({
            dealId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if(component.isValid() && response.getState() === "SUCCESS") {
                var responseObj = response.getReturnValue(); 
                component.set("v.records", responseObj);
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
    addRow : function(component, event, helper){
        var createContact = $A.get("e.force:createRecord");
        createContact.setParams({
            "entityApiName": "Loan_Status__c",
            "defaultFieldValues": {
                "Deal__c": component.get("v.recordId")
            },
            "navigationLocation":"LOOKUP",
            "panelOnDestroyCallback": function(event) {
                helper.init(component, event);
            }
            
        });
        createContact.fire();
        
    },
    
    deleteRecord : function(component, event, helper, recordId){
        var action = component.get("c.deleteRecord");
        action.setParams({
            recordId : recordId,
            dealId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if(component.isValid() && response.getState() === "SUCCESS") {
                alert('Record deleted successfully.');
                var responseObj = response.getReturnValue(); 
                component.set("v.records", responseObj);
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
    editRecord : function(component, event, helper, recordId){
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId,
            "panelOnDestroyCallback": function(event) {
                helper.init(component, event);
            }
        });
        editRecordEvent.fire();        
    },
    
    refresh : function(component, event){
        this.init(component, event);
    },
    
    
    
})
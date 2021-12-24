({
    init : function(component, event, helper) {
        let action = component.get('c.getRelationshipManager');

        action.setParams({recordId: component.get('v.recordId')});

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                console.log(JSON.parse(response.getReturnValue()));
                component.set('v.relationshipManager', JSON.parse(response.getReturnValue()));
            }else if(state === 'ERROR'){
                console.log(response.getError());
            }
        });

        $A.enqueueAction(action);
    }
})
({
    init: function (component, event, helper) {
        let action = component.get('c.getUnderwriter');

        action.setParams({ recordType: component.get('v.recordType') });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                console.log(JSON.parse(response.getReturnValue()));
                component.set('v.underwriter', JSON.parse(response.getReturnValue()));
            } else if (state === 'ERROR') {
                console.log(response.getError());
            }
        });

        $A.enqueueAction(action);
    }
})
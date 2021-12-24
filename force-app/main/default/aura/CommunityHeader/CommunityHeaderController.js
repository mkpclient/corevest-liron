({
    init: function (component, event, helper) {
        console.log('init');

        let action = component.get('c.getPortalUser');

        // // action.setParams({ recordId: component.get('v.recordId') });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                console.log(JSON.parse(response.getReturnValue()));
                component.set('v.user', JSON.parse(response.getReturnValue()));
            } else if (state === 'ERROR') {
                console.log(response.getError());
            }
        });

        $A.enqueueAction(action);
        console.log('init2');
    }
})
({
	init : function(component, event, helper) {
		var recordId = component.get('v.recordId');
		console.log(recordId);

		//
		var action = component.get('c.givePortalAccess');

		action.setParams({'recordId': recordId});
		action.setCallback(this, function(response){
			var state = response.getState();

				var toastEvent = $A.get("e.force:showToast");
			    toastEvent.setParams({
			        "title": "Success!",
			        "message": "Access has been given"
			    });
			    toastEvent.fire();
				$A.get("e.force:closeQuickAction").fire();
			if(state == 'SUCCESS'){
				console.log('success');
			}else if(state === 'ERROR'){
				component.set('v.errorMessage', 'Error granting access to one or more contacts');
			}
		});

		$A.enqueueAction(action);
	}
})
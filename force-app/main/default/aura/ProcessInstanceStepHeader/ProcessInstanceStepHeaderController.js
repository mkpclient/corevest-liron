({
	init : function(component, event, helper) {
		let action = component.get('c.returnInstanceStep');
		action.setParams({recordId: component.get('v.recordId')});
		action.setCallback(this, function(response){
			let state = response.getState();
			if (state === 'SUCCESS'){
				let returnVal = response.getReturnValue();
				console.log(returnVal);
				component.set('v.record', returnVal);
				// component.set('v.status', returnVal.Status);
			} else {
				console.log(response.getError());
			}
		});
		$A.enqueueAction(action);
	}
})
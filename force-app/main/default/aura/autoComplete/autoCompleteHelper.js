({
	setRecord : function(component, lookupId) {
		var action = component.get('c.getRecord');

		action.setParams({ i : lookupId});

		action.setCallback(this, function(response){
			var state = response.getState();

			if(state === 'SUCCESS'){
				console.log(JSON.parse(response.getReturnValue()));
				var record = JSON.parse(response.getReturnValue());
				component.set('v.searchTerm', record['Name']);
				//component.set('v.record', JSON.parse(response.getReturnValue());
			}else if(state === 'ERROR'){
				console.log('error setting record');
			}
		});

		$A.enqueueAction(action);
	}
})
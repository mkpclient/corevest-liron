({
	setRecord : function(component, lookupId) {
		var action = component.get('c.getRecord');

		action.setParams({ i : lookupId});

		action.setCallback(this, function(response){
			var state = response.getState();

			if(state === 'SUCCESS'){
				console.log(JSON.parse(response.getReturnValue()));
				console.log(JSON.parse(JSON.stringify(component.get("v.record"))));
				var record = JSON.parse(response.getReturnValue());
				component.set('v.searchTerm', record['Name']);
				//component.set('v.record', JSON.parse(response.getReturnValue());
			}else if(state === 'ERROR'){
				console.log('error setting record');
			}
		});

		$A.enqueueAction(action);
	},

	valueChangeEvent: function(component, helper) {
		if((component.get("v.fieldName") != null || component.get("v.fieldName").length > 0) ) {
			const cmpEvent = component.getEvent("valueChangeEvent");
			cmpEvent.setParams({
					"row" : component.get("v.row"),
					"rowIdx" : component.get("v.rowIdx"),
					"fieldName" : component.get("v.fieldName")
			});
			cmpEvent.fire();    
	}
	}
})
({
	getRecordTypeName : function(component, helper) {
		var action = component.get('c.getRecordTypeName');
		action.setParams({
			i : component.get('v.recordId')
		});

		action.setCallback(this, function(response){
			var state = response.getState();

			if(state === 'SUCCESS'){
				component.set('v.recordTypeName', response.getReturnValue());
				console.log(response.getReturnValue());
				console.log(component.get('v.recordTypeName'));

				//helper.getProp

			}else if(state === 'ERROR'){
				console.log('error');
			}
		});

		$A.enqueueAction(action);
	},

	getPropertyPicklists : function(component, helper) {
		var action = component.get('c.getPropertyPicklists');
		action.setParams({
			dealId : component.get('v.recordId')
		});

		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				//console.log(JSON.parse(response.getReturnValue()));
				var picklistValues = [];
				picklistValues.push({
					value: '',
					label: ''
				});

				picklistValues = picklistValues.concat(JSON.parse(response.getReturnValue()));

				component.set('v.propertyOptions', picklistValues);

				//var select = component.find('propertySelect');
				//console.log(select);//.set('v.options', picklistValues);

			}else if(state === 'ERROR'){
				console.log('error');
			}
		})

		$A.enqueueAction(action);
	},


})
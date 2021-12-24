({
	init : function(component, event, helper){
		console.log('init');

		var dealId = location.hash;
		component.set('v.recordId', dealId.split('#!')[1]);
		console.log(component.get('v.recordId'));

		var action = component.get('c.getUser');
		action.setStorable();
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				component.set('v.user', JSON.parse( response.getReturnValue() ));
				console.log(component.get('v.user'));

				//helper.getLayout(component);
				helper.getFieldTypeMap(component, helper);

			}else{
				console.log('error');
				console.log(response);
			}
		});
		$A.enqueueAction(action);
	}
})
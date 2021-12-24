({
	init : function(component, event, helper) {

		var action = component.get('c.getUser');
		action.setStorable();
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				component.set('v.user', JSON.parse( response.getReturnValue() ));
				var user = component.get('v.user');
				if(user.userType == 'borrower'){
					// helper.queryBorrowerDeals(component);
				}else{
					// helper.queryVendorDeals(component);
				}
			}else{
				console.log('error');
				console.log(response);
			}
		});
		$A.enqueueAction(action);

	},

	search : function(component, event, helper){
		helper.searchDocuments(component, helper);
	},	

	inputKeyPress : function(component, event, helper){
		if(event.which == 13){
			helper.searchDocuments(component, helper);
		}
	}
})
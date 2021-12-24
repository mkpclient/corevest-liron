({
	init : function(component, event, helper) {

		component.find('util').getUserId(function(response){
			var userId = response;

			if(!$A.util.isEmpty(userId)){
				component.find('util').query('SELECT Id AccountId FROM User WHERE Id =\'' + userId + '\'', function(data){
					
				});
			}
		})

	}
})
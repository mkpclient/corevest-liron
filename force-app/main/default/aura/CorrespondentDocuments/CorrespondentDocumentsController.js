({
	init : function(component, event, helper) {
		helper.queryFiles(component);
	},

	refresh : function(component, event, helper){
		helper.queryFiles(component);
	},

	openDocument : function(component, event, helper){

		$A.get('e.lightning:openFiles').fire({
		        recordIds: [event.srcElement.dataset.id]
		    });

	}
})
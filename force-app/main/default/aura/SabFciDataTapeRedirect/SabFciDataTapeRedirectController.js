({
	redirect : function(component, event, helper) {
		var recordId = component.get('v.recordId');
		console.log('--record id--');
		console.log(recordId);
		var evt = $A.get("e.force:navigateToComponent");
		evt.setParams({
			componentDef : 'c:SabFciDataTape',
			componentAttributes : {
				recordId: recordId,
				isRedirect: true
			}
		});

		evt.fire();

	}
})
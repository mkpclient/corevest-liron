({
	init : function(component, event, helper) {
		var queryString = `SELECT Id, Name, Amount__c, Draw_Date__c FROM Draw__c WHERE Property__c = '${component.get("v.recordId")}' ORDER BY Draw_Number__c ASC`;
		console.log(queryString);

		component.find('util').query(queryString, data => {
			component.set('v.records', data);
		});

	},

	handleClick : function(component, event, helper){
		event.preventDefault();
		console.log('click');

		console.log(event.target);
		var recordId = event.target.title;
		console.log(recordId);
		component.find('navService').navigate({
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'Draw__c',
				recordId: recordId,
				actionName: 'view'
			}
		});
		
		// var navEvt = $A.get("e.force:navigateToSObject");
  //           navEvt.setParams({
  //             "recordId": event.getSource().get('v.title')
  //           });
  //           navEvt.fire();
	},
})
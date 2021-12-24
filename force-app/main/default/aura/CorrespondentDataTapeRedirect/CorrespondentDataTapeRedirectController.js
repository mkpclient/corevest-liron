({
	redirect : function(component, event, helper) {
		console.log('redirect');

		var sobjectType = component.get('v.sObjectName');
		var recordId = component.get('v.recordId');

		console.log(recordId);
		console.log(sobjectType);


		var isCommunity = location.href.indexOf('one.app') == -1;


		var evt = $A.get('e.force:navigateToComponent');
		evt.setParams({
			componentDef : "c:CorrespondentDataTape",
			componentAttributes: {
				recordId: recordId,
				sobjectType: sobjectType,
				isCommunity: isCommunity
			}
		});

		console.log(isCommunity);

		if(isCommunity){
			console.log('i am community');
			location.href ='/correspondent/s/datatape-import#!'+ recordId + '#!' + sobjectType;
		}else{
			evt.fire();
		}
		//evt.fire();

	}
})
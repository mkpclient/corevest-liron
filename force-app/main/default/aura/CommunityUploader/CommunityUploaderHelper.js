({
	getRecordTypeName : function(component, helper) {
        let action = component.get('c.getRecordTypeName');
        const sObjectName = component.get('v.sobjectType');
        
        if(sObjectName === 'Property__c' || sObjectName === 'Advance__c'){
            action = component.get('c.getDealRecordTypeName');
        } 
       	
        
		action.setParams({
			i : component.get('v.recordId')
		});

		action.setCallback(this, function(response){
			var state = response.getState();

			if(state === 'SUCCESS'){
                
				let recordType = response.getReturnValue();
                console.log('--recordtype--', recordType);
				if(recordType.includes('Bridge')){
					recordType = 'LOC_Loan';
				}

				component.set('v.recordTypeName', response.getReturnValue());

				//helper.getProp

			}else if(state === 'ERROR'){
				console.log('error');
			}
		});

		$A.enqueueAction(action);
	}
})
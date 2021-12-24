({
	init : function(component, event, helper){

		// var action = component.get('c.getPropertyPicklists');
		// action.setParams({
		// 	dealId : component.get('v.recordId')
		// });

		// action.setCallback(this, function(response){
		// 	var state = response.getState();
		// 	if(state === 'SUCCESS'){
		// 		//console.log(JSON.parse(response.getReturnValue()));
		// 		var picklistValues = [];
		// 		picklistValues.push({
		// 			value: '',
		// 			label: ''
		// 		});

		// 		picklistValues = picklistValues.concat(JSON.parse(response.getReturnValue()));

		// 		component.set('v.propertyOptions', picklistValues);

		// 		//var select = component.find('propertySelect');
		// 		//console.log(select);//.set('v.options', picklistValues);

		// 	}else if(state === 'ERROR'){
		// 		console.log('error');
		// 	}
		// })

		// $A.enqueueAction(action);

		component.find('util').query('SELECT Id, Name, Address__c FROM Trade_Deal__c WHERE Trade__c = \'' + component.get('v.recordId')+ '\'', function(data){
			
			console.log(data);
			var picklistValues = [];

			picklistValues.push({
				value: '',
				label: ''
			});

			data.forEach(function(deal){
				picklistValues.push({
					value: deal.Id,
					label: deal.Address__c
				});
			});

			console.log(picklistValues);

			component.set('v.propertyOptions', picklistValues);
			//component.set('v.propertyOptions')

		})


	},

	propertyIdChange : function(component, event, helper){
		console.log(component.get('v.propertyId'));

		var select = event.getSource();

		console.log(select.get('v.value'));
	},

	handleActive : function(component, event, helper){
		var tab = event.getSource();

		console.log(tab.get('v.id'));

		if(tab.get('v.id') == 'tradeSingle'){
			component.set('v.tradeBulkSelected', false);
		}else if(tab.get('v.id') == 'tradeBulk'){
			component.set('v.tradeSingleSelected', false);
		}else if(tab.get('v.id') == 'propertySingle'){
			component.set('v.propertyBulkSelected', false);
		}else if(tab.get('v.id') == 'propertyBulk'){
			component.set('v.propertySingleSelected', false);
		}

		component.set('v.' + tab.get('v.id') + 'Selected', true);
	},

	handleSelect : function(component, event, helper){
		var tab = event.getSource();

		component.set('v.tradeSelected', false);
		component.set('v.propertySelected', false);

		component.set('v.' + tab.get('v.id') + 'Selected', true);

	}
})
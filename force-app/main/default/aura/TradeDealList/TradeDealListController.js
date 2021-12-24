({
	init : function(component, event, helper) {
		console.log('init');

		helper.queryTradeAndDeals(component);

	},

	confirmDelete : function(component, event, helper){
		var deals = component.get('v.deals');

		var selectedDeals = [];

		deals.forEach(function(deal){
			if(deal.selected){
				selectedDeals.push(deal);
			}
		});

		if(selectedDeals.length > 0){
			component.set('v.dealsToDelete', selectedDeals);
			helper.toggleDeleteModal(component);
		}
	},

	deleteDeals : function(component, event, helper){
		var dealsToDelete = component.get('v.dealsToDelete');

		component.find('util').delete(dealsToDelete, function(response){
			helper.queryTradeAndDeals(component);
			helper.toggleDeleteModal(component);
		})
	},

	markDeals : function(component, event, helper){
		var deals = component.get('v.deals');

		var selectedDeals = [];

		deals.forEach(function(deal){
			//console.log(deal);
			if(deal.selected){
				deal.Exception__c = true;

				//selectedDeals.push(deal);
			}
		});

		component.find('util').upsert(deals, function(response){
			helper.queryTradeAndDeals(component);
		})




		//console.log(selectedDeals.length);

	},

	selectAll : function(component, event, helper){

		//console.log('select all');
		var selected = component.get('v.checked');
		//console.log(selected);
		var deals = component.get('v.deals');

		deals.forEach(function(deal){
			deal.selected = selected;
		});

		component.set('v.deals', deals);
	},

	closeDeleteModal : function(component, event, helper){
		helper.toggleDeleteModal(component);
	}

})
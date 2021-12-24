({
	init : function(component, event, helper){

		helper.callAction(helper.queryAdvance(component), component)
		.then( $A.getCallback(function(data){
			var advance = data[0];
			console.log(advance);

			component.set('v.advance', advance);
			component.set('v.deal', advance.Deal__r);

			var propertyAdvances = advance.Property_Advances__r || [];

			var propertyIds = '(';
			propertyAdvances.forEach(function(p){
				propertyIds += '\'' + p.Property__c + '\', ';
			});

			propertyIds = propertyIds.substr(0, propertyIds.lastIndexOf(',') == -1 ? propertyIds.length : propertyIds.lastIndexOf(','));
			propertyIds += ')';

			component.set('v.propertyIds', propertyIds);
			return helper.callAction(helper.queryProperties(component), component);
		})
		).then($A.getCallback(function(data){
			component.set('v.properties', data);
		}));

	},

	add : function(component, event, helper){
		component.find('addBtn').set('v.disabled', true);
		$A.util.removeClass(component.find('spinner'), 'slds-hide');
		var checkboxes = component.find('checkbox');
		var properties = component.get('v.properties');

		var advance = component.get('v.advance');
		var deal = component.get('v.deal');
		console.log(advance);
		var propIds = [];

		var advanceAmountTotal = 0;

		console.log(checkboxes);

		if(!$A.util.isArray(checkboxes)){
			checkboxes = [checkboxes];
		}

		checkboxes.forEach(function(el, index){
			if(el.getElement().checked){
				advanceAmountTotal += properties[index].Advance_Fee_formula__c;
				propIds.push(properties[index].Id);
			}

		});

		//console.log(advanceAmountTotal);
		//console.log(deal.Max_Adva)

		var advFee = advance.Advance_Fee_Total__c || 0;

		if(propIds.length > 0){
			var deal = component.get('v.deal');

			if(deal.Max_Advance_Fee__c == 'Yes' && advanceAmountTotal > (deal.Advance_Fee_Remaining__c - advFee)){
				console.log('1');
				var prompt = component.find('prompt');
				var content = component.find('content');

				$A.util.removeClass(prompt, 'slds-hide');
				$A.util.addClass(content, 'slds-hide');
			}else{
				//create property advance
				helper.createPropAdvance(component, propIds);
				console.log('2');
			}

		}else{
			component.find('addBtn').set('v.disabled', false);
			$A.util.addClass(component.find('spinner'), 'slds-hide');
		}

		
	},

	continueAdvance : function(component, event, helper){
		// create property advance
		$A.util.removeClass(component.find('content'), 'slds-hide');
		$A.util.addClass(component.find('prompt'), 'slds-hide');

		var checkboxes = component.find('checkbox');
		var properties = component.get('v.properties');
		var advance = component.get('v.advance');
		var propIds = [];

		var advanceAmountTotal = 0;

		if(!$A.util.isArray(checkboxes)){
			checkboxes = [checkboxes];
		}

		var advFee = advance.Advance_Fee_Total__c || 0;

		checkboxes.forEach(function(el, index){
			if(el.getElement().checked){
				advanceAmountTotal += properties[index].Advance_Fee_formula__c;
				propIds.push(properties[index].Id);
			}

		});

		if(propIds.length > 0){
			var deal = component.get('v.deal');
			var feeAmount = (deal.Advance_Fee_Remaining__c - advFee)/propIds.length;
            helper.createPropAdvance(component, propIds,feeAmount);
		}
	},

	close : function(component, event, helper){
		$A.util.removeClass(component.find('content'), 'slds-hide');
		$A.util.addClass(component.find('prompt'), 'slds-hide');

		component.find('addBtn').set('v.disabled', false);
		$A.util.addClass(component.find('spinner'), 'slds-hide');

	}
})
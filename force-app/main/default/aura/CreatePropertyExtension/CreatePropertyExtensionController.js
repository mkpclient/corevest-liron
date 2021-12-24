({
	init : function(component, event, helper) {
		var dealId = component.get('v.recordId');

		var dealQueryString = 'SELECT Id, StageName, Current_Line_Maturity_Date__c, Original_Line_Maturity_Date__c, Name, Num_of_Property_Extensions__c FROM Opportunity WHERE Id =\'' + dealId + '\'';

		component.find('util').query(dealQueryString, function(data){
			if($A.util.isEmpty(data[0].Num_of_Property_Extensions__c)){
				data[0].Num_of_Property_Extensions__c = 1;
			}
			component.set('v.deal', data[0]);

			//console.log('--deal--');
			//console.log(component.get('v.deal'));
		});

		var propertyQueryString = 'SELECT Id, Name, State__c, City__c, Current_Interest_Rate__c, Status__c, Asset_Maturity_Date__c FROM Property__c';
		propertyQueryString += ' WHERE Deal__c =\'' + dealId + '\' AND (Status__c = \'Active\' OR Status__c = \'In Process\')';

		component.find('util').query(propertyQueryString, function(data){
			component.set('v.properties', data);
			//console.log('--properties--');
			//console.log(component.get('v.properties'));
		});
	},

	closeModal : function(component, event, helper){
		component.set('v.modalOpen', false);
	},

	add : function(component, event, helper){
		console.log('add');

		var checkboxes = component.find('checkbox');
		var properties = component.get('v.properties');

		//var advance = component.get('v.advance');
		var deal = component.get('v.deal');
		//console.log(advance);
		//var propIds = [];


		if(!$A.util.isArray(checkboxes)){
			checkboxes = [checkboxes];
		}

		var selectedProperties = [];

		checkboxes.forEach(function(el, index){
			if(el.getElement().checked){
				//advanceAmountTotal += properties[index].Advance_Fee_formula__c;
				//propIds.push(properties[index].Id);
				selectedProperties.push(properties[index]);
			}
		});

		console.log(selectedProperties);
		// component.set('v.propertyIds', propIds);

		if(!$A.util.isEmpty(selectedProperties)){
			var data = {
				'currentInterestRate': selectedProperties[0].Current_Interest_Rate__c,
				'currentMaturityDate': selectedProperties[0].Asset_Maturity_Date__c
			}

			component.set('v.data', data);
			component.set('v.selectedProperties', selectedProperties);
			component.set('v.inputScreen', true);
		}
	},

	createExtension : function(component, event, helper){
		console.log('create extension');
		var maturityDate = component.find('maturdate').get('v.value');
		var interestRate = component.find('rate').get('v.value');

		console.log(maturityDate);
		console.log(interestRate);

		if(!$A.util.isEmpty(maturityDate) && !$A.util.isEmpty(interestRate)){
			//console.log('insert');
			var extensions = [];

			component.get('v.selectedProperties').forEach(function(property){
				extensions.push({
					sobjectType: 'Property_Extension__c',
					Property__c: property.Id,
					New_Asset_Maturity_Date__c: maturityDate,
					New_Asset_Interest_Rate__c: interestRate*100,
					Original_Asset_Maturity_Date__c: property.Asset_Maturity_Date__c,
					Original_Interest_Rate__c: property.Current_Interest_Rate__c,
					Original_Line_Maturity_Date__c: component.get('v.deal').Original_Line_Maturity_Date__c,
					Extension__c: component.get('v.deal').Num_of_Property_Extensions__c
				});

			});

			extensions.push({
				sobjectType: 'Opportunity',
				Id: component.get('v.deal').Id,
				Num_of_Property_Extensions__c: (component.get('v.deal').Num_of_Property_Extensions__c + 1)
			})

			console.log(extensions);

			component.find('util').upsert(extensions, function(response){
				$A.get('e.force:refreshView').fire();
				component.set('v.modalOpen', false);

			})
		}
	}
})
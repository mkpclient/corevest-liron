({	
	init : function(component, event, helper){
		

		var recordId = component.get('v.recordId');
		var sobjectType = component.get('v.sObjectName');

		var queryString = 'SELECT ';
		if(sobjectType == 'Opportunity'){
			queryString += 'Requested_Max_initial_LTV_LTC__c, Requested_Total_Loan_LTC__c, Requested_ARV_LTV__c, Requested_Rehab_Holdback_Limit__c';
		}else if(sobjectType == 'Property__c'){
			queryString += 'Deal__r.Requested_Max_initial_LTV_LTC__c, Deal__r.Requested_Total_Loan_LTC__c, Deal__r.Requested_ARV_LTV__c, Deal__r.Requested_Rehab_Holdback_Limit__c';
		}

		queryString += ' FROM ' + sobjectType;
		queryString += ' WHERE Id = \'' + recordId + '\'';

		component.find('util').query(queryString, function(data){
			console.log(data);

			var maxInitialLTVLTC;
			var totalARVLTV;
			var rehabHoldbackLimit;
			var totalLoanLTC;
			if(sobjectType == 'Property__c'){
				maxInitialLTVLTC = $A.util.isUndefinedOrNull(data[0].Deal__r.Max_Initial_LTV_LTC__c) ? 0 : data[0].Deal__r.Max_Initial_LTV_LTC__c;
				totalARVLTV = $A.util.isUndefinedOrNull(data[0].Deal__r.Total_ARV_LTV__c) ? 0 : data[0].Deal__r.Total_ARV_LTV__c;
				rehabHoldbackLimit = $A.util.isUndefinedOrNull(data[0].Deal__r.Rehab_Holdback_Limit__c) ? 0 : data[0].Deal__r.Rehab_Holdback_Limit__c;
				totalLoanLTC = $A.util.isUndefinedOrNull(data[0].Deal__r.Total_Loan_LTC__c) ? 0 : data[0].Deal__r.Total_Loan_LTC__c;
			}

			var calculatorFields = {
					asIsValue: 0,
					afterRehabValue: 0,
					purchasePrice: 0,
					rehabBudget: 0,
					interestRate: 0,
					totalCostBasisValue: 0,
					maxInitialLTVLTC: maxInitialLTVLTC,
					totalARVLTV: totalARVLTV,
					rehabHoldbackLimit: rehabHoldbackLimit,
					totalLoanLTC: totalLoanLTC
			}

			console.log(calculatorFields);
			component.set('v.calculatorFields', calculatorFields);

			helper.calculateFields(component);


		})

		

	},


	toggleSection : function(component, event, helper) {

		var id = event.target.getAttribute('data-id');

		$A.util.toggleClass(component.find(id), 'slds-is-open');
		$A.util.toggleClass(component.find(id + '-icon'), 'slds-accordion__summary-action-icon');

	},

	calculateFields : function(component, event, helper){
		helper.calculateFields(component);
	}
})
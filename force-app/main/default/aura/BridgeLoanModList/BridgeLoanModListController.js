({
	init : function(component, event, helper) {

		var dealId = component.get('v.parentDealId') || component.get('v.recordId'); //$A.util.isEmpty(component.get('v.parentDealId')) ? component.get('v.recordId') : component.get('v.parentDealId');

		var fields = ['Id',
					  'Name',
					  'Loan_Mod_Type__c',
					  'StageName',
					  'Loan_Size__c',
					  'LOC_Commitment__c',
					  'CloseDate',
					  'Original_Line_Maturity_Date__c',
					  'Current_Line_Maturity_Date__c',
					  'Rate__c',
					  'LOC_Term__c',
					  'LTC__c',
					  'LTV__c',
					  'Aggregate_Funding__c',
					  ];

		var queryString = 'SELECT '
		fields.forEach(function(field){
			queryString += field + ', ';
		});

		queryString = queryString.substring(0, queryString.lastIndexOf(","));;
		queryString += ' FROM Opportunity WHERE Id =\'' + dealId + '\'';
		queryString += ' OR Parent_Deal__c = \'' + dealId + '\'';
		queryString += ' ORDER BY CreatedDate ASC';

		component.find('util').query(queryString, function(data){
			var summaryData = {
					requestedLoanAmount: 0,
					locCommitment: 0,
					closeDate: null,
					origMaturityDate: null,
					currentMaturityDate: null,
					termType: null,
					intrestRate: null,
					maxLTC: null,
					maxLTV: null,
					aggregateFunding: 0
			};
			if(!$A.util.isEmpty(data)){
				component.set('v.loanMods', data);

				data.forEach(function(deal, index){
					if(index == 0){
						summaryData.origMaturityDate = deal.Original_Line_Maturity_Date__c;
					}
					

					if(deal.StageName == 'Closed Won' || deal.StageName == 'Matured' || deal.StageName == 'Expired'){
						summaryData.closeDate = deal.CloseDate;
						summaryData.currentMaturityDate = deal.Current_Line_Maturity_Date__c;
						summaryData.interestRate = deal.Rate__c;
						summaryData.termType = deal.LOC_Term__c;
						summaryData.maxLTC = deal.LTC__c;
						summaryData.maxLTV = deal.LTV__c;

						summaryData.requestedLoanAmount += deal.Loan_Size__c || 0;
						summaryData.locCommitment += deal.LOC_Commitment__c || 0;
						summaryData.aggregateFunding += deal.Aggregate_Funding__c || 0;

					}

				});
				
			}
			component.set('v.summaryData', summaryData);
			
		});


	},

	handleClick : function(component, event, helper){
		// console.log('stuff');
		// console.log(event.target.getAttribute('id'));
		//console.log(event.srcElement);

		var evt = $A.get( 'e.force:navigateToSObject' );

	    evt.setParams({
	        'recordId' : event.target.getAttribute('id'),
	       
	    }).fire();
	}
})
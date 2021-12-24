({
	queryTradeAndDeals : function(component){
		var queryString = 'SELECT Id, Name, Address__c, Loan_ID__c, Exception__c, City__c, State__c, Trade__r.Correspondent__r.Name, Purchase_Price__c, Borrower_Name__c, Net_Proceeds__c';
		queryString += ' FROM Trade_Deal__c';
		queryString += ' WHERE Trade__c = \'' + component.get('v.recordId') + '\'';

		component.find('util').query(queryString, function(deals){
			
			deals.forEach(function(deal){
				deal.selected = false;
			});
			component.set('v.deals', deals);


		});

		queryString = 'SELECT Id, Proceed_to_Wire__c';
		queryString += ' FROM Trade__c';
		queryString += ' WHERE Id = \'' + component.get('v.recordId') + '\'';

		component.find('util').query(queryString, function(trade){
			component.set('v.trade', trade[0]);
		})
	}, 

	toggleDeleteModal : function(component){
		$A.util.toggleClass(component.find('modal'), 'slds-fade-in-open');
		$A.util.toggleClass(component.find('backdrop'), 'slds-backdrop_open');
	}
})
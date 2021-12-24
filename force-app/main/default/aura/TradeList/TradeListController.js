({
	init : function(component, event, helper) {

		var queryString = 'SELECT Id, Name, Status__c, Total_Drawn__c, Total_Loan_Amount__c, Deals__c, Number_of_Exception__c';
		queryString += ' FROM Trade__c';
		queryString += ' WHERE Correspondent__c =\'' + component.get('v.recordId') + '\'';
		queryString += 'Order BY CreatedDate Asc';

		component.find('util').query(queryString, function(trades){
			component.set('v.trades', trades);
		});
	}
})
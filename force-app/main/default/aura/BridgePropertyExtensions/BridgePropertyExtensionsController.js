({
	init : function(component, event, helper) {

		var propertyId = component.get('v.recordId'); //$A.util.isEmpty(component.get('v.parentDealId')) ? component.get('v.recordId') : component.get('v.parentDealId');

		var fields = ['Id',
					  'Name',
					  'Extension__c',
					  'Original_Asset_Maturity_Date__c',
					  'Original_Line_Maturity_Date__c',
					  'Current_Line_Maturity_Date__c',
					  'Original_Interest_Rate__c',
					  'CreatedBy.Name',
					  'CreatedById',
					  'Extension_Date__c',
					  'New_Asset_Interest_Rate__c',
					  'New_Asset_Maturity_Date__c'
					  ];

		var queryString = 'SELECT '
		fields.forEach(function(field){
			queryString += field + ', ';
		});

		queryString = queryString.substring(0, queryString.lastIndexOf(","));;
		queryString += ' FROM Property_Extension__c WHERE Property__c =\'' + propertyId + '\'';
		queryString += ' ORDER BY CreatedDate ASC';

		component.find('util').query(queryString, function(data){
			component.set('v.extensions', data);
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
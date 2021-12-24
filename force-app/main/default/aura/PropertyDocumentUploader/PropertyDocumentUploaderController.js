({
	init : function(component, event, helper) {

		if($A.util.isEmpty(component.get('v.recordTypeName'))){
			let queryString = `SELECT Id, RecordType.DeveloperName FROM Property__c`;
			queryString += ` WHERE Id = '${component.get('v.recordId')}'`;

			component.find('util').query(queryString, response => {

				let recordType = response[0].RecordType.DeveloperName;

				if(recordType.includes('Bridge') || recordType == "Ground_Up_Construction"){
					recordType = 'LOC_Loan';
				}

				component.set('v.recordType', recordType);

			}); 

		}

	}
})
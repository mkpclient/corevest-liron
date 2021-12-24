({
	init : function() {

		if($A.util.isEmpty(component.get('v.recordType'))){
			let queryString = `SELECT Id, RecordType.DeveloperName FROM Property`;
			queryString += ` WHERE Id = '${component.get('v.recordId')}'`;

			component.find('util').query(queryString, response =>{
				let recordType = response[0].RecordType.DeveloperName;

				recordType = recordType == 'Bridge_Renovation' ? 'LOC_Loan' : recordType;

				component.set('v.recordTypeName', recordType );

			});
		}

	}
})
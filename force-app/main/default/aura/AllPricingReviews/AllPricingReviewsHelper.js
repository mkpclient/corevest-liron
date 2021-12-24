({
	desiredFields : [
		'Name'
		, 'Approver__c'
		, 'Date_Acted__c'
        , 'Time_in_Approval__c'
		, 'Comments__c'
		, 'oppName'
        , 'oppOwner'
        , 'oppLoanSize'
		, 'Status_Text__c'
        , 'LOC_Loan_Type__c'
        , 'Product_Sub_Type__c'
        , 'LOC_Program_Type__c'
		, 'Deal_Stage_At_Time_of_Submission__c'
	],

	turnIntoArray : function(obj, cb) {
		var returnArr = [];
		for (var oppId in obj){
			returnArr.push(obj[oppId]);
		}
		return cb(returnArr);
	},

	sortDates : function(a, b){
		return Date.parse(b.lmd) - Date.parse(a.lmd);
	},

	toggleDirection : function(title,properties,parent,component,cb) {
		let field = title.split('-')[0];
		let direction = title.split('-')[1];
		let type = title.split('-')[2]

		if (direction == 'down'){
			if (null != type && type == 'date'){
				console.log('this is a date');
				properties.sort(function(a,b){
					var fieldA = a[field] ? Date.parse(a[field]) : 0;
					var fieldB = b[field] ? Date.parse(b[field]) : 0;
					return fieldA - fieldB;
				});
				parent.setAttribute('title',field + '-' + 'up-date');
			} else {
				properties.sort(function(a,b){
					var nameA = a[field] ? a[field].toUpperCase() : ' ';
					var nameB = b[field] ? b[field].toUpperCase() : ' ';
					if (nameA < nameB) {
					  return 1;
					}
					if (nameA > nameB) {
					  return -1;
					}
					return 0;
				});
				parent.setAttribute('title',field + '-' + 'up');
			}
			component.set('v.'+field, 'up');
		} else if (direction == 'up'){
			if (null != type && type == 'date'){
				console.log('this is a date');
				properties.sort(function(a,b){
					var fieldA = a[field] ? Date.parse(a[field]) : 0;
					var fieldB = b[field] ? Date.parse(b[field]) : 0;
					return fieldB - fieldA;
				});
				parent.setAttribute('title',field + '-' + 'down-date');
			} else {
				properties.sort(function(a,b){
					var nameA = a[field] ? a[field].toUpperCase() : ' ';
					var nameB = b[field] ? b[field].toUpperCase() : ' ';
					if (nameA < nameB) {
					  return -1;
					}
					if (nameA > nameB) {
					  return 1;
					}
					return 0;
				});
				parent.setAttribute('title',field + '-' + 'down');
			}
			component.set('v.'+field, 'down');
		}
		cb(properties);
	}
})
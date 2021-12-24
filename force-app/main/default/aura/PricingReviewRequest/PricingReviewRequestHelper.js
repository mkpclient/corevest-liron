({
	toggleHide : function(component, name){
		$A.util.toggleClass(component.find(name), 'slds-hide');
	},

	parseData : function(returnVal, cb){
		var error = '';
		if (returnVal.wrongUser){
			error += 'You must be the originator in order to submit the pricing review. ';
		}
		if (returnVal.wrongStage){
			error += 'Inavlid Stage for Pricing Review Request. ';
		}
		if (Array.isArray(returnVal.nullFields) ){
			let list = returnVal.nullFields;
			let listStr = list.join(', ') + '.';
			error += 'These fields must be completed before initiating the pricing review: ';
			error += listStr;
		}
		cb(error);
	}
})
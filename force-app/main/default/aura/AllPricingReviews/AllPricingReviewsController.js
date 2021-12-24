({
	init : function(component, event, helper) {
		let action = component.get('c.returnAllReviews');
		action.setCallback(this, function(response){
			let state = response.getState();
			if (state == 'SUCCESS'){
				var returnVal = JSON.parse(response.getReturnValue());
				console.log('getting back pricing reviews: ');
				console.log(returnVal);
				helper.turnIntoArray(returnVal, function(returnArr){
					returnArr.sort(helper.sortDates);
					var submittedDeals = [];
					var resubmittedDeals = [];
					for (let i = 0; i < returnArr.length; i++){
						if (returnArr[i].reSubmitted === true){
							resubmittedDeals.push(returnArr[i]);
						} else {
							submittedDeals.push(returnArr[i]);
						}
					}



					console.log('these are resubmitted deals');
					console.log(resubmittedDeals);
                    
                    let newArr = submittedDeals;

					if (resubmittedDeals.length > 0) newArr = resubmittedDeals.concat(submittedDeals);

					console.log(newArr);
					component.set('v.records', newArr);
				});
			} else {
				console.log(response.getError());
			}
		});
		$A.enqueueAction(action);
	},

	sort : function(component, event, helper){
		console.log('sorting');
		let records = component.get('v.records');
		let tagName = event.target.tagName;
		console.log(tagName);
		if (tagName == 'use'){
			var parent = event.target.parentElement.parentElement.parentElement;
			var title = parent.getAttribute('title');
			console.log(title);
		}
		if (tagName == 'svg'){
			var parent = event.target.parentElement.parentElement;
			var title = parent.getAttribute('title');
			console.log(title);
		}

		if (title){
			helper.toggleDirection(title,records,parent,component,function(sortedArr){
				console.log(sortedArr);
				component.set('v.records',sortedArr);
			});
		}
	}
})
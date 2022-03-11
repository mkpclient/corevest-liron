({
	init : function(component, event, helper) {
		console.log('init start');
		let action = component.get('c.returnParentAndChild');
		action.setParams({recordId: component.get('v.recordId')});
		action.setCallback(this, function(response){
			let state = response.getState();
			if (state === 'SUCCESS'){
				// console.log('success');
				let returnVal = JSON.parse(response.getReturnValue());
				console.log(returnVal);
				component.set('v.record', returnVal.Deal);
				const parsedApprovalName = returnVal.hasOwnProperty('ProcessName') ? returnVal.ProcessName.split('_') : [];
				if(parsedApprovalName.length > 1 && parsedApprovalName.some(v => v.toUpperCase() == 'IC')){
					component.set("v.isIcApproval", true);
				}
				if (returnVal.Deal.Properties__r){
					let properties = returnVal.Deal.Properties__r.records.slice();
					component.set('v.properties', properties);
					console.log('this is properties');
					console.log(properties);
				}
			} else {
				console.log(response.getError());
			}
		});
		$A.enqueueAction(action);
	},

	showSection : function(component, event, helper){
		var tagName = event.target.tagName;
		var classList = event.target.classList;
		if (tagName == 'BUTTON'){
			var element = event.target.nextElementSibling;
			var image = event.target.firstElementChild;
		} else if (tagName == 'SPAN'){
			var element = event.target.parentElement.nextElementSibling;
			var image = event.target;
		}

		console.log(element);
		console.log(image);
		// let el = event.target.nextElementSibling;
		// console.log(el);
		if (element.getAttribute('data-state') === 'hidden'){
			element.classList.remove('hide');
			element.classList.add('shown');
			element.setAttribute('data-state', 'shown');
			image.innerHTML = '-';
		} else if (element.getAttribute('data-state') === 'shown'){
			element.classList.remove('shown');
			element.classList.add('hide');
			element.setAttribute('data-state', 'hidden');
			image.innerHTML = '+';
		}
	},

	sort : function(component, event, helper){
		// console.log('sorting');
		// console.log(event.target);
		// console.log(event.target.tagName);
		var properties = component.get('v.properties');
		let tagName = event.target.tagName;
		if (tagName == 'use'){
			var parent = event.target.parentElement.parentElement.parentElement;
			// console.log(parent);
			var title = parent.getAttribute('title')
			// console.log(title);
		}
		if (tagName == 'svg'){
			var parent = event.target.parentElement.parentElement;
			// console.log(parent);
			var title = parent.getAttribute('title')
			// console.log(title);
		}

		if (title){
			helper.toggleDirection(title,properties,parent,component,function(sortedArr){
				console.log(sortedArr);
				component.set('v.properties',sortedArr);
			});
		}
	}
})
({

	init : function(cmp, evt, helper) {

		// create instance of action in server-side controller
		var getTypeName = cmp.get('c.getRecordTypeName');
		var recordId = cmp.get('v.recordId');
		var getRecord = cmp.get('c.getLoanApplication');
		console.log(recordId);
		function sendAction(action, recordId, cb){
			action.setParams({ i : recordId});
			action.setCallback(this, cb);
			$A.enqueueAction(action);
		}

		sendAction(getTypeName, recordId, function(response){
				var state = response.getState();

				console.log(recordId);

				if (state === 'SUCCESS'){
					console.log(response.getReturnValue());
					if (response.getReturnValue() === 'Term Loan'){
						document.querySelector('.term-loan').classList.remove('hide');
					} else {
						document.querySelector('.bridge').classList.remove('hide');
					}
				} else {
					console.log('not a success');
				}
			}
		)

		sendAction(getRecord, recordId, function(response){
			//console.log(response.getState());
			//console.log(response.getReturnValue());
            var resp = JSON.parse(response.getReturnValue());
            //console.log(resp);
            //console.log(resp.Loan_Application_JSON__c);
            if(!$A.util.isEmpty(resp.Loan_Application_JSON__c)){
                var jsonForm = JSON.parse(resp.Loan_Application_JSON__c);
                //console.log(jsonForm);
    
                document.querySelectorAll('input').forEach(function(el){
                    if (el.type === 'text'){
                        el.value = jsonForm[el.name];
                    } else if (el.type === 'checkbox' && jsonForm[el.name]){
                        var checkedOptionsArr = jsonForm[el.name].split(',');
                        for (var i = 1; i < checkedOptionsArr.length; i++){
                            el.value === checkedOptionsArr[i] ? el.checked = true : false
                        }
                    } else if (el.type === 'radio') {
                            if (jsonForm[el.name] === 'true' && el.value === "true") {
                                    el.checked = true;
                            } else if (jsonForm[el.name] === 'false' && el.value === "false") {
                                    el.checked = true;
                            }
                    } // closes checkbox if
                }) // close forEach for querySelector
    
                document.querySelectorAll('textarea').forEach(function(el){
                    el.value = jsonForm[el.name];
                })
            }
			
		});

	}, // closes Init

	print : function(component, event, helper) {
		window.print();
	},

	save : function(cmp, evt, helper){
			var sendObj = {};

			document.querySelectorAll('input').forEach(function(el){
				if (el.type != 'checkbox' && !el.value){
					// Todo: some alert message in view saying to fill all fields
				}
				if (el.type === 'radio' && el.checked){
					sendObj[el.name] = el.value;
				}
				if (el.type != 'checkbox' && el.type != 'radio'){
					sendObj[el.name] = el.value;
				} else if (el.type === 'checkbox' && el.checked){
					sendObj[el.name] = sendObj[el.name] + ',' + el.value;
				}
			});

			document.querySelectorAll('textarea').forEach(function(el){
				sendObj[el.name] = el.value;
			});

			var action = cmp.get('c.upsertRecord');
			var record = {
				sobjectType: 'Opportunity',
				Id: cmp.get('v.recordId'),
				Loan_Application_JSON__c: JSON.stringify(sendObj)
			};

			console.log(record);

			action.setParams({
				record: record
			});

			action.setCallback(this, function(response){
				var state = response.getState();
				if (state === 'SUCCESS'){
					console.log('saved');
				} else {
					console.log(response.getError());
					console.log('no success');
				}
			});

			$A.enqueueAction(action);

		}, // closes debug method

		// I really wished this worked in Salesforce
		// validateEmail : function(cmp, evt, helper){
		// 	var emailFields = document.querySelectorAll('.email');
		// 	var emailNotices = document.querySelectorAll('.email-notice');
		// 	var regEx = /^[0-9a-zA-Z\.]+@[a-z]+\.[a-z]{2,4}$/;
		//
		// 	emailFields.forEach(function(el, idx){
		// 		el.addEventListener('blur', function(e){
		// 			if (regEx.test(el.value)){
		// 				emailNotices[idx].innerHTML = '';
		// 			} else {
		// 				console.log('not an email');
		// 				emailNotices[idx].innerHTML = 'Please enter a valid email.';
		// 			}
		// 		})
		// 	})
		// } // this closes validateEmail

		validateEmail : function(cmp, evt, helper){
				var regEx = /^[0-9a-zA-Z\.]+@[a-z]+\.[a-z]{2,4}$/;
				if (regEx.test(evt.target.value)){
					evt.target.parentNode.lastChild.innerHTML = '';
				} else {
					evt.target.parentNode.lastChild.innerHTML = 'Please enter a valid e-mail.';
				}
		},

		validatePhone : function(cmp, evt, helper){
			var regEx = /^\d{3}-\d{3}-\d{4}$/;
			if (regEx.test(evt.target.value)){
				evt.target.nextSibling.innerHTML = '';
			} else {
				evt.target.nextSibling.innerHTML = 'Please write phone number in xxx-xxx-xxxx format.';
			}
		},

		print : function(cmp, evt, helper){
			window.print();
		}

})
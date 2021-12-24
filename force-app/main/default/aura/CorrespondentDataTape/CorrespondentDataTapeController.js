({
	init : function(component, event, helper) {
		console.log('data tape init');

		console.log('recordId = ', component.get('v.recordId'));
		console.log('sobjectType = ', component.get('v.sobjectType'));

		console.log(location.hash);
		console.log(location.hash.split('#!'));

		if(component.get('v.isCommunity') && !$A.util.isEmpty(location.hash)){
			component.set('v.recordId', location.hash.split('#!')[1]);
			component.set('v.sobjectType', location.hash.split('#!')[2]);
		}


		if(component.get('v.isCommunity') && $A.util.isEmpty(component.get('v.recordId')) && $A.util.isEmpty(component.get('v.sobjectType'))){
			component.find('util').getUserId(function(response){
				var userId = response;
				console.log(userId);
				if(!$A.util.isEmpty(userId)){
					component.find('util').query('SELECT Id, AccountId FROM User WHERE Id =\'' + userId + '\'', function(data){
						var user = data[0];

						console.log(user);

						component.set('v.newTrade', true);
						component.set('v.sobjectType', 'Account');
						component.set('v.recordId', user.AccountId);

						helper.queryAccount(component, component.get('v.recordId'));

					});
				}
			})
		}
		else if(component.get('v.sobjectType') == 'Account'){
			component.set('v.newTrade', true);
			helper.queryAccount(component, component.get('v.recordId'));
		}else if(component.get('v.sobjectType') == 'Trade__c'){
			helper.queryTradeAndDeals(component, component.get('v.recordId'), helper);
		}

		helper.getTemplateId(component);	
	},

	save : function(component, event, helper){

		var trade = helper.compileTrade(component);

		component.find('util').upsert(trade, $A.getCallback(function(response){
			console.log(response);
			component.set('v.trade', response[0]);
			//var deals = helper.compileTradeDeals(component, response[0].Id);

//			if(!$A.util.isEmpty(component.get('v.dataTapeNeedToUpload'))){
//
//				console.log('attempting to insert file');
//
//				var req = {
//					data: component.get('v.dataTapeNeedToUpload'),
//					parentId: response[0].Id,
//					fileName: 'DataTape',
//					fileType: 'DataTape'
//				}
//
//				component.find('util').insertFileAndLink(JSON.stringify(req), function(d){
//					console.log('file uploaded');
//				});
//			}


			component.find('hot-table').getData(function(data){

				var columns = component.find('hot-table').get('v.columns');

				data.forEach(function(el){

					if(el.hasOwnProperty('_')){
						delete el['_'];
					}

					delete el['ARV_LTV__c'];
					delete el['Accrual_Days__c'];
					delete el['Accrued_Interest__c'];
					delete el['As_Is_Initial_LTV__c'];
					delete el['Days_From_Paid_Through_Date__c'];
					delete el['Effective_Loan_Amount__c'];
					delete el['Closed_Date_Acquired_Date__c'];
					

					el['sobjectType'] = 'Trade_Deal__c';

					for(var x in el){

						if(!$A.util.isEmpty(el[x]) && (x.includes('Date') || x == 'First_Payment__c' ) ){
							if(el[x] == 'N/A'){
								el[x] = null;
							}else{
								el[x] = $A.localizationService.formatDate(el[x], 'YYYY-MM-DD');
							}
						}

						if($A.util.isEmpty(el[x])){
							el[x] = null;
						}

						if(el[x] == '$0.00'){
							delete el[x];
						}

						if(x == 'State__c' && !$A.util.isEmpty(el[x]) && el[x].length == 2){
							el[x] = el[x].toUpperCase();
						}

						if(x.includes('__r')){
							delete el[x];
						}
					}

					 el['Trade__c'] = response[0].Id;
				});

				console.log(data);

				component.find('util').upsert(data, function(dat){
					// console.log(dat);
					var navEvt = $A.get('e.force:navigateToSObject');

					navEvt.setParams({
						recordId : component.get('v.trade').Id
					});

					navEvt.fire();
				},
				function(errors, state){
					var errorMsg = '';
					if ( errors ) {

						

					    for ( var index in errors ) {
					        //console.error( 'Error: ' + errors[index].message );
					        errorMsg += ' ' + errors[index].message;
					    }

				    	

					} else {
					    //console.error( 'Unknown error' );
					    errorMsg = 'Unknown error';
					}

					var toastEvent = $A.get("e.force:showToast");
				    toastEvent.setParams({
				        "title": "Error",
				        "message": errorMsg,
				        "mode": "dismissible",
				        "type": "error"
				    });
				    toastEvent.fire();

				});

			});
			


			
		}));

		console.log(trade);

	},

	toggleModal : function(component, event, helper){
		helper.toggleModal(component);
	},

	handleImport : function(component, event, helper){
		console.log('handling import');

		$A.util.toggleClass(component.find('spinner'), 'slds-hide');

		// console.log(component.find('fileUpload').get('v.files'));

		var file = component.find('fileUpload').get('v.files')[0];

		helper.readFile(file, component, helper);

		component.find('fileUpload').set('v.value', '');
		// component.find('fileUpload').set('v.files', []);

		
	},

	export : function(component, event, helper){
		// var action = com


		var columns = component.find('hot-table').get('v.columns');
		var queryString = 'SELECT Id, ';
		columns.forEach(function(column){
			if(column.get('v.data') != '_' && column.get('v.data') != 'Id'){
				queryString += column.get('v.data') + ', ';
			}
			
		});
		queryString = queryString.substring(0, queryString.lastIndexOf(','));
		queryString += ' FROM Trade_Deal__c WHERE Trade__c =\'' + component.get('v.recordId') + '\''; 

		component.find('util').query(queryString, $A.getCallback(function(data){
			// console.log(data);
			var deals = data;

			var action = component.get('c.getTemplate');

			action.setParams({
				fileName: 'Correspondent Import Tape'
			});

			action.setCallback(this, function(response){
				var state = response.getState();

				if(state == 'SUCCESS'){

					XlsxPopulate.fromDataAsync(helper.base64ToArrayBuffer(JSON.parse(response.getReturnValue() ) ) )
						.then(workbook => {
							var columns = component.find('hot-table').get('v.columns');
							var settlementDate = component.get('v.settlementDate');
							var tradeDate = component.get('v.tradeDate');

							if(!$A.util.isEmpty(tradeDate)){
								tradeDate = $A.localizationService.formatDate(tradeDate, 'MM/DD/YYYY');
								workbook.sheet(0).row(2).cell(9).value(tradeDate);
							}

							if(!$A.util.isEmpty(settlementDate)){
								settlementDate = $A.localizationService.formatDate(settlementDate, 'MM/DD/YYYY');
								workbook.sheet(0).row(3).cell(9).value(settlementDate);
							}
							

							for(var i = 0; i < deals.length; i++){
								for(var j =0; j < columns.length; j++){



									var prop = columns[j].get('v.data');

									if(columns[j].get('v.type') === 'date' && !$A.util.isEmpty(deals[i][prop])){
										deals[i][prop] = $A.localizationService.formatDate(deals[i][prop], 'MM/DD/YYYY');
									}

									if(columns[j].get('v.isPercent') && !$A.util.isEmpty(deals[i][prop])){
										deals[i][prop] = deals[i][prop]/100;
									}


									if(!$A.util.isEmpty(prop) && prop != '_' && !columns[j].get('v.isFormula')){
										workbook.sheet(0).row(12+i).cell(j+3).value(deals[i][prop]);
									}

								}
							}
							return workbook.outputAsync('base64');
						}).then(data => {
							var link = document.createElement("a");
							link.href = "data:" + XlsxPopulate.MIME_TYPE + ";base64," + data;
							link.download= "Correspondent DataTape.xlsx";
							link.click();
						});

				}else if(state == 'ERROR'){
					console.log('error');
					console.log(response.getError());
				}

			});

			$A.enqueueAction(action);

		}));

		

	},

	return : function(component, event, helper){
		var navEvt = $A.get('e.force:navigateToSObject');

		navEvt.setParams({
			recordId : component.get('v.recordId')
		});

		navEvt.fire();
	},

	// createTemplate : function(component, event, helper){

	// }
})
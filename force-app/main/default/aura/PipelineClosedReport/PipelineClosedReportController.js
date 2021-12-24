({
	createPipelineReport : function(component, event, helper){
		console.log('create pipeline report');

		$A.util.removeClass(component.find('spinner'), 'slds-hide');
		component.find('download').set('v.disabled', true);
		var fields = new Set();
		helper.PIPELINE_FIELDS.forEach( field => fields.add(field));
		helper.CLOSED_FIELDS.forEach( field => fields.add(field) );
		fields.delete('');
		fields.add('Awaiting_Kickoff_Call__c');

		var fieldList = Array.from(fields);


		var pipelineWhereClause = '(StageName IN (';
		helper.STAGES.forEach( field => pipelineWhereClause += '\'' + field + '\', ' );
		pipelineWhereClause = pipelineWhereClause.substr(0, pipelineWhereClause.lastIndexOf(','));
		pipelineWhereClause += ')';
		pipelineWhereClause += ' AND Type =\'Term Loan\' AND Account_Name__c != \'Inhouse Test Account\' AND Hold_Reason__c != \'In Process of Withdrawal/Rejection\')';
		pipelineWhereClause += ' OR (Type =\'Term Loan\' AND StageName = \'Closed Won\' AND Account_Name__c != \'Inhouse Test Account\' AND CloseDate = THIS_MONTH)';

		var pipelineOrderBy = "Awaiting_Kickoff_Call__c Asc, Anticipated_Closing_Date__c Asc, StageName DESC ";

		var pipelineQuery = component.get('c.getRecordList');

		pipelineQuery.setParams({
			fields : fieldList,
			sobjectType : 'Opportunity',
			whereClause : pipelineWhereClause,
			orderBy : pipelineOrderBy
		});

		var closedWhereClause = 'StageName IN (\'Closed Won\',\'Matured\',\'Paid Off\') AND Type = \'Term Loan\' AND Account_Name__c != \'Inhouse Test Account\' AND CloseDate != THIS_MONTH';
		var closedOrderBy = 'CloseDate ASC';

		var closedQuery = component.get('c.getRecordList');
		closedQuery.setParams({
			fields : fieldList,
			sobjectType : 'Opportunity',
			whereClause : closedWhereClause,
			orderBy : closedOrderBy
		});

		var pipelineData = [];
		var closedData = [];
		helper.callAction(pipelineQuery, component)
		.then($A.getCallback(function(data){
			//console.log(data);
			pipelineData = data;

			return helper.callAction(closedQuery, component);

		}))
		.then($A.getCallback(function(data){
			//console.log(data);
			closedData = data;
		}))
		.then($A.getCallback(

				function(){
					
					console.log('both done');

					var sheetClosed = {};
					var sheetPipeline = {};
					var months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December', 'Closed', 'Pending Kickoff', 'On Hold'];

					closedData.forEach( function(deal){
						var year = parseInt(deal.CloseDate.split('-')[0]);
						var month = parseInt(deal.CloseDate.split('-')[1]) - 1;
						helper.pushRecord(sheetClosed, year, months, month, deal);
					});

					var onHolds = [];

					pipelineData.forEach( function(deal){
						if(deal.StageName == 'Closed Won'){
							var year = parseInt(deal.Anticipated_Closing_Date__c.split('-')[0]);
							var month = parseInt(deal.Anticipated_Closing_Date__c.split('-')[1]) - 1;
							helper.pushRecord(sheetPipeline, year, months, 12, deal);
						}
					});

					pipelineData.forEach( function(deal){

						var pendingKickoffs = [];

						if(deal.StageName == 'UW Hold' && deal.hasOwnProperty('Anticipated_Closing_Date__c')){
							deal.StageName = 'On Hold';
							//var year = parseInt(deal.Anticipated_Closing_Date__c.split('-')[0]);
							//var month = parseInt(deal.Anticipated_Closing_Date__c.split('-')[1]) - 1;

							onHolds.push(deal);

							//helper.pushRecord(sheetPipeline, new Date().getFullYear(), months, 14, deal);
						}else 
						if(deal.Awaiting_Kickoff_Call__c){
							deal.StageName = 'Pending Kickoff';
							var year = parseInt(deal.Anticipated_Closing_Date__c.split('-')[0]);
							var month = parseInt(deal.Anticipated_Closing_Date__c.split('-')[1]) - 1;

							helper.pushRecord(sheetPipeline, new Date().getFullYear(), months, 13, deal);
						}
						else if(deal.StageName == 'Closed Won'){
							

						}else if (deal.hasOwnProperty('Anticipated_Closing_Date__c')){

							var year = parseInt(deal.Anticipated_Closing_Date__c.split('-')[0]);
							var month = parseInt(deal.Anticipated_Closing_Date__c.split('-')[1]) - 1;
							helper.pushRecord(sheetPipeline, year, months, month, deal);
						}
					});

					onHolds.forEach(function(deal){
						var year = parseInt(deal.Anticipated_Closing_Date__c.split('-')[0]);
						var month = parseInt(deal.Anticipated_Closing_Date__c.split('-')[1]) - 1;

						helper.pushRecord(sheetPipeline, new Date().getFullYear(), months, 14, deal);
					})

					// for(var property in sheetPipeline){
					// 	if(sheetPipeline.hasOwnProperty(property)){
					// 		for( var prop1 in sheetPipeline[property]){
					// 			if(sheetPipeline[property].hasOwnProperty(prop1)){
					// 				if($A.util.isArray(sheetPipeline[property][prop1])){
					// 					console.log('reverse?');
					// 					sheetPipeline[property][prop1].reverse();
					// 				}
					// 			}
					// 		}
					// 	}
					// }

					console.log(sheetPipeline);
					component.set('v.sheetClosed', sheetClosed);
					component.set('v.sheetPipeline', sheetPipeline);

					helper.download(component, helper);
				}
			)
		);
	},

	init : function(component, event, helper) {
		$A.util.removeClass(component.find('download'), 'slds-hide');
	},

	// download : function(component, event, helper){
	// 	console.log('click');
	//
	// 	var columnsPipeline = [
	// 		'Anticipated_Closing_Date__c',
	// 		'Loan_Coordinator_Name__c',
	// 		'Loan_Purpose__c',
	// 		'Deal_Loan_Number__c',
	// 		'LeadSource',
	// 		'Recourse__c',
	// 		'Term_Loan_Type__c',
	// 		'Amortization_Term__c',
	// 		'Spread_BPS__c',
	// 		'Floor__c',
	// 		'',
	// 		'StageName',
	// 		'Loan_Size__c',
	// 		'Owner_Name__c',
	// 		'Underwriter.Name',
	// 		'Loan_Coordinator_Name__c',
	// 		'Closer_Name__c',
	// 		'Bridge_Borrower__c',
	// 		'',
	// 		'Anticipated_IC_Approval__c',
	// 		'Kickoff_Date__c',
	// 		'Days_In_Underwriting__c'
	// 	];
	//
	// 	var columnsClosed = [
	// 		'Anticipated_Closing_Date__c',
	// 		'CloseDate',
	// 		'Loan_Coordinator_Name__c',
	// 		'Loan_Purpose__c',
	// 		'Deal_Loan_Number__c',
	// 		'LeadSource',
	// 		'Recourse__c',
	// 		'Term_Loan_Type__c',
	// 		'Amortization_Term__c',
	// 		'Spread_BPS__c',
	// 		'Floor__c',
	// 		'',
	// 		'StageName',
	// 		'Loan_Size__c',
	// 		'Final_Loan_Amount__c',
	// 		'Owner_Name__c',
	// 		'Underwriter.Name',
	// 		'Loan_Coordinator_Name__c',
	// 		'Closer_Name__c',
	// 		'Bridge_Borrower__c',
	// 		'',
	// 		'Anticipated_IC_Approval__c',
	// 		'Kickoff_Date__c',
	// 		'Days_In_Underwriting__c'
	// 	];
	//
	// 	var sheet0 = component.get('v.sheetPipeline');
	// 	var sheet1 = component.get('v.sheetClosed');
	//
	// 	var dbPipelinePrevious = {};
	// 	var dbClosedPrevious = {};
	// 	var currentYear = new Date().getFullYear();
	//
	// 	helper.archiveDb(sheet0, dbPipelinePrevious, currentYear);
	// 	helper.archiveDb(sheet1, dbClosedPrevious, currentYear);
	//
	// 	console.log('these are the previous databases');
	// 	console.log(dbPipelinePrevious);
	// 	console.log(dbClosedPrevious);
	//
	// 	var docPromise = new Promise(function(resolve, reject){
	// 		var action = component.get('c.getTemplate');
	// 		action.setParams({
	// 			fileName: 'PipelineClosedTemplate'
	// 		});
	// 		action.setCallback(this, function(response){
	// 			var state = response.getState();
	// 			if (state === 'SUCCESS'){
	// 				resolve(response.getReturnValue());
	// 			} else if (state === 'ERROR'){
	// 				reject(new Error(response.getError()));
	// 			}
	// 		});
	// 		$A.enqueueAction(action);
	// 	});
	//
	// 	docPromise.then(function(response){
	// 		XlsxPopulate.fromDataAsync(helper.base64ToArrayBuffer(JSON.parse(response)))
	// 			.then(workbook => {
	//
	// 				var offsetColumns = 2;
	// 				var offsetRows = 3;
	//
	// 				var offsetPipeline = helper.populateReportPreviousYears(dbPipelinePrevious, columnsPipeline, workbook, 0, 13, offsetRows, offsetColumns, 'Anticipated_Closing_Date__c', 'B', 'S', 'U', 'W');
	// 				var offsetClosed = helper.populateReportPreviousYears(dbClosedPrevious, columnsClosed, workbook, 1, 14, offsetRows, offsetColumns, 'Anticipated_Closing_Date__c', 'B', 'U', 'W', 'Y');
	//
	// 				if (sheet0[currentYear]){
	// 					helper.populateReportPreviousYears(sheet0[currentYear], columnsPipeline, workbook, 0, 13, offsetPipeline, offsetColumns, 'CloseDate', 'B', 'S', 'U', 'W');
	// 				}
	//
	// 				if (sheet1[currentYear]){
	// 					helper.populateReportPreviousYears(sheet1[currentYear], columnsClosed, workbook, 1, 14, offsetClosed, offsetColumns, 'CloseDate', 'B', 'U', 'W', 'Y');
	// 				}
	// 				return workbook.outputAsync('base64');
	// 		}).then(data => {
	// 			var link = document.createElement("a");
	// 			link.href = "data:" + XlsxPopulate.MIME_TYPE + ";base64," + data;
	// 			link.download= "PipelineReport.xlsx";
	// 			link.click();
	// 		}).catch(function(err){
	// 			console.log(err);
	// 		})
	// 	});
	// } // closes download

})
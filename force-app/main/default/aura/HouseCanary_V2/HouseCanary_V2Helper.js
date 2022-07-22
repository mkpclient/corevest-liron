({
	getProperties: function(component) {
		let recordId = component.get("v.recordId");
		let action = component.get("c.getProperties");
		action.setParams({
			recordId: recordId,
		});
		action.setCallback(this, (response) => {
			let res = response.getReturnValue();
			let state = response.getState();
			let error = response.getError();
			if (state == 'SUCCESS') {
				let pageSize = component.get("v.pageSize");
				component.set("v.properties", res.properties);
				component.set("v.maxPage", Math.ceil(res.properties.length / pageSize));
				component.set("v.tableData", this.getTableData(component));
			}
			else {
				this.showToast('error', error[0].message);
			}
			this.hideSpinner(component);
		});
		this.showSpinner(component);
		$A.enqueueAction(action);
	},

	getColumns: function() {
		return [
						{label: 'Address', fieldName: 'RelativeUrl', type: 'url', typeAttributes: {label: {fieldName: 'Name'}, target: '_top'}},
						{label: 'City', fieldName: 'City__c', type: 'text'},
						{label: 'State', fieldName: 'State__c', type: 'text'},
						{label: 'Zip', fieldName: 'ZipCode__c', type: 'text'},
						{label: 'APN', fieldName: 'APN__c'},
						{label: 'Borrower Provided Rent/Estimated Rent', fieldName: 'Estimated_Rent__c'},            
						{label: 'BOV/CalcAve'},
						{label: 'Property Type'},
            			{label: '# of Stories'},            
					//	{label: 'Is HOA'},
						{label: 'Bed', fieldName: 'Number_of_Beds__c'},
						{label: 'Bath', fieldName: 'Number_of_Bath__c'},
						{label: 'Square Feet', fieldName: 'Square_Feet__c'},
						{label: 'Year Built', fieldName: 'Year_Built__c'},
						{label: 'Last Sold Date'},
						{label: 'Last Sold Price'},
            			{label: 'Tax Year'},
            			{label: 'Tax Amount'},            
            			{label: 'Mortgage Lien'},
            			{label: 'Sale History'},
            		//	{label: 'Block Crime'},
            			{label: 'Tax History'},
            			{label: 'Value Report PDF Link'},
					 ];
	},

	getTableData: function(component) {
		let properties = component.get("v.properties");
		let tableData = properties.map((prop) => ({
			Invalid_Address__c: prop.Invalid_Address__c,
			Selected: prop.selected,
			Id: prop.Id,
			Name: prop.Name,
			RelativeUrl: '/' + prop.Id,
			City__c: prop.City__c,
			State__c: prop.State__c,
			ZipCode__c: prop.ZipCode__c,
			Active__c: prop.Active__c ? 'Yes' : 'No',
            no_of_stories: prop.No_of_Stories__c  != null ?prop.No_of_Stories__c:null,             
			Number_of_Beds__c: prop.Number_of_Beds__c,
			Number_of_Bath__c: prop.Number_of_Bath__c,
			Square_Feet__c: prop.Square_Feet__c,
			Year_Built__c: prop.Year_Built__c,
			APN__c: prop.APN__c,
			Is_HOA__c: prop.Is_HOA__c,
            Monthly_Rent__c  : prop.Monthly_Rent__c  != null ? '$' + prop.Monthly_Rent__c  : null,            
            value_report_static_Link__c:prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_AVMs__r[0].value_report_static_Link__c != null ? prop.Property_AVMs__r[0].value_report_static_Link__c:null,
            value_report_static_Link__c_link:prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_AVMs__r[0].value_report_static_Link__c != null ? prop.Name + ' - Value Report PDF Link':null,
			Property_Type__c: prop.Property_Type__c,
            Calc_AveValue__c:prop.Calc_AveValue__c != null ? '$' + prop.Calc_AveValue__c.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,').slice(0, -3) : null,
			Borrower_Opinion_of_Current_Value__c: prop.Borrower_Opinion_of_Current_Value__c != null ? '$' + prop.Borrower_Opinion_of_Current_Value__c.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,').slice(0, -3) : null,
            Show_select_check_box:prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].HouseCanary_Sync_Allowed__c : 'Yes',
			House_Canary_Address__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Address__c : null,
			Diff_House_Canary_Address__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Name && prop.Name != prop.Property_AVMs__r[0].AVM_Address__c : null,
			House_Canary_City__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_City__c : null,
			Diff_House_Canary_City__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.City__c && prop.City__c != prop.Property_AVMs__r[0].AVM_City__c,
			House_Canary_State__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ?  prop.Property_AVMs__r[0].AVM_State__c : null,
			Diff_House_Canary_State__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.State__c && prop.State__c != prop.Property_AVMs__r[0].AVM_State__c,
			House_Canary_Zip__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_ZIP__c : null,
			Diff_House_Canary_Zip__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.ZipCode__c && prop.ZipCode__c != prop.Property_AVMs__r[0].AVM_ZIP__c,
			House_Canary_Beds__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].number_of_bedrooms__c : null,
			Diff_House_Canary_Beds__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Number_of_Beds__c && prop.Number_of_Beds__c != prop.Property_AVMs__r[0].number_of_bedrooms__c,
			House_Canary_Baths__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].total_bath_count__c : null,
			Diff_House_Canary_Baths__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Number_of_Bath__c && prop.Number_of_Bath__c != prop.Property_AVMs__r[0].total_bath_count__c,
			House_Canary_Square_Feet__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Square_Feet__c : null,
			Diff_House_Canary_Square_Feet__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Square_Feet__c && prop.Square_Feet__c != prop.Property_AVMs__r[0].AVM_Square_Feet__c,
			House_Canary_Year_Built__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Year_Built__c : null,
			Diff_House_Canary_Year_Built__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Year_Built__c && prop.Year_Built__c != prop.Property_AVMs__r[0].AVM_Year_Built__c,
			House_Canary_APN__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].apn__c : null,
			Diff_House_Canary_APN__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.APN__c && prop.APN__c != prop.Property_AVMs__r[0].apn__c,
			House_Canary_Property_Type__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].property_type__c : null,
			Diff_House_Canary_Property_Type__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_Type__c && prop.Property_Type__c != prop.Property_AVMs__r[0].property_type__c,
			House_Canary_Calculated_Price__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_AVMs__r[0].AVM_Calculated_Price__c != null ? '$' + prop.Property_AVMs__r[0].AVM_Calculated_Price__c.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,').slice(0, -3) : null,
			Diff_House_Canary_Calculated_Price__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Calc_AveValue__c && prop.Calc_AveValue__c != prop.Property_AVMs__r[0].AVM_Calculated_Price__c,
			Diff_House_Canary_Estimated_Rent__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 &&  prop.Monthly_Rent__c && prop.Monthly_Rent__c != prop.Property_AVMs__r[0].Estimated_Rent__c,                
			House_Canary_Estimated_Rent__c: prop.Property_AVMs__r &&prop.Property_AVMs__r[0].Estimated_Rent__c != null && prop.Property_AVMs__r.length>0 ?'$' + prop.Property_AVMs__r[0].Estimated_Rent__c.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,').slice(0, -3): null,            
            Diff_House_Canary_no_of_stories__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 &&  prop.no_of_stories__c && prop.no_of_stories__c != prop.Property_AVMs__r[0].no_of_stories__c,
            House_Canary_no_of_stories__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ?prop.Property_AVMs__r[0].no_of_stories__c : null,
			House_Canary_REO__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_REO__c : null,
			Diff_House_Canary_REO__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.REO__c && prop.REO__c != prop.Property_AVMs__r[0].AVM_REO__c,
			House_Canary_Loan_Number__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Loan_Number__c : null,
			Diff_House_Canary_Loan_Number__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Loan_Number__c && prop.Loan_Number__c != prop.Property_AVMs__r[0].AVM_Loan_Number__c,
			House_Canary_Last_Sale_Price__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_AVMs__r[0].AVM_Last_Sale_Price__c != null ? '$' + prop.Property_AVMs__r[0].AVM_Last_Sale_Price__c.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,').slice(0, -3) : null,
			Diff_House_Canary_Last_Sale_Price__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Last_Sale_Price__c && prop.Last_Sale_Price__c != prop.Property_AVMs__r[0].AVM_Last_Sale_Price__c,
			House_Canary_Last_Sale_Date__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Last_Sale_Date__c : null,
			Diff_House_Canary_Last_Sale_Date__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Last_Sale_Date__c && prop.Last_Sale_Date__c != prop.Property_AVMs__r[0].AVM_Last_Sale_Date__c,
			House_Canary_Tax_Year: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0?prop.Property_AVMs__r[0].Tax_History_Tax_Year__c : null,
			House_Canary_Tax_Amt: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0?prop.Property_AVMs__r[0].Tax_History_Tax_Amount__c : null,
            House_Canary_Mortgage_Lien: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_AVMs__r[0].Mortgage_Lien_Data_Present__c  ? 'Yes' : 'No',
            House_Canary_Sale_History: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_AVMs__r[0].Sale_History_Data_Present__c  ? 'Yes' : 'No',                
           // House_Canary_Block_Crime: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_AVMs__r[0].Block_Crime_Data_Present__c  ? 'Yes' : 'No',                
            House_Canary_Tax_History: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_AVMs__r[0].Tax_History_Data_Present__c  ? 'Yes' : 'No',                                
       		House_Canary_Mortgage_Lien_Rpt:'/lightning/r/Report/00O8K000000VEyeUAG/view?fv0=' + prop.Id,
       		House_Canary_Sale_History_Rpt:'/lightning/r/Report/00O8K000000VEyZUAW/view?fv0=' + prop.Id,
       		//House_Canary_Block_Crime_Rpt:'/lightning/r/Report/00O76000000VQlDEAW/view?fv0=' + prop.Id,
       		House_Canary_Tax_History_Rpt:'/lightning/r/Report/00O8K000000VEyaUAG/view?fv0=' + prop.Id,                
			//House_Canary_Is_HOA__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Is_HOA__c : null,
			//Diff_House_Canary_Is_HOA__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0  && prop.Is_HOA__c && prop.Is_HOA__c != prop.Property_AVMs__r[0].AVM_Is_HOA__c,
		}));
		component.set("v.selectedRowsCount", 0);
		return tableData;
	},

	showSpinner: function(component) {
		$A.util.removeClass(component.find('spinner'), 'slds-hide');
	},

	hideSpinner: function( component ) {
		$A.util.addClass(component.find('spinner'), 'slds-hide');
	},

	mapRowsToProperties: function(component) {
		let tableData = component.get('v.tableData');
		let properties = component.get('v.properties');

		let selectedRows = [];
		for (let i = 0; i < tableData.length; i++) {
			if (tableData[i].Selected) {
				selectedRows.push(properties[i]);
			}
		}
		return selectedRows;
	},

	showToast: function(type, message) {
		let toast = $A.get('e.force:showToast');
		toast.setParams({
			'mode': type == 'error' ? 'sticky' : null,
			'title': type.replace(/^\w/, c => c.toUpperCase()),
			'message': message,
			'type': type
		});
		toast.fire();
	},

	selectAll: function(component) {
		let tableData = component.get("v.tableData");
		let selectedRowsCount = 0;
		for (let td of tableData) 
        {
			td.Selected = true;
			selectedRowsCount++;
		}
		component.set("v.tableData", tableData);
		component.set("v.selectedRowsCount", selectedRowsCount);
	},

	deselectAll: function(component) {
		let tableData = component.get("v.tableData");
		for (let td of tableData) {
			td.Selected = false;
		}
		component.set("v.tableData", tableData);
		component.set("v.selectedRowsCount", 0);
	},

	oneAtATimeHouseCanaryRead: function(component, selectedProps) {
		let isError = false;
		let errorMsgs = [];
		this.showSpinner(component);
		return selectedProps.reduce((promise, prop, index) => {
			return promise.then($A.getCallback(() => {
				 return this.singleHouseCanaryRead(component, prop).then(
					 $A.getCallback((res) => {
						 console.log('done in promise');
						 component.set("v.properties", res.properties);
		 				 component.set("v.tableData", this.getTableData(component));
						 if (index == selectedProps.length - 1 && !isError) {
							 this.hideSpinner(component);
							 this.showToast('success', 'Property AVMs have been retrieved');
						 }
						 else if (index == selectedProps.length - 1 && isError) {
							 this.hideSpinner(component);
							 let errorMsg = 'An error occured on one or more properties.';
							 for (let msg of errorMsgs) {
								 errorMsg += '\n' + msg;
							 }
							 this.showToast('error', errorMsg);
						 }
					 }),
					 $A.getCallback((error) => {
						 console.log('error in promise');
						 isError = true;
						 errorMsgs.push(prop.Name + ': ' + error.message);
						 if (index == selectedProps.length - 1) {
							 this.hideSpinner(component);
							 let errorMsg = 'An error occured on one or more properties.';
							 for (let msg of errorMsgs) {
								 errorMsg += '\n' + msg;
							 }
							 this.showToast('error', errorMsg);
						 }
					 })
				 );
			}));
		}, Promise.resolve());
	},

	singleHouseCanaryRead: function(component, prop) {
		return new Promise((resolve, reject) => {
			let action = component.get('c.callHouseCanarySingle');
			action.setParams({
				property: prop,
				recordId: component.get("v.recordId"),
            	valueReport: component.get("v.valueReport"),
			});
			action.setCallback(this, (response) => {
				let state = response.getState();
				let res = response.getReturnValue();
				let error = response.getError();
				console.log('state: ', state);
				if (state == 'SUCCESS') {
					resolve(res);
				}
				else {
					let errorMsg = error[0].message;
					reject(new Error(errorMsg));
				}
			});
			$A.enqueueAction(action);
		});
	},

})
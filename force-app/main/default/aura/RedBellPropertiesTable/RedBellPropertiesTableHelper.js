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
						//{label: 'Active', fieldName: 'Active__c', type: 'text'},
						{label: 'Calc AVEValue'},
						{label: 'Property Type'},
						{label: 'Is HOA'},
						{label: 'Bed', fieldName: 'Number_of_Beds__c'},
						{label: 'Bath', fieldName: 'Number_of_Bath__c'},
						{label: 'Square Feet', fieldName: 'Square_Feet__c'},
						{label: 'Year Built', fieldName: 'Year_Built__c'},

						//{label: 'REO'},
						//{label: 'Loan Number'},
						// {label: 'Inspection Date'},

						{label: 'Last Sold Date'},
						{label: 'Last Sold Price'},
						{label: 'Comps'},
					 ];
	},

	getTableData: function(component) {
		let properties = component.get("v.properties");
		//let currentPage = component.get("v.currentPage");
		//let pageSize = component.get("v.pageSize");
		//let start = (currentPage - 1) * pageSize;
		//let end = (currentPage) * pageSize;
		//let relavantProperties = properties.slice(start, end);
		//let tableData = relavantProperties.map((prop) => ({
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
			Number_of_Beds__c: prop.Number_of_Beds__c,
			Number_of_Bath__c: prop.Number_of_Bath__c,
			Square_Feet__c: prop.Square_Feet__c,
			Year_Built__c: prop.Year_Built__c,
			APN__c: prop.APN__c,
			Is_HOA__c: prop.Is_HOA__c,
			Property_Type__c: prop.Property_Type__c,
			Borrower_Opinion_of_Current_Value__c: prop.Borrower_Opinion_of_Current_Value__c != null ? '$' + prop.Borrower_Opinion_of_Current_Value__c.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,').slice(0, -3) : null,
			Red_Bell_Address__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Address__c : null,
			Diff_Red_Bell_Address__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Name && prop.Name != prop.Property_AVMs__r[0].AVM_Address__c : null,
			Red_Bell_City__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_C1_City__c : null,
			Diff_Red_Bell_City__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.City__c && prop.City__c != prop.Property_AVMs__r[0].AVM_C1_City__c,
			Red_Bell_State__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ?  prop.Property_AVMs__r[0].AVM_State__c : null,
			Diff_Red_Bell_State__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.State__c && prop.State__c != prop.Property_AVMs__r[0].AVM_State__c,
			Red_Bell_Zip__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_ZIP__c : null,
			Diff_Red_Bell_Zip__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.ZipCode__c && prop.ZipCode__c != prop.Property_AVMs__r[0].AVM_ZIP__c,
			Red_Bell_Beds__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Beds__c : null,
			Diff_Red_Bell_Beds__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Number_of_Beds__c && prop.Number_of_Beds__c != prop.Property_AVMs__r[0].AVM_Beds__c,
			Red_Bell_Baths__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Baths__c : null,
			Diff_Red_Bell_Baths__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Number_of_Bath__c && prop.Number_of_Bath__c != prop.Property_AVMs__r[0].AVM_Baths__c,
			Red_Bell_Square_Feet__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_C1_Square_Feet__c : null,
			Diff_Red_Bell_Square_Feet__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Square_Feet__c && prop.Square_Feet__c != prop.Property_AVMs__r[0].AVM_C1_Square_Feet__c,
			Red_Bell_Year_Built__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_C1_Year_Built__c : null,
			Diff_Red_Bell_Year_Built__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Year_Built__c && prop.Year_Built__c != prop.Property_AVMs__r[0].AVM_C1_Year_Built__c,
			Red_Bell_APN__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_APN__c : null,
			Diff_Red_Bell_APN__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.APN__c && prop.APN__c != prop.Property_AVMs__r[0].AVM_APN__c,
			Red_Bell_Property_Type__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Property_Type__c : null,
			Diff_Red_Bell_Property_Type__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_Type__c && prop.Property_Type__c != prop.Property_AVMs__r[0].AVM_Property_Type__c,
			Red_Bell_Calculated_Price__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_AVMs__r[0].AVM_Calculated_Price__c != null ? '$' + prop.Property_AVMs__r[0].AVM_Calculated_Price__c.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,').slice(0, -3) : null,
			Diff_Red_Bell_Calculated_Price__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Borrower_Opinion_of_Current_Value__c && prop.Borrower_Opinion_of_Current_Value__c != prop.Property_AVMs__r[0].AVM_Calculated_Price__c,


			Red_Bell_APN__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_APN__c : null,
			Diff_Red_Bell_APN__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 &&  prop.APN__c && prop.APN__c != prop.Property_AVMs__r[0].AVM_APN__c,

			//these fields don't exist on property
			Red_Bell_REO__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_REO__c : null,
			Diff_Red_Bell_REO__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.REO__c && prop.REO__c != prop.Property_AVMs__r[0].AVM_REO__c,
			Red_Bell_Loan_Number__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Loan_Number__c : null,
			Diff_Red_Bell_Loan_Number__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Loan_Number__c && prop.Loan_Number__c != prop.Property_AVMs__r[0].AVM_Loan_Number__c,
			// Red_Bell_Last_Inspection_Date__c: prop.Red_Bell_Last_Inspection_Date__c,
			// Diff_Red_Bell_Last_Inspection_Date__c: prop.Last_Inspection_Date__c && prop.Last_Inspection_Date__c != prop.Red_Bell_Last_Inspection_Date__c,
			Red_Bell_Last_Sale_Price__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_AVMs__r[0].AVM_Last_Sale_Price__c != null ? '$' + prop.Property_AVMs__r[0].AVM_Last_Sale_Price__c.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,').slice(0, -3) : null,
			Diff_Red_Bell_Last_Sale_Price__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Last_Sale_Price__c && prop.Last_Sale_Price__c != prop.Property_AVMs__r[0].AVM_Last_Sale_Price__c,
			Red_Bell_Last_Sale_Date__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Last_Sale_Date__c : null,
			Diff_Red_Bell_Last_Sale_Date__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Last_Sale_Date__c && prop.Last_Sale_Date__c != prop.Property_AVMs__r[0].AVM_Last_Sale_Date__c,

			Red_Bell_Is_HOA__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Is_HOA__c : null,
			Diff_Red_Bell_Is_HOA__c: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0  && prop.Is_HOA__c && prop.Is_HOA__c != prop.Property_AVMs__r[0].AVM_Is_HOA__c,
            
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

		// return tableData.reduce((selectedRows, row) => {
		// 	if (row.Selected) {
		// 		selectedRows.push({
		// 			sobjectType: 'Property__c',
		// 			Id: row.Id,
		// 			Name: row.Name,
		// 			City__c: row.City__c,
		// 			State__c: row.State__c,
		// 			ZipCode__c: row.ZipCode__c,
		// 		});
		// 	}
		// 	return selectedRows;
		// }, []);
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
		for (let td of tableData) {
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



	oneAtATimeRedBellRead: function(component, selectedProps) {
		let isError = false;
		let errorMsgs = [];
		this.showSpinner(component);
		return selectedProps.reduce((promise, prop, index) => {
			return promise.then($A.getCallback(() => {
				 return this.singleRedBellRead(component, prop).then(
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

	singleRedBellRead: function(component, prop) {
		return new Promise((resolve, reject) => {
			let action = component.get('c.callRedBellSingle');
			action.setParams({
				property: prop,
				recordId: component.get("v.recordId"),
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
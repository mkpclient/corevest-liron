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
						{label: 'Property Type', fieldName: 'Property_Type__c', type: 'text'},
						{label: 'Bed', fieldName: 'Number_of_Beds__c', type: 'number'},
						{label: 'Bath', fieldName: 'Number_of_Bath__c', type: 'number'},
						{label: 'Square Feet', fieldName: 'Square_Feet__c', type: 'number'},
            			{label: 'Estimated Rent', fieldName:'Estimated_Rent__c', type: 'number'},
            			{label: 'Estimated Min Rent', fieldName:'Estimated_Min_Rent__c', type: 'number'},
            			{label: 'Estimated Max Rent', fieldName:'Estimated_Max_Rent__c', type: 'number'},
					 ];
	},

	getTableData: function(component) {
		let properties = component.get("v.properties");
		let tableData = properties.map((prop) => ({
			Selected: prop.selected,
			Id: prop.Id,
			Name: prop.Name,
			RelativeUrl: '/' + prop.Id,
			City__c: prop.City__c,
			State__c: prop.State__c,
			ZipCode__c: prop.ZipCode__c,
			Number_of_Beds__c: prop.Number_of_Beds__c,
			Number_of_Bath__c: prop.Number_of_Bath__c,
			Square_Feet__c: prop.Square_Feet__c,
			Property_Type__c: prop.Property_Type__c,
            Pool__c: prop.Pool__c, 
            Estimated_Rent__c 		: prop.Estimated_Rent__c != null ? '$' + prop.Estimated_Rent__c : null,
            Estimated_Min_Rent__c 	: prop.Estimated_Min_Rent__c != null ? '$' + prop.Estimated_Min_Rent__c : null,
            Estimated_Max_Rent__c 	: prop.Estimated_Max_Rent__c != null ? '$' + prop.Estimated_Max_Rent__c : null,
            Beekin_Address__c		: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? prop.Property_AVMs__r[0].AVM_Address__c : null,
            Retrieved_addr_diff 	: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 && prop.Property_AVMs__r[0].AVM_Address__c != (prop.Name + ',' + prop.City__c + ','+ prop.State__c + ' ' + prop.ZipCode__c) ? true:false,               
            Beekin_Estimated_Rent__c 		: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? '$' + prop.Property_AVMs__r[0].Estimated_Rent__c : null,
            Beekin_Estimated_Min_Rent__c 	: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? '$' + prop.Property_AVMs__r[0].Estimated_Min_Rent__c : null,
            Beekin_Estimated_Max_Rent__c 	: prop.Property_AVMs__r && prop.Property_AVMs__r.length>0 ? '$' + prop.Property_AVMs__r[0].Estimated_Max_Rent__c : null,
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

	oneAtATimeBeekinRead: function(component, selectedProps) {
		let isError = false;
		let errorMsgs = [];
		this.showSpinner(component);
		return selectedProps.reduce((promise, prop, index) => {
			return promise.then($A.getCallback(() => {
				 return this.singleBeekinRead(component, prop).then(
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

	singleBeekinRead: function(component, prop) {
		return new Promise((resolve, reject) => {
			let action = component.get('c.callBeekinSingle');
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
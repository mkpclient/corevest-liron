({
	onInit: function(component, event, helper) {
		helper.getProperties(component);
		component.set("v.columns", helper.getColumns());
	},

	refresh: function(component, event, helper) {
		helper.getProperties(component);
	},

	nextPage: function(component, event, helper) {
		let currentPage = component.get('v.currentPage');
		component.set("v.currentPage", currentPage + 1);
		component.set("v.tableData", helper.getTableData(component));
		component.set('v.selectedRowsCount', 0);
	},

	prevPage: function(component, event, helper) {
		let currentPage = component.get('v.currentPage');
		component.set("v.currentPage", currentPage - 1);
		component.set("v.tableData", helper.getTableData(component)); 
		component.set('v.selectedRowsCount', 0);
	},

	lastPage: function(component, event, helper) {
		let maxPage = component.get('v.maxPage');
		component.set("v.currentPage", maxPage);
		component.set("v.tableData", helper.getTableData(component));
		component.set('v.selectedRowsCount', 0);
	},

	firstPage: function(component, event, helper) {
		component.set("v.currentPage", 1);
		component.set("v.tableData", helper.getTableData(component));
		component.set('v.selectedRowsCount', 0);
	},

	openReport: function(component, event, helper) {
		let recordId = component.get('v.recordId');
		let reportUrl = '/lightning/r/Report/00O0a000005C8byEAC/view?fv0=' + recordId;
		window.open(reportUrl);
	},

	// updateSelectedRows: function(component, event, helper) {
	// 	var selectedRows = event.getParam('selectedRows');
	// 	console.log(selectedRows);
	// 	component.set('v.selectedRows', selectedRows);
	// 	component.set('v.selectedRowsCount', selectedRows.length);
	// },

	toggleSelectAll: function(component, event, helper) {
		let selectedRowsCount = component.get("v.selectedRowsCount");
		if (selectedRowsCount == 0) {
			console.log('select all');
			helper.selectAll(component);
		}
		else {
			console.log('deselect all');
			helper.deselectAll(component);
		}
	},

	updateSelectedRowsCount: function(component, event, helper) {
		let tableData = component.get("v.tableData");
		let selectedRowsCount = 0;
		for (let td of tableData) {
			if (td.Selected == true) {
				selectedRowsCount++;
			}
		}
		component.set("v.selectedRowsCount", selectedRowsCount);
	},

	getRedBellData: function(component, event, helper) {
		let selectedProps = helper.mapRowsToProperties(component);
		if (selectedProps.length == 0) {
			alert("No properties were selected");
			return;
		}
		helper.oneAtATimeRedBellRead(component, selectedProps);
		// let action = component.get('c.callRedBell');
		// action.setParams({
		// 	properties: helper.mapRowsToProperties(component),
		// 	recordId: component.get("v.recordId"),
		// });
		// action.setCallback(this, (response) => {
		// 	let state = response.getState();
		// 	let res = response.getReturnValue();
		// 	let error = response.getError();
		// 	console.log(state);
		// 	if (state == 'SUCCESS') {
		// 		component.set("v.properties", res.properties);
		// 		component.set("v.tableData", helper.getTableData(component));
		// 		helper.showToast('success', 'Properties successfully updated!');
		//
		// 	}
		// 	else {
		// 		helper.showToast('error', error[0].message);
		// 	}
		// 	helper.hideSpinner(component);
		// });
		// helper.showSpinner(component);
		// $A.enqueueAction(action);
	},

	openModal: function(component, event, helper) {
		let rowIndex = parseInt(event.currentTarget.dataset.rowIndex);
		console.log(rowIndex);
		let properties = component.get("v.properties");
		let currentPage = component.get("v.currentPage");
		let pageSize = component.get("v.pageSize");
		console.log(currentPage, pageSize, rowIndex, (currentPage - 1) * pageSize + rowIndex);
		let compProperty = properties[(currentPage - 1) * pageSize + rowIndex];
		console.log(compProperty);
		component.set("v.compProperty", compProperty);
	},
})
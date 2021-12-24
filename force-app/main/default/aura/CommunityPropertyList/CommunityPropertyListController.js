({
	doInit : function(component, event, helper) {
		//helper.queryRecords(component);

        console.log(event.getSource().get('v.name'));

        if(event.getSource().get('v.name') == 'onlyTerm'){
            component.set('v.showOnlyBridge', false);
        }else if(event.getSource().get('v.name') == 'onlyBridge'){
            component.set('v.showOnlyTerm', false);
        }

		helper.compileFields(component);

		var action = component.get('c.getUser');
		action.setStorable();
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				//console.log(JSON.parse( response.getReturnValue() ));
				component.set('v.user', JSON.parse( response.getReturnValue() ));
				//console.log('user')
				console.log(component.get('v.user'));

				var user = component.get('v.user');
				// if(user.userType == 'borrower'){
				// 	helper.queryBorrowerDeals(component);
				// }else{
				// 	helper.queryVendorDeals(component);
				// }

				helper.queryProperties(component);

			}else{
				console.log('error');
				console.log(response);
			}
		});
		$A.enqueueAction(action);
	},

	handleSortChangeEvent : function( component, event, helper ) {
		console.log('change sort');
        var tableCmp = component.find( 'dataTable' );
        component.set('v.pageNumber', 1);
        component.set('v.sortColumnName', event.getParam('columnName'));
        component.set('v.sortDir', event.getParam('sortDirection'));

        tableCmp.set('v.sortColumnName', event.getParam('columnName'));
        tableCmp.set('v.sortDirection', event.getParam('sortDirection'));
        //helper.queryVendorDeals(component);

        var user = component.get('v.user');
		if(user.userType == 'borrower'){
			helper.queryBorrowerDeals(component);
		}else{
			helper.queryVendorDeals(component);
		}

    },

    nextPage : function(component, event, helper){

        var records = component.get('v.records');
        var currentPage = component.get('v.currentPage')+1;
        var pageSize = component.get('v.pageSize');

        var table = component.find('dataTable');

        var recordsToDisplay = records.slice((currentPage-1)*pageSize, currentPage*pageSize);

        table.set('v.rows', recordsToDisplay);

        component.set('v.currentPage', currentPage);

    },

    prevPage : function(component, event, helper){
        var records = component.get('v.records');
        var currentPage = component.get('v.currentPage')-1;
        var pageSize = component.get('v.pageSize');

        var table = component.find('dataTable');
        var recordsToDisplay = records.slice((currentPage-1)*pageSize, currentPage*pageSize);
        table.set('v.rows', recordsToDisplay);
        component.set('v.currentPage', currentPage);

    },

    lastPage : function(component, event, helper){
        var records = component.get('v.records');
        var currentPage = component.get('v.maxPage');
        var pageSize = component.get('v.pageSize');

        var table = component.find('dataTable');
        var recordsToDisplay = records.slice((currentPage-1)*pageSize, currentPage*pageSize);
        table.set('v.rows', recordsToDisplay);
        component.set('v.currentPage', currentPage);
    },

    firstPage : function(component, event, helper){
        var records = component.get('v.records');
        var currentPage = 1;
        var pageSize = component.get('v.pageSize');

        var table = component.find('dataTable');
        var recordsToDisplay = records.slice((currentPage-1)*pageSize, currentPage*pageSize);
        table.set('v.rows', recordsToDisplay);
        component.set('v.currentPage', currentPage);
    }
})
({
    init: function( component, event, helper ) {
    	var fields = [];
    	var columns = component.find('dataTable').get('v.columns');
    	for(var i = 0; i < columns.length; i++){
    		fields.push(columns[i].get('v.name'));
    	}

    	component.set('v.fieldList', fields);
    	//console.log(component.get('v.fieldList'));
        // //this.handlePageChangeEvent(component, event, helper);
        // helper.queryRecords(component);

        helper.queryRecordsList(component);
		helper.calTotal(component, event, helper); //@ Added by Trivikram
    },

    // handlePageChangeEvent : function( component, event, helper ) {

    //     var tableCmp = component.find( 'dataTable' );

    //     // console.log( 'handling page change event in app container' );
    //     // console.log( 'columnName=' + tableCmp.get( 'v.sortColumnName' ) );
    //     // console.log( 'sortDirection=' + tableCmp.get( 'v.sortDirection' ) );
    //     // console.log( 'page=' + event.getParam( 'pageNumber' ) );
    //     // console.log( 'pageSize=' + event.getParam( 'pageSize' ) );
    //     $A.util.removeClass(component.find('spinner'), 'slds-hide');
    //     if($A.util.isEmpty(component.get('v.fieldList'))){
    //     	helper.compileFields(component);
    //     }

    //     helper.callAction(
    //         component,
    //         'c.getRecords',
    //         {	
    //         	'parentId' : component.get('v.recordId'),
    //         	'parentFieldName' : component.get('v.parentFieldName'),
    //         	'sobjectType' : component.get('v.sobjectType'),
    //         	'fields' : component.get('v.fieldList'),
    //             'page' : event.getParam( 'pageNumber' ),
    //             'pageSize' : event.getParam( 'pageSize' ),
    //             'sortCol' : tableCmp.get( 'v.sortColumnName' ),
    //             'sortDir' : tableCmp.get( 'v.sortDirection' ),
    //             'whereClause' : '',
    //             'orderBy' : component.get('v.orderBy')
    //         },
    //         function( data ) {

    //             var tableCmp = component.find( 'dataTable' );

    //             var rows = tableCmp.get( 'v.rows' );

    //             tableCmp.set( 'v.rows', rows.concat( data ) );
    //             $A.util.addClass(component.find('spinner'), 'slds-hide');

    //         }
    //     );

    //     //helper.queryRecords(component);

    // },

    handleSortChangeEvent : function( component, event, helper ) {

        var tableCmp = component.find( 'dataTable' );

        //tableCmp.set( 'v.pageNumber', 1 );
        component.set('v.pageNumber', 1);
        console.log('sort');
        // console.log(component.find('dataTable').get('v.rows'), rows);
        // tableCmp.addSpinner();
        // if($A.util.isEmpty(component.get('v.fieldList'))){
        // 	helper.compileFields(component);
        // }

        // helper.callAction(
        //     component,
        //     'c.getRecords',
        //     {	
        //     	'parentId' : component.get('v.recordId'),
        //     	'parentFieldName' : component.get('v.parentFieldName'),
        //     	'sobjectType' : component.get('v.sobjectType'),
        //     	'fields' : component.get('v.fieldList'),
        //         'page' : tableCmp.get( 'v.pageNumber' ),
        //         'pageSize' : tableCmp.get( 'v.pageSize' ),
        //         'sortCol' : event.getParam( 'columnName' ),
        //         'sortDir' : event.getParam( 'sortDirection' ),
        //         'whereClause' : ''
        //     },
        //     function( data ) {

        //         var tableCmp = component.find( 'dataTable' );

        //          tableCmp.set( 'v.rows', data );
        //         //tableCmp.set('v.rows', []);
        //         tableCmp.removeSpinner();
        //     }
        // );
        tableCmp.set('v.sortColumnName', event.getParam('columnName'));
        tableCmp.set('v.sortDir', event.getParam('sortDirection'));
        helper.queryRecords(component);

    },

    createAdvance : function(component, event, helper){
    	var table = component.find('dataTable');

    	console.log('create advance');
    },

    makeActive : function(component, event, helper){
    	var table = component.find('dataTable');

        table.toggleSpinner();

    	var rowsChecked = [];
    	table.getChecked(function(resp){
    		rowsChecked = resp;
    	});

    	var rows = table.get('v.rows');
    	for(var i = 0; i < rowsChecked.length; i++ ){
    		rows[rowsChecked[i]].Active__c = true;
    	}

    	helper.callAction(
    		component,
    		'c.upsertRecords',
    		{
    			'records': rows
    		},

    		function( data ) {
    			//table.set('v.rows', data);
                table.toggleSpinner();
                helper.queryRecordsList(component, helper);
                $A.get('e.force:refreshView').fire();
    		}

    	);
    },

    makeInactive : function(component, event, helper){
    	var table = component.find('dataTable');
        table.toggleSpinner();
    	var rowsChecked = [];
    	table.getChecked(function(resp){
    		rowsChecked = resp;
    	});

    	var rows = table.get('v.rows');
    	for(var i = 0; i < rowsChecked.length; i++ ){
    		rows[rowsChecked[i]].Active__c = false;
    	}

        console.log(rows);

    	helper.callAction(
    		component,
    		'c.upsertRecords',
    		{
    			'records': rows
    		},

    		function( data ) {
                helper.queryRecordsList(component, helper);
                table.toggleSpinner();
                $A.get('e.force:refreshView').fire();
    		}

    	);

    },

    refresh : function(component, event, helper){
        helper.queryRecordsList(component);
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
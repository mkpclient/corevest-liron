({
    doInit : function( component, event, helper ) {

        // since these components are set via attribute and
        // not known at compile time then <aura:handler> is not
        // correctly registering our event listener as anticipated.
        //
        // therefore, we dynamically add our event listener to all
        // added columns upon initialization.
        // https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/js_cb_dynamic_handler.htm

        var columns = component.get( 'v.columns' );
        for ( var i = 0; i < columns.length; i++ ) {
            columns[i].addHandler( 'sortChangeEvent', component, 'c.handleSortChangeEvent' );
        }

        // default sort column if not specified yet
        if ( columns.length > 0 ) {

            var sortColumnName = component.get( 'v.sortColumnName' );
            var sortDirection = component.get( 'v.sortDirection' );

            if ( $A.util.isUndefinedOrNull( sortColumnName ) ) {
                sortColumnName = columns[0].get( 'v.name' );
            }

            if ( $A.util.isUndefinedOrNull( sortDirection ) ) {
                sortDirection = 'asc';
            }

            helper.syncColumnStates( component, sortColumnName, sortDirection );

        }

        // notify listeners to react and display initial page of data
        // this will send v.page and v.pageSize initial attribute values
        helper.firePageChangeEvent( component, component.get( 'v.pageNumber' ), component.get( 'v.pageSize' ) );

    },

    /**
     * Toggles the sort state of all the columns to reflect the
     * currently sorted column captured by the sort change event.
     */
    handleSortChangeEvent : function( component, event, helper ) {

        // column requested to sort data by
        var sortColumnName = event.getParam( 'columnName' );
        var sortDirection = event.getParam( 'sortDirection' );

        helper.syncColumnStates( component, sortColumnName, sortDirection );

    },

    getChecked : function( component, event, helper ){
        var params = event.getParam('arguments');
        var checkboxes = component.find('checkboxes');

        var rows = [];
		
        if(!$A.util.isUndefinedOrNull(checkboxes)){
            if(!Array.isArray(checkboxes)){
            	checkboxes = [checkboxes];
        	}

        	for(var i = 0; i < checkboxes.length; i++){
            	if(checkboxes[i].get('v.checked')){
             	   rows.push(checkboxes[i].get('v.value'));
            	}
        	}
        }
        
        

        console.log('--in table checked--');
        console.log(rows);

        params.callback(rows);
    },

    toggleEdit : function(component, event, helper){
        component.set('v.editMode', !component.get('v.editMode'));
    },

    saveRows : function(component, event, helper){
        var rows = component.get('v.rows');
        console.log(rows);
        helper.callAction(
            component,
            'c.upsertRecords',
            {
                'records': rows
            }),

        function( data ) {
            component.set('v.rows', rows);
        }
    },

    addRow : function(component, event, helper){
        var rows = component.get('v.rows');
        var params = event.getParam('arguments');
        console.log(params.row);
        rows.splice(rows.length, 0, params.row);
        component.set('v.rows', rows);
    },

    toggleSpinner : function(component, event, helper){
        $A.util.toggleClass(component.find('spinner'), 'slds-hide');
    },

    addSpinner : function(component, event, helper){
        $A.util.removeClass(component.find('spinner', 'slds-hide'));
    },

    removeSpinner : function(component, event, helper){
        $A.util.addClass(component.find('spinner', 'slds-hide'));
    },

    selectAll : function(component, event, helper){
        var checked = component.find('checkbox').get('v.checked');
        console.log('selectAll:::checked:::',checked);
        var checkboxes = component.find('checkboxes');
        console.log(checkboxes);
        if(!Array.isArray(checkboxes)){
            checkboxes = [checkboxes];
        }

        for(var i = 0; i < checkboxes.length; i++){
            checkboxes[i].set('v.checked', checked);
        }
    }
})
({
    /**
     * Notify that there's a request for specific page of data.
     *
     * It is the responsibility of the developer to listen for the
     * page change event and update the table's rows accordingly.
     */
    firePageChangeEvent : function( component, pageNumber, pageSize ) {

        component.getEvent( 'pageChangeEvent' ).setParams({
            'pageNumber' : pageNumber,
            'pageSize' : pageSize
        }).fire();

    },

    /**
     * Designed to be called by the renderer during infinite scrolling events.
     * Increments the page number then fires page change event.
     */
    getNextPage : function( component ) {

        var pageNumber = component.get( 'v.pageNumber' );
        var pageSize = component.get( 'v.pageSize' );

        pageNumber++;

        component.set( 'v.pageNumber', pageNumber );
        component.set( 'v.pageSize', pageSize );

        this.firePageChangeEvent( component, pageNumber, pageSize );

    },

    /**
     * Designed to be called whenever a sort change event is fired.
     * The component iterates through all the columns attribute and
     * updates their isSorted status so that the table column headers
     * reflect the UI of the user's sorting intent.
     *
     * It is the responsibility of the developer to also listen for the
     * sort change event and update the table's rows accordingly.
     */
    syncColumnStates : function( component, sortColumnName, sortDirection ) {

        // for all columns update their attributes
        // to indicate if it is the sorted column or not
        var columns = component.get( 'v.columns' );
        for ( var i = 0; i < columns.length; i++ ) {

            var column = columns[i];
            var columnName = column.get( 'v.name' );

            if ( sortColumnName === columnName ) {

                column.set( 'v.isSorted', true );
                column.set( 'v.sortDirection', sortDirection );

                component.set( 'v.sortColumnName', sortColumnName );
                component.set( 'v.sortDirection', sortDirection );

            } else {

                column.set( 'v.isSorted', false );

            }

        }

    },

    callAction : function( component, actionName, params, successCallback, failureCallback ) {

        //this.showSpinner( component );

        var action = component.get( actionName );

        if ( params ) {
            action.setParams( params );
        }

        action.setCallback( this, function( response ) {

            //this.hideSpinner( component );

            if ( component.isValid() && response.getState() === 'SUCCESS' ) {

                if ( successCallback ) {
                    successCallback( response.getReturnValue() );
                }

            } else {

                console.error( 'Error calling action "' + actionName + '" with state: ' + response.getState() );

                if ( failureCallback ) {
                    failureCallback( response.getError(), response.getState() );
                } else {
                    this.logActionErrors( component, response.getError() );
                }

            }
        });

        $A.enqueueAction( action );

    },

    logActionErrors : function( component, errors ) {
        if ( errors ) {
            for ( var index in errors ) {
                console.error( 'Error: ' + errors[index].message );
            }
        } else {
            console.error( 'Unknown error' );
        }
    },

})
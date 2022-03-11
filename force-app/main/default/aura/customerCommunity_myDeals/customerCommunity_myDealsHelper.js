({  

    compileFields : function( component ){
        var fields = [];
        var columns = component.find('dataTable').get('v.columns');
        for(var i = 0; i < columns.length; i++){
            fields.push(columns[i].get('v.name'));
        }
        component.set('v.fieldList', fields);
    },

    showSpinner : function( component ) {
        $A.util.removeClass( component.find( 'spinner' ), 'slds-hide' );
    },
    hideSpinner : function( component ) {
        $A.util.addClass( component.find( 'spinner' ), 'slds-hide' );
    },
    navigateToRecord : function( recordId ) {
    },
    /**
     * actionName = the apex controller method to call (e.g. 'c.myMethod' )
     * params = JSON object specifying action parameters (e.g. { 'x' : 42 } )
     * successCallback = function to call when action completes (e.g. function( response ) { ... } )
     * failureCallback = function to call when action fails (e.g. function( response ) { ... } )
    **/
	callAction : function( component, actionName, params, successCallback, failureCallback ) {
        this.showSpinner( component );
        var action = component.get( actionName );
        if ( params ) {
            action.setParams( params );
        }
        action.setCallback( this, function( response ) {
            this.hideSpinner( component );
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
    // queryRecords : function(component){
    //     console.log('queryRecords');
    //     var tableCmp = component.find('dataTable');

    //     //tableCmp.toggleSpinner();
    //     $A.util.removeClass(component.find('spinner'), 'slds-hide');
    //     this.callAction(
    //         component,
    //         'c.getRecordList',
    //         {   
    //             'parentId' : 'User.ContactId' ,
    //             'parentFieldName' : 'Contact__c',
    //             'sobjectType' : 'Opportunity',
    //             'fields' : ['Name','StageName','Loan_Size__c','Anticipated_Closing_Date__c'],
    //             'sortCol' : tableCmp.get( 'v.sortColumnName' ),
    //             'sortDir' : tableCmp.get( 'v.sortDirection' ),
    //             'whereClause' : component.get('v.whereClause'),
    //             'orderBy' : component.get('v.orderBy')
    //         },
    //         function( data ) {
    //             var records = data;
    //             component.set('v.records', data);
    //             console.log(records);
    //             var tableCmp = component.find('dataTable');
    //             var pageSize = component.get('v.pageSize');
    //             var currentPage = component.get('v.currentPage');
    //             component.set('v.maxPage', Math.ceil(records.length/pageSize));

    //             var recordsToDisplay = records.slice((currentPage-1)*pageSize, currentPage*pageSize);

    //             tableCmp.set('v.rows', recordsToDisplay);

    //             $A.util.addClass(component.find('spinner'), 'slds-hide');
    //             //tableCmp.toggleSpinner();



    //         }
    //     )
    // },

    queryDeals : function(component){
        var tableCmp = component.find('dataTable');
        this.callAction(
            component,
            'c.getDeals',
            {
                fields: component.get('v.fieldList'),
                'sortCol': tableCmp.get('v.sortColumnName'),
                'sortDir': tableCmp.get('v.sortDirection'),
                'whereClause': '',
                'showOnlyOpen': component.get('v.showOnlyOpen'),
                'showOnlyTerm': component.get('v.showOnlyTerm'),
                'showOnlyBridge': component.get('v.showOnlyBridge')

            },
            function (data) {
                //console.log(data);
                var records = JSON.parse(data);
                component.set('v.records', records);

                var tableCmp = component.find('dataTable');
                var pageSize = component.get('v.pageSize');
                var currentPage = component.get('v.currentPage');
                component.set('v.maxPage', Math.ceil(records.length / pageSize));

                var recordsToDisplay = records.slice((currentPage - 1) * pageSize, currentPage * pageSize);
                // @ Description Change stage names in portal for borrower view
                // @ return Closed or In Underwriting
                // @ Author Trivikram
                //renameStages(component,recordsToDisplay);
                var clonerecordsToDisplay = recordsToDisplay;
                var user = component.get('v.user');
                console.log('User: ' + user);
                if(user !=null && user.userType === 'borrower' && clonerecordsToDisplay.length>0){
                    var recordsSize =clonerecordsToDisplay.length;
                    var i=0
                    for(i=0;i<recordsSize;i++){
                        var records =clonerecordsToDisplay[i];
                        console.log(records);
                        if(records['StageName']==='Closed Won'){
                            records['StageName']='Closed';
                        } else if (records['StageName']==='Underwriting'){
                            records['StageName']='In Underwriting';
                        } else if (records['StageName']==='UW Hold'){
                            records['StageName']='In Underwriting';
                        }

                        //clonerecordsToDisplay[i]= records;
                    }
                }
                tableCmp.set('v.rows', recordsToDisplay);

            },
            function (errors, state) {
                console.log(errors);

            }
        );
    },

    queryVendorDeals : function(component){
        //console.log('query vendor deals');
        var tableCmp = component.find('dataTable');
        // $A.util.removeClass(component.find('spin'))
        //console.log(component.get('v.fieldList'));
        this.callAction(
            component,
            'c.getVendorDeals',
            {
                accountId: component.get('v.user').accountId,
                fields: component.get('v.fieldList'),
                'sortCol' : tableCmp.get( 'v.sortColumnName' ),
                'sortDir' : tableCmp.get( 'v.sortDirection' ),
                'whereClause' : '',
                'showOnlyOpen': component.get('v.showOnlyOpen'),
                'showOnlyTerm': component.get('v.showOnlyTerm'),
                'showOnlyBridge': component.get('v.showOnlyBridge')

            },
            function(data){
                //console.log(data);
                var records = JSON.parse(data);
                component.set('v.records', records);

                var tableCmp = component.find('dataTable');
                var pageSize = component.get('v.pageSize');
                var currentPage = component.get('v.currentPage');
                component.set('v.maxPage', Math.ceil(records.length/pageSize));

                var recordsToDisplay = records.slice((currentPage-1)*pageSize, currentPage*pageSize);

                tableCmp.set('v.rows', recordsToDisplay);
                
            },
            function(errors, state){
                console.log(errors);

            }
        );
    },

    queryBorrowerDeals : function(component){
        var tableCmp = component.find('dataTable');
        // $A.util.removeClass(component.find('spin'))
        //console.log(component.get('v.fieldList'));
        this.callAction(
            component,
            'c.getBorrowerDeals',
            {
                contactId: component.get('v.user').contactId,
                fields: component.get('v.fieldList'),
                'sortCol' : tableCmp.get( 'v.sortColumnName' ),
                'sortDir' : tableCmp.get( 'v.sortDirection' ),
                'whereClause' : '',
                'showOnlyOpen': component.get('v.showOnlyOpen'),
                'showOnlyTerm': component.get('v.showOnlyTerm'),
                'showOnlyBridge': component.get('v.showOnlyBridge')

            },
            function(data){
                //console.log(data);
                var records = JSON.parse(data);
                component.set('v.records', records);

                var tableCmp = component.find('dataTable');
                var pageSize = component.get('v.pageSize');
                var currentPage = component.get('v.currentPage');
                component.set('v.maxPage', Math.ceil(records.length/pageSize));

                var recordsToDisplay = records.slice((currentPage-1)*pageSize, currentPage*pageSize);
                
                this.renameStages(component,recordsToDisplay);
                // Added by Vikram
                //renameStages(component,recordsToDisplay);
                var clonerecordsToDisplay = recordsToDisplay;
                var user = component.get('v.user');
                console.log(user);
                if(user !=null && user.userType === 'borrower' && clonerecordsToDisplay.length>0){
                    var recordsSize =clonerecordsToDisplay.length;
                    var i=0
                    for(i=0;i<recordsSize;i++){
                        var records =clonerecordsToDisplay[i];
                        console.log(records);
                        if(records['StageName']==='Closed Won'){
                            records['StageName']='Closed';
                        } else if (records['StageName']==='In Underwriting'){
                            records['StageName']='Underwriting Hold';
                        } else if (records['StageName']==='Underwriting'){
                            records['StageName']='Underwriting Hold';
                        }                        	

                        //clonerecordsToDisplay[i]= records;
                    }
                }
                console.log(recordsToDisplay);
                tableCmp.set('v.rows', recordsToDisplay);
                
            },
            function(errors, state){
                console.log(errors);

            }
        );
    },
    /*renameStages: function(component,records){
        console.log(component);
        console.log(records);
    var clonerecordsToDisplay = records;
                var user = component.get('v.user');
                console.log(user);
                if(user !=null && user.userType === 'borrower' && clonerecordsToDisplay.length>0){
                    var recordsSize =clonerecordsToDisplay.length;
                    var i=0
                    for(i=0;i<recordsSize;i++){
                        var records =clonerecordsToDisplay[i];
                        console.log(records);
                        if(records['StageName']==='Closed Won'){
                            records['StageName']='Closed';
                        }else if(records['StageName']==='In Underwriting'){
                            records['StageName']='Underwriting Hold';
                        }
                            else if(records['StageName']==='Underwriting'){
                                records['StageName']='Underwriting Hold';
                            }                        	

                        //clonerecordsToDisplay[i]= records;
                    }
                }
    }*/


})
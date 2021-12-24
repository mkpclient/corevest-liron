({
  init: function (component, event, helper) {
    console.log("init");
    var fields = [];
    var columns = component.find("dataTable").get("v.columns");
    for (var i = 0; i < columns.length; i++) {
      //if(columns[i].get('v.name')!='possibleDuplicate'){
      fields.push(columns[i].get("v.name"));
      //}
    }

    component.set("v.fieldList", fields);
    //console.log(component.get('v.fieldList'));
    // //this.handlePageChangeEvent(component, event, helper);
    // helper.queryRecords(component);

    helper.queryRecordsList(component);

    helper.compilePermissions(component);
  },
  duplicateDatatape: function (component, event, helper) {
    var recordId = component.get("v.recordId");
    console.log("--record id--");
    console.log(recordId);
    var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
      componentDef: "c:DupeCheckDataTape",
      componentAttributes: {
        recordId: recordId,
        isRedirect: true
      }
    });

    evt.fire();

    /*$A.createComponent(
         "c:DupeCheckDataTape",
            {
                "recordId": component.get("v.recordId")
            },
         function(newCmp, status, errorMessage){
             if (status === "SUCCESS") {
                 component.set("v.dataTapeOpen", true);
                 var body = component.get("v.body");
                 
                 body.push(newCmp);
                 component.set("v.body", body);
                 
             }
             else if (status === "INCOMPLETE") {
                 console.log("No response from server or client is offline.");
             }
                 else if (status === "ERROR") {
                     console.log("Error: " + errorMessage);
                 }
         }
        );*/
  },

  handleSortChangeEvent: function (component, event, helper) {
    var tableCmp = component.find("dataTable");

    //tableCmp.set( 'v.pageNumber', 1 );
    tableCmp.set("v.pageNumber", 1);
    console.log("sort");
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
    tableCmp.set("v.sortColumnName", event.getParam("columnName"));
    tableCmp.set("v.sortDirection", event.getParam("sortDirection"));
    helper.queryRecords(component);
  },

  makeActive: function (component, event, helper) {
    var table = component.find("dataTable");

    //table.toggleSpinner();

    var rowsChecked = [];
    table.getChecked(function (resp) {
      rowsChecked = resp;
    });

    var rows = table.get("v.rows");
    for (var i = 0; i < rowsChecked.length; i++) {
      rows[rowsChecked[i]].Status__c = "Active";
    }

    helper.callAction(
      component,
      "c.upsertRecords",
      {
        records: rows
      },

      function (data) {
        //table.set('v.rows', data);
        //table.toggleSpinner();
        helper.queryRecordsList(component, helper);
        $A.get("e.force:refreshView").fire();
        //table.toggleSpinner();
      },
      function (error) {
        //console.log(error);
        var toast = $A.get("e.force:showToast");
        toast.setParams({
          title: "Error",
          message: error[0].message,
          mode: "sticky",
          type: "error"
        });
        toast.fire();
      }
    );
  },
  
	closeReasonModal: function (component, event, helper) {
		component.set("v.showReasonModal", false);
	},
	
	openReasonModal: function (component, event, helper) {
		component.set("v.showReasonModal", true);
	},
	
  makeInactive: function (component, event, helper) {
	
	var spinner = component.find("mySpinner");
	$A.util.removeClass(spinner, "slds-hide");
	  
    var table = component.find("dataTable");
    //table.toggleSpinner();
    var rowsChecked = [];
    table.getChecked(function (resp) {
      rowsChecked = resp;
    });
	
	var reasonForInactiveText = component.get("v.reasonForInativeValue");
	console.log('reasonForInactiveText::::',reasonForInactiveText);

    var rows = table.get("v.rows");
    for (var i = 0; i < rowsChecked.length; i++) {
      rows[rowsChecked[i]].Status__c = "Inactive";
      rows[rowsChecked[i]].Reason_For_Inactive__c = reasonForInactiveText;
    }

    console.log('rows:::',rows);

    helper.callAction(
      component,
      "c.upsertRecords",
      {
        records: rows
      },

      function (data) {
		var spinner = component.find("mySpinner");
		$A.util.addClass(spinner, "slds-hide");  
	
		component.set("v.showReasonModal", false);
		
        helper.queryRecordsList(component, helper);
        //table.toggleSpinner();
        $A.get("e.force:refreshView").fire();
      },
      function (error) {
        console.log(error);
        var toast = $A.get("e.force:showToast");
        toast.setParams({
          title: "Error",
          message: error[0].message,
          type: "error"
        });
        toast.fire();
      }
    );
  },

  refresh: function (component, event, helper) {
    helper.queryRecordsList(component);
  },

  nextPage: function (component, event, helper) {
    var records = component.get("v.records");
    var currentPage = component.get("v.currentPage") + 1;
    var pageSize = component.get("v.pageSize");

    var table = component.find("dataTable");

    var recordsToDisplay = records.slice(
      (currentPage - 1) * pageSize,
      currentPage * pageSize
    );

    table.set("v.rows", recordsToDisplay);

    component.set("v.currentPage", currentPage);
  },

  prevPage: function (component, event, helper) {
    var records = component.get("v.records");
    var currentPage = component.get("v.currentPage") - 1;
    var pageSize = component.get("v.pageSize");

    var table = component.find("dataTable");
    var recordsToDisplay = records.slice(
      (currentPage - 1) * pageSize,
      currentPage * pageSize
    );
    table.set("v.rows", recordsToDisplay);
    component.set("v.currentPage", currentPage);
  },

  lastPage: function (component, event, helper) {
    var records = component.get("v.records");
    var currentPage = component.get("v.maxPage");
    var pageSize = component.get("v.pageSize");

    var table = component.find("dataTable");
    var recordsToDisplay = records.slice(
      (currentPage - 1) * pageSize,
      currentPage * pageSize
    );
    table.set("v.rows", recordsToDisplay);
    component.set("v.currentPage", currentPage);
  },

  firstPage: function (component, event, helper) {
    var records = component.get("v.records");
    var currentPage = 1;
    var pageSize = component.get("v.pageSize");

    var table = component.find("dataTable");
    var recordsToDisplay = records.slice(
      (currentPage - 1) * pageSize,
      currentPage * pageSize
    );
    table.set("v.rows", recordsToDisplay);
    component.set("v.currentPage", currentPage);
  },
  
	openRefinanceModal: function (component, event, helper) {
        var table = component.find("dataTable");

        var rowsChecked = [];
        table.getChecked(function (resp) {
          rowsChecked = resp;
        });
        console.log('rowsChecked::::',rowsChecked);
        
        if(rowsChecked == '' || rowsChecked == null){
            component.set("v.isNoRowSelected", true);
            component.set("v.Message", "Please select 1 or more Properties before you assign a Refinance Deal.");
        }else{
            component.set("v.isNoRowSelected", false);
            component.set("v.Message", "");
        }
		component.set("v.showRefinanceModal", true);
	},
	
	closeRefinanceModal: function (component, event, helper) {
		component.set("v.showRefinanceModal", false);
	},
  
	onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = '';
         helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
             component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );   
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected record from the COMPONETN event 	 
       var selectedRecordGetFromEvent = event.getParam("recordByEvent");
	   component.set("v.selectedRecord" , selectedRecordGetFromEvent); 
       
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
      
	},
    
    onAssignRefinanceDealSave : function(component, event, helper) {
		var selectedRecordName = component.get("v.selectedRecord.Id");
        console.log('selectedRecordName::::',selectedRecordName);
        
        var spinner = component.find("refinanceModalSpinner");
		$A.util.removeClass(spinner, "slds-hide");
        
         var table = component.find("dataTable");

        //table.toggleSpinner();
    
        var rowsChecked = [];
        table.getChecked(function (resp) {
          rowsChecked = resp;
        });
    
        var rows = table.get("v.rows");
        for (var i = 0; i < rowsChecked.length; i++) {
          rows[rowsChecked[i]].Deal_Refinanced_With__c  = component.get("v.selectedRecord.Id");
        }
    	
        console.log('rows:::',rows);
        helper.callAction(
          component,
          "c.upsertRecords",
          {
            records: rows
          },
    
          function (data) {
            var spinner = component.find("refinanceModalSpinner");
			$A.util.addClass(spinner, "slds-hide");
            component.set("v.showRefinanceModal", false);
            //table.set('v.rows', data);
            //table.toggleSpinner();
            helper.queryRecordsList(component, helper);
            $A.get("e.force:refreshView").fire();
            
            //table.toggleSpinner();
          },
          function (error) {
            //console.log(error);
            var spinner = component.find("refinanceModalSpinner");
			$A.util.addClass(spinner, "slds-hide");
            var toast = $A.get("e.force:showToast");
            toast.setParams({
              title: "Error",
              message: error[0].message,
              mode: "sticky",
              type: "error"
            });
            toast.fire();
          }
        );
        
    }
    
});
({
	init: function (component, event, helper) {
		var action = component.get("c.getRecord");
		action.setParams({ i: component.get("v.recordId") });

		action.setCallback(this, function (response) {
		  var state = response.getState();

		  if (state == "SUCCESS") {
			console.log("success");
			//console.log(response.getReturnValue());
			component.set("v.record", JSON.parse(response.getReturnValue()));
			console.log(component.get("v.record"));
			var fields = [];
			var columns = component.find("dataTable").get("v.columns");
			for (var i = 0; i < columns.length; i++) {
			  fields.push(columns[i].get("v.name"));
			}

			component.set("v.fieldList", fields);

			helper.queryRecordsList(component);
		  } else if (state == "ERROR") {
			console.log("ERROR");
		  }
		});

		$A.enqueueAction(action);

		helper.compilePermissions(component);
		helper.compileAdvancePermissions(component);
		helper.compileExtensionPermissions(component);
	},

  
	openPropertyModal: function (component, event, helper) {
		component.set("v.showCreatePropertyModal", true);
		
		var action = component.get("c.getPicklistFieldValue");
		
		 action.setParams({
            "objectApiName" : 'Property__c',
			"fieldAPiName" : 'Property_Type__c'
        }); 
		
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
				var fieldMap = [];
				for(var key in result){
					fieldMap.push({key: key, value: result[key]});
				}
				component.set("v.PropertyTypeMap", fieldMap);
				
			}else if (state == "ERROR") {
				console.log("ERROR");
			}
		});
		$A.enqueueAction(action);
		
		var action1 = component.get("c.getPicklistFieldValue");
		
		 action1.setParams({
            "objectApiName" : 'Property__c',
			"fieldAPiName" : 'State__c'
        }); 
		
		action1.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
				var fieldMap1 = [];
				for(var key in result){
					fieldMap1.push({key: key, value: result[key]});
				}
				console.log('fieldMap1:::',fieldMap1);
				component.set("v.stateMap", fieldMap1);
				
			}else if (state == "ERROR") {
				console.log("ERROR");
			}
		});
		$A.enqueueAction(action1);
	},
	
	onSaveButtonClick: function (component, event, helper) {
		var createProperty = component.get("v.createProperty");
		var propertyRecordType = component.get("v.Property_Record_Type");
		console.log('::::createProperty'+createProperty.City__c);
		console.log('::::createProperty'+createProperty.Name);
		console.log('::::propertyRecordType'+propertyRecordType);
		
		component.set("v.Spinner", true);
	 	//helper.showSpinner(component);
		var action = component.get("c.createNewProperty"); 
		
		action.setParams({
            "propertyObj" : component.get('v.createProperty'),
			"propertyRecordType" : component.get("v.Property_Record_Type"),
			"dealRecordId" : component.get("v.recordId")
        });
		
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				//helper.hideSpinner(component);
				component.set("v.showCreatePropertyModal", false);
				component.set("v.Spinner", false);
				helper.actionCallInit(component, event, helper);
			}else if (state == "ERROR") {
				console.log("ERROR");
			}
		});
		$A.enqueueAction(action);
	},
	
	closeCreatePropertyModal: function (component, event, helper) {
		component.set("v.showCreatePropertyModal", false);
	},

	handleSortChangeEvent: function (component, event, helper) {
		var tableCmp = component.find("dataTable");
		tableCmp.set( 'v.pageNumber', 1 );
		// component.set("v.pageNumber", 1);
		tableCmp.set("v.sortColumnName", event.getParam("columnName"));
		tableCmp.set("v.sortDirection", event.getParam("sortDirection"));
		helper.queryRecords(component);
	},

	close: function (component, event, helper) {
		console.log("close");
		var modal = component.find("modal");
		var backdrop = component.find("modal-backdrop");
		$A.util.removeClass(modal, "slds-fade-in-open");
		$A.util.addClass(modal, "slds-modal__close");
		$A.util.removeClass(backdrop, "slds-backdrop--open");
	},

	continueAdvance: function (component, event, helper) {
		var table = component.find("dataTable");

		//console.log('create advance');
		//var table = component.find('dataTable');

		//table.toggleSpinner();
		var modal = component.find("modal");
		var backdrop = component.find("modal-backdrop");
		$A.util.removeClass(modal, "slds-fade-in-open");
		$A.util.addClass(modal, "slds-modal__close");
		$A.util.removeClass(backdrop, "slds-backdrop--open");

		var rowsChecked = [];
		table.getChecked(function (resp) {
		  rowsChecked = resp;
		});

		var rows = table.get("v.rows");
		var properties = [];

		var advanceAmountTotal = 0;
		for (var i = 0; i < rowsChecked.length; i++) {
		  if (
			rows[rowsChecked[i]].Status__c == "Closing" || 
			(rows[rowsChecked[i]].Status__c == "Active" && rows[rowsChecked[i]].Reno_Advance_Amount_Remaining__c > 0)
		  ) {
			properties.push(rows[rowsChecked[i]]);
			advanceAmountTotal += rows[rowsChecked[i]].Advance_Fee_formula__c;
		  }
		}
		//console.log(advanceAmountTotal);
		//console.log(properties);

		if (properties.length > 0) {
		  var deal = component.get("v.record");
		  var feeAmount = deal.Advance_Fee_Remaining__c / properties.length;
		  helper.createAdvance(component, properties, helper, feeAmount);
		} else {
		  var toast = $A.get("e.force:showToast");
		  toast.setParams({
			type: "warning",
			message: "No suitable properties selected"
		  });

		  toast.fire();
		}
	},

	createAdvance: function (component, event, helper) {
		var table = component.find("dataTable");

		var rowsChecked = [];
		table.getChecked(function (resp) {
		  rowsChecked = resp;
		});

		var rows = table.get("v.rows");
		var properties = [];

		var advanceAmountTotal = 0;

		var recordTypeSet = new Set();

		let invalidProperties = [];

		for (var i = 0; i < rowsChecked.length; i++) {
		  if (
			rows[rowsChecked[i]].Status__c == "Closing" || 
			(rows[rowsChecked[i]].Status__c == "Active" && rows[rowsChecked[i]].Reno_Advance_Amount_Remaining__c > 0)
		  ) {
			properties.push(rows[rowsChecked[i]]);
			recordTypeSet.add(rows[rowsChecked[i]].Renovation_Type_formula__c);
			advanceAmountTotal += rows[rowsChecked[i]].Advance_Fee_formula__c;
		  }

		  if (
			!$A.util.isEmpty(rows[rowsChecked[i]].Current_Asset_Maturity_Date__c)
		  ) {
			if (
			  new Date(rows[rowsChecked[i]].Current_Asset_Maturity_Date__c) <
			  new Date()
			) {
			  invalidProperties.push(rows[rowsChecked[i]]);
			}
		  }
		  console.log(rows[rowsChecked[i]].Current_Asset_Maturity_Date__c);
		}
		//console.log(advanceAmountTotal);
		console.log(properties);

		if (invalidProperties.length > 0) {
		  var toast = $A.get("e.force:showToast");
		  toast.setParams({
			type: "warning",
			message:
			  "The Asset Maturity Date has expired on at least one of your Assets selected."
		  });

		  toast.fire();
		} else if (recordTypeSet.length > 1) {
		  var toast = $A.get("e.force:showToast");
		  toast.setParams({
			type: "warning",
			message: "Can't mix renovation properties in an advance"
		  });

		  toast.fire();
		} else {
		  if (properties.length > 0) {
			var deal = component.get("v.record");
			//console.log(advanceAmountTotal)
			if (
			  deal.Max_Advance_Fee__c == "Yes" &&
			  advanceAmountTotal > deal.Advance_Fee_Remaining__c
			) {
			  //console.log('stop');
			  var modal = component.find("modal");
			  var backdrop = component.find("modal-backdrop");
			  $A.util.addClass(modal, "slds-fade-in-open");
			  $A.util.removeClass(modal, "slds-modal__close");
			  $A.util.addClass(backdrop, "slds-backdrop--open");
			} else {
			  helper.createAdvance(component, properties, helper);
			}
		  } else {
			var toast = $A.get("e.force:showToast");
			toast.setParams({
			  type: "warning",
			  message: "No suitable properties selected"
			});

			toast.fire();
		  }
		}
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

	createPropExtension: function (component, event, helper) {
		var table = component.find("dataTable");

		var rowsChecked = [];
		table.getChecked(function (resp) {
		  rowsChecked = resp;
		});

		const propertyIds = [];
		var rows = table.get("v.rows");
		for (var i = 0; i < rowsChecked.length; i++) {
		  propertyIds.push(`'${rows[rowsChecked[i]].Id}'`);
		}

		if (propertyIds.length > 0) {
		  component.find("propertyExtensionNew").init(propertyIds);
		}
	},

	openDocModal: function (component, event, helper) {
	var table = component.find("dataTable");

		var rowsChecked = [];
		table.getChecked(function (resp) {
		  rowsChecked = resp;
		});

		let propertyIds = "";
		var rows = table.get("v.rows");
		for (var i = 0; i < rowsChecked.length; i++) {
		  propertyIds += `'${rows[rowsChecked[i]].Id}',`;
		}

		if (!$A.util.isEmpty(propertyIds)) {
		  propertyIds = propertyIds.substr(0, propertyIds.lastIndexOf(","));
		  propertyIds = "(" + propertyIds + ")";
		}

		component.set("v.propertyIds", propertyIds);

		component.find("advanceDocGen").set("v.isTrue", true);
	},

	closeModal: function (component, event, helper) {
		component.find("advanceDocGen").set("v.isTrue", false);
	},

	saveRows: function (component, event, helper) {
		helper.saveRecords(component, helper);
	},

	toggleEdit: function (component, event, helper) {
		component.set("v.editMode", !component.get("v.editMode"));
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
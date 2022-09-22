({
  compileFields: function (component) {
    var fields = [];
    var columns = component.find("dataTable").get("v.columns");
    for (var i = 0; i < columns.length; i++) {
      fields.push(columns[i].get("v.name"));
    }

    component.set("v.fieldList", fields);
  },

  showSpinner: function (component) {
    $A.util.removeClass(component.find("spinner"), "slds-hide");
  },

  hideSpinner: function (component) {
    $A.util.addClass(component.find("spinner"), "slds-hide");
  },

  navigateToRecord: function (recordId) {
    console.log("navigating to record: " + recordId);

    var event = $A.get("e.force:navigateToSObject");

    if (event) {
      event
        .setParams({
          recordId: recordId
        })
        .fire();
    } else if (
      typeof sforce !== "undefined" &&
      typeof sforce.one !== "undefined"
    ) {
      sforce.one.navigateToSObject(recordId);
    } else {
      window.location.href = "/" + recordId;
    }
  },

  /**
   * actionName = the apex controller method to call (e.g. 'c.myMethod' )
   * params = JSON object specifying action parameters (e.g. { 'x' : 42 } )
   * successCallback = function to call when action completes (e.g. function( response ) { ... } )
   * failureCallback = function to call when action fails (e.g. function( response ) { ... } )
   */
  callAction: function (
    component,
    actionName,
    params,
    successCallback,
    failureCallback
  ) {
    this.showSpinner(component);
    var action = component.get(actionName);

    if (params) {
      action.setParams(params);
    }

    action.setCallback(this, function (response) {
      this.hideSpinner(component);

      if (component.isValid() && response.getState() === "SUCCESS") {
        if (successCallback) {
          successCallback(response.getReturnValue());
        }
      } else {
        console.error(
          'Error calling action "' +
            actionName +
            '" with state: ' +
            response.getState()
        );

        if (failureCallback) {
          failureCallback(response.getError(), response.getState());
        } else {
          this.logActionErrors(component, response.getError());
        }
      }
    });

    $A.enqueueAction(action);
  },

  logActionErrors: function (component, errors) {
    if (errors) {
      for (var index in errors) {
        console.error("Error: " + errors[index].message);
      }
    } else {
      console.error("Unknown error");
    }
  },
  queryRecords: function (component) {
    var tableCmp = component.find("dataTable");
    // tableCmp.toggleSpinner();
    $A.util.removeClass(component.find("spinner"), "slds-hide");
    this.callAction(
      component,
      "c.getRecords",
      {
        parentId: component.get("v.recordId"),
        parentFieldName: component.get("v.parentFieldName"),
        sobjectType: component.get("v.sobjectType"),
        fields: component.get("v.fieldList"),
        page: 1,
        pageSize: tableCmp.get("v.pageNumber") * tableCmp.get("v.pageSize"),
        sortCol: tableCmp.get("v.sortColumnName"),
        sortDir: tableCmp.get("v.sortDirection"),
        whereClause: component.get("v.whereClause"),
        orderBy: component.get("v.orderBy")
      },
      function (data) {
        var tableCmp = component.find("dataTable");

        tableCmp.set("v.rows", data);
        $A.util.addClass(component.find("spinner"), "slds-hide");

        // tableCmp.toggleSpinner();
      }
    );
  },

  queryRecordsList: function (component) {
    var tableCmp = component.find("dataTable");

    // tableCmp.toggleSpinner();
    $A.util.removeClass(component.find("spinner"), "slds-hide");
    this.callAction(
      component,
      "c.getRecordList",
      {
        parentId: component.get("v.recordId"),
        parentFieldName: component.get("v.parentFieldName"),
        sobjectType: component.get("v.sobjectType"),
        fields: component.get("v.fieldList"),
        sortCol: tableCmp.get("v.sortColumnName"),
        sortDir: tableCmp.get("v.sortDirection"),
        whereClause: component.get("v.whereClause"),
        orderBy: component.get("v.orderBy")
      },
      function (data) {
        //var records = JSON.parse(data);
        var records = data;
        component.set("v.records", data);
        //console.log(records);
        var tableCmp = component.find("dataTable");

        var pageSize = component.get("v.pageSize");
        var currentPage = component.get("v.currentPage");

        component.set("v.maxPage", Math.ceil(records.length / pageSize));

        var recordsToDisplay = records.slice(
          (currentPage - 1) * pageSize,
          currentPage * pageSize
        );

        tableCmp.set("v.rows", recordsToDisplay);

        $A.util.addClass(component.find("spinner"), "slds-hide");
      }
    );
  },

  saveRecords: function (component, helper) {
    var table = component.find("dataTable");

    var rows = table.get("v.rows");
    table.toggleSpinner();
    helper.callAction(
      component,
      "c.upsertRecords",
      {
        records: rows
      },

      function (data) {
        table.toggleSpinner();
        component.set("v.editMode", !component.get("v.editMode"));
        helper.queryRecords(component);
      }
    );
  },

  deleteRecords: function (component, helper, records) {
    var tableCmp = component.find("dataTable");

    tableCmp.toggleSpinner();
    helper.callAction(
      component,
      "c.deleteRecords",
      {
        records: records
      },
      function (data) {
        tableCmp.toggleSpinner();
        helper.queryRecords(component);
      }
    );
  },

  compilePermissions: function (component, helper, records) {
    let fields = [
      "Name",
      "Loan_Status__c",
      "Original_UPB__c",
      "Current_UPB__c",
      "First_Payment_Date__c",
      "Last_Payment_Date__c",
      "Next_Payment_Date__c",
      "Current_Interest_Rate__c",
      "Property_Type__c",
      "City__c",
      "State__c",
      "Active__c",
      "Possible_Duplicate__c",
      "Active_Last_Changed__c"
    ];

    component.find("util").getPermissions("Property__c", fields, (response) => {
      console.log("--permissions--");

      console.log(response);

      component.set("v.permissionsMap", response);
    });
  },
  
	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
		var action = component.get("c.fetchLookUpValues");
	  // set param to method  
		action.setParams({
			'searchKeyWord': getInputkeyWord,
			'ObjectName' : 'opportunity'
		  });
	  // set a callBack    
		action.setCallback(this, function(response) {
		  $A.util.removeClass(component.find("mySpinner"), "slds-show");
			var state = response.getState();
			if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
			  // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
				if (storeResponse.length == 0) {
					component.set("v.Message", 'No Result Found...');
				} else {
					component.set("v.Message", '');
				}
				// set searchResult list with return value from server.
				component.set("v.listOfSearchRecords", storeResponse);
			}

		});
	  // enqueue the Action  
		$A.enqueueAction(action);

	},
});
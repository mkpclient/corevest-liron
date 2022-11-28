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
      },

      function (error) {
        table.toggleSpinner();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "error",
          title: "Unable to save properties",
          mode: 'sticky',
          message: error[0].message
        });
        toastEvent.fire();
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

  createAdvance: function (component, properties, helper, feeAmount) {
    console.log(properties);
    /**
     * actionName = the apex controller method to call (e.g. 'c.myMethod' )
     * params = JSON object specifying action parameters (e.g. { 'x' : 42 } )
     * successCallback = function to call when action completes (e.g. function( response ) { ... } )
     * failureCallback = function to call when action fails (e.g. function( response ) { ... } )
     */
    // var renoType = properties[0].Renovation_Type_formula__c;

    // if (renoType == "No Renovation") {
    //   renoType = "Non-Renovation";
    //   /**   else if(renoType == 'Ground Up Construction') {
    //             renoType == 'Ground Up Construction';
    //         }*/
    // } else {
    //   renoType = "Renovation";
    // }

    var advance = {
      sobjectType: "Advance__c",
      Deal__c: component.get("v.recordId"),
      // Status__c: "Pending",
      // Property_Record_Type__c: renoType
    };

    this.callAction(
      component,
      "c.upsertRecords",
      {
        records: [advance]
      },
      function (response) {
        helper.createPropertyAdvances(
          component,
          response[0]["Id"],
          properties,
          feeAmount
        );
      }
    );
    //var component.get('v.upsertRecords')
  },

  createPropertyAdvances: function (
    component,
    advanceId,
    properties,
    feeAmount
  ) {
    console.log(advanceId);
    var propertyAdvances = [];
    for (var i = 0; i < properties.length; i++) {
      propertyAdvances.push({
        sobjectType: "Property_Advance__c",
        Advance__c: advanceId,
        Property__c: properties[i]["Id"],
        Advance_Fee__c: feeAmount
      });
      properties[i].Advance__c = advanceId;
    }

    this.callAction(
      component,
      "c.upsertRecords",
      { records: propertyAdvances },
      function (response) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          recordId: advanceId
        });
        navEvt.fire();
      }
    );
  },

  compilePermissions: function (component) {
    let fields = ["Name", "Requested_Funding_Date__c", "Status__c", "Rehab_Budget__c", "Acquisition_Price__c",
      "After_Repair_Value__c", "Appraised_Value_Amount__c", "Reno_Advance_Amount__c", "Remedy_Plan__c", "Title_Company__c", "Title_Company_Contact__c", "Escrow_Agent__c", "Escrow_Company_Contact__c", "Insurance_Company__c", "Insurance_Contact__c"];

    component.find("util").getPermissions("Property__c", fields, (response) => {
      console.log(response);

      component.set("v.permissionsMap", response);
    });
  },
  compileAdvancePermissions: function (component) {
    let fields = ["Name"];

    component.find("util").getPermissions("Advance__c", fields, (response) => {
      console.log(response);

      component.set("v.advancePermissionsMap", response);
    });
  },
  compileExtensionPermissions: function (component) {
    let fields = ["Name"];

    component.find("util").getPermissions("Property_Extension__c", fields, (response) => {
      console.log(response);

      component.set("v.extensionPermissionsMap", response);
    });
  },
  
	actionCallInit: function (component, event, helper) {
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

	}

});
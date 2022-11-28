({
  callActionSync: function(
    component,
    actionName,
    params,
    successCallback,
    failureCallback
  ) {
    var action = component.get(actionName);

    if (params) {
      action.setParams(params);
    }

    action.setCallback(this, function(response) {
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

  logActionErrors: function(component, errors) {
    if (errors) {
      for (var index in errors) {
        console.error("Error: " + errors[index].message);
      }
    } else {
      console.error("Unknown error");
    }
  },

  callAction: function(action, component) {
    return new Promise(function(resolve, reject) {
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {
          resolve(response.getReturnValue());
        } else if (component.isValid() && state === "ERROR") {
          reject(new Error(response.getError()));
        }
      });
      $A.enqueueAction(action);
    });
  },

  queryAdvance: function(component) {
    var action = component.get("c.getRecordList");
    var fieldList = [
      "Id",
      "Deal__c",
      "Status__c",
      "Deal__r.Id",
      "Deal__r.Advance_Fee_Remaining__c",
      "Deal__r.Max_Advance_Fee__c",
      "Advance_Fee_Total__c",
      "(SELECT Id, Property__c FROM Property_Advances__r)"
    ];

    var whereClause = "Id = '" + component.get("v.recordId") + "'";

    action.setParams({
      sobjectType: "Advance__c",
      whereClause: whereClause,
      fields: fieldList
    });

    return action;
    //console.log(this);
    // this.callAction(action, component).then($A.getCallback(function(data){
    // 	var advance = data[0];
    // 	console.log(advance);

    // 	component.set('v.advance');
    // 	component.set('v.deal', advance.Deal__r);

    // 	var propertyAdvances = advance.Property_Advances__r || [];

    // 	var propertyIds = '(';
    // 	propertyAdvances.forEach(function(p){
    // 		propertyIds += p.Property__c + ', ';
    // 	});

    // 	propertyIds = propertyIds.substr(0, propertyIds.lastIndexOf(',') == -1 ? propertyIds.length : propertyIds.lastIndexOf(','));
    // 	propertyIds += ')';

    // 	component.set('v.propertyIds', propertyIds);

    // 	return new Promise( function(resolve) {resolve()} );
    // }));
  },

  queryProperties: function(component) {
    var action = component.get("c.getRecordList");
    var fieldList = [
      "Id",
      "Deal__c",
      "Status__c",
      "Name",
      "City__c",
      "State__c",
      "Approved_Advance_Amount__c",
      "Asset_Maturity_Date__c",
      "Advance_Fee_formula__c"
    ];
    var whereClause = "Deal__c = '" + component.get("v.deal").Id + "'";
    whereClause += " AND (Status__c = 'Due Diligence' OR Status__c = 'Pending' OR Status__c = 'Closing' OR (Status__c = 'Active' AND Approved_Advance_Amount_Remaining__c > 0))";

    whereClause +=
      " AND (Updated_Asset_Maturity_Date__c = null OR Updated_Asset_Maturity_Date__c >= TODAY )";

    if (component.get("v.propertyIds") !== "()") {
      whereClause += " AND Id NOT IN " + component.get("v.propertyIds");
      whereClause += " ORDER BY Name";
    }

    console.log(whereClause);

    action.setParams({
      sobjectType: "Property__c",
      whereClause: whereClause,
      fields: fieldList
    });

    return action;
  },

  createPropAdvance: function(component, properties, feeAmount) {
    var propertyAdvances = [];
    var advanceId = component.get("v.advance").Id;
    for (var i = 0; i < properties.length; i++) {
      propertyAdvances.push({
        sobjectType: "Property_Advance__c",
        Advance__c: advanceId,
        Property__c: properties[i],
        Advance_Fee__c: feeAmount
      });
    }

    console.log(propertyAdvances);
    this.callActionSync(
      component,
      "c.upsertRecords",
      { records: propertyAdvances },
      function(response) {
        component.find('addBtn').set('v.disabled', false);
		  $A.util.addClass(component.find('spinner'), 'slds-hide');
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
      }
    );
  }
});
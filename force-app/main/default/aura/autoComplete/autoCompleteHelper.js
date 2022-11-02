({
  setRecord: function (component, lookupId) {
    var action = component.get("c.getRecord");

    action.setParams({ i: lookupId });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        console.log(JSON.parse(response.getReturnValue()));
        console.log(JSON.parse(JSON.stringify(component.get("v.record"))));
        var record = JSON.parse(response.getReturnValue());
        component.set("v.searchTerm", record["Name"]);
        //component.set('v.record', JSON.parse(response.getReturnValue());
      } else if (state === "ERROR") {
        console.log("error setting record");
      }

      component.set("v.isLoading", false);
    });

    $A.enqueueAction(action);
  },

  valueChangeEvent: function (component, helper) {
    if (
      component.get("v.fieldName") != null ||
      component.get("v.fieldName").length > 0
    ) {
      const cmpEvent = component.getEvent("valueChangeEvent");
      cmpEvent.setParams({
        row: component.get("v.row"),
        rowIdx: component.get("v.rowIdx"),
        fieldName: component.get("v.fieldName")
      });
      cmpEvent.fire();
    }
  },

  loadDependents: function (component, helper) {
    let whereClause = component.get("v.whereClause");
    const record = component.get("v.record");
    let relatedRecordId;

    if (whereClause.includes("{")) {
      let whereField = whereClause.substring(
        whereClause.indexOf("{") + 1,
        whereClause.lastIndexOf("}")
      );
      if (!!record && record.hasOwnProperty(whereField) && record[whereField]) {
        relatedRecordId = record[whereField];
        component.set("v.relatedRecordId", relatedRecordId);
        whereClause = whereClause
          .replace(whereField, record[whereField])
          .replace("{", "'")
          .replace("}", "'");
        component.set("v.dependentMessage", null);
      } else {
        return;
      }

      const action = component.get("c.getRecordList");
      action.setParams({
        parentId: null,
        parentFieldName: null,
        sobjectType: component.get("v.sObjectName"),
        fields: ["Id", "Name"],
        sortCol: "Name",
        sortDir: "ASC",
        whereClause: whereClause,
        orderBy: null
      });
      action.setCallback(this, function (response) {
        if (response.getState() === "SUCCESS") {
          var res = response.getReturnValue();

          component.set("v.results", res);
          console.log(component.get("v.results"));
        } else if (response.getState() === "ERROR") {
          console.log("error in autocomplete");
          console.error(response.getError());
        }
      });
      $A.enqueueAction(action);
    } else {
      return;
    }
  },

  retrieveRecordTypeId: function (component, helper) {
    const action = component.get("c.getRecordTypeId");

    action.setParams({
        "sobjectName": component.get("v.sObjectName"),
        "recordTypeDeveloperName": component.get("v.recordTypeName"),
    });

    action.setCallback(this, function(response) {
        if ( response.getState() === "SUCCESS" ){
           
            component.set("v.recordTypeId", response.getReturnValue());
            console.log(response.getReturnValue());
        }
        else if( response.getState() === "ERROR"){
            console.log('error in autocomplete');
            console.error(response.getError());
        }
    });
    $A.enqueueAction(action);
  }
});
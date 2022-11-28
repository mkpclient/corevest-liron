({
  init: function (component, event, helper) {
    //console.log(event.getParam('oldValue'));
    //console.log(event.getParam('value'));
    component.set("v.isLoading", true);

    if (!$A.util.isEmpty(component.get("v.value"))) {
      helper.setRecord(component, component.get("v.value"));
    } else {
        component.set("v.isLoading", false);
    }
  },

  handleInputClick: function (component, event, helper) {
    
    const searchTerm = component.get("v.searchTerm");
    console.log("entering input click " + searchTerm);

    if (
      component.get("v.recordTypeName") != null &&
      component.get("v.recordTypeId") == null
    ) {
      helper.retrieveRecordTypeId(component, helper);
    }

    if (searchTerm && searchTerm.length > 1) {
      return;
    } else {
      helper.loadDependents(component, helper);
    }
  },
  searchRecordsMethod: function (component, event, helper) {
    console.log(component.get("v.record"));
    var searchTerm = component.get("v.searchTerm");
    var whereClause = component.get("v.whereClause");
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
        whereClause = whereClause
          .replace(whereField, "")
          .replace("{", "'")
          .replace("}", "'");
        if (whereField === "Escrow_Agent__c") {
          whereField = "Escrow Company";
        }
        component.set(
          "v.dependentMessage",
          "Please select " +
            whereField.replace("__c", "").replaceAll("_", " ") +
            " first."
        );
      }
    }

    let whereClauseSegments = [];

    if (whereClause) {
      whereClauseSegments.push(whereClause);
    }

    if (component.get("v.recordTypeId") != null) {
      whereClauseSegments.push(
        "RecordTypeId='" + component.get("v.recordTypeId") + "'"
      );
    }

    if (component.get("v.isStrictSearch")) {
      whereClauseSegments.push("Name LIKE '%" + searchTerm + "%'");
    }

    if (whereClauseSegments.length > 0) {
      whereClause = whereClauseSegments.join(" AND ");
    }

    console.log("where clause", whereClause);
    console.log(component.get("v.sObjectName"));
    console.log(searchTerm);
    if (searchTerm && searchTerm.length > 1) {
      var sObjectName = component.get("v.sObjectName");
      component.set("v.objectLabel", sObjectName.replace("__c", ""));
      // var whereClause = component.get("v.whereClause");
      var lim = component.get("v.limit");
      //var returnFields = component.get('v.returnFields');
      var action = component.get("c.searchRecords");

      action.setParams({
        searchTerm: searchTerm,
        sObjectName: sObjectName,
        whereClause: whereClause,
        lim: lim
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
      component.set("v.results", null);
    }
  },

  select: function (component, event, helper) {
    var lookupId = event.target.getAttribute("data-recordid");
    var recordName = event.target.getAttribute("data-record");

    component.set("v.results", null);
    component.set("v.searchTerm", recordName);
    component.set("v.value", lookupId);
    component.set("v.isFocused", false);
    //helper.setRecord(component, lookupId);
    helper.valueChangeEvent(component, helper);
  },

  handleCreateNew: function (component, event, helper) {
    component.set("v.showModal", true);

    // var createRecordEvent = $A.get("e.force:createRecord");
    // createRecordEvent.setParams({
    //     "entityApiName": component.get("v.sObjectName"),
    //     "defaultFieldValues": component.get("v.sObjectName") == "Contact"  && component.get("v.relatedRecordId")? {
    //         "AccountId" : component.get("v.relatedRecordId")
    //     } : null
    // });
    // createRecordEvent.fire();
  },

  handleSubmit: function (component, event, helper) {
    event.preventDefault();
    component.set("v.disableModalButtons", true);
    let fields = event.getParam("fields");
    if (component.get("v.recordTypeId") != null) {
      fields.RecordTypeId = component.get("v.recordTypeId");
    }

    if (component.get("v.sObjectName") == "Account") {
      fields.Account_Status__c = "Active CoreVest Vendor";
//Insurance_Company__c Title_Company__c Escrow_Agent__c
      if(component.get("v.fieldName") == "Insurance_Company__c") {
        fields.Non_Borrower_Account_Type__c = "Insurance Agent";
      } else if (["Title_Company__c", "Escrow_Agent__c"].includes(component.get("v.fieldName"))) {
        fields.Non_Borrower_Account_Type__c = "Title and Escrow";
      }
    }

    if (fields.Name != null) {
      component.set("v.searchTerm", fields.Name);
    } else if (fields.FirstName != null && fields.LastName != null) {
      component.set("v.searchTerm", fields.FirstName + " " + fields.LastName);
    }

    component.find("recordEditForm").submit(fields);
  },

  handleSuccess: function (component, event, helper) {
    component.set("v.disableModalButtons", false);
    component.set("v.results", null);
    var record = JSON.parse(JSON.stringify(event.getParams().response));

    component.set("v.value", record.id);
    console.log(record.id);
    //helper.setRecord(component, lookupId);
    helper.valueChangeEvent(component, helper);
    component.set("v.showModal", false);
  },

  handleFormError: function (component, event, helper) {
    component.set("v.disableModalButtons", false);
    component.set("v.hasError", true);
  },
  handleFocus: function (component) {
    let whereClause = component.get("v.whereClause");
    const record = component.get("v.record");
    if (whereClause.includes("{")) {
      let whereField = whereClause.substring(
        whereClause.indexOf("{") + 1,
        whereClause.lastIndexOf("}")
      );
      if (
        !!record &&
        (!record.hasOwnProperty(whereField) || !record[whereField])
      ) {
        whereClause = whereClause
          .replace(whereField, "")
          .replace("{", "'")
          .replace("}", "'");
        if (whereField === "Escrow_Agent__c") {
          whereField = "Escrow Company";
        }
        component.set(
          "v.dependentMessage",
          "Please select " +
            whereField.replace("__c", "").replaceAll("_", " ") +
            " first."
        );
      } else {
        component.set("v.dependentMessage", null);
      }
    }
    component.set("v.isFocused", true);
  },

  handleBlur: function (component) {
    setTimeout(() => component.set("v.isFocused", false), 200);
    // component.set("v.isFocused", false);
  },

  handleCancel: function (component) {
    component.set("v.showModal", false);
  },

  clearRecord: function (component, event, helper) {
    component.set("v.value", null);
    component.set("v.searchTerm", "");
    // component.set('v.record', null);
    helper.valueChangeEvent(component, helper);
  }
});
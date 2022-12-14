({
  compileFields: function (component) {
    var fields = [];
    var columns = component.find("dataTable").get("v.columns");
    for (var i = 0; i < columns.length; i++) {
      fields.push(columns[i].get("v.name"));
    }
    
    fields.push("Deal__r.isClosed");

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
  queryRecords: function (component, helper) {
    var tableCmp = component.find("dataTable");

    tableCmp.toggleSpinner();
    this.callAction(
      component,
      "c.getRecords",
      {
        parentId: component.get("v.recordId"),
        parentFieldName: component.get("v.parentFieldName"),
        sobjectType: component.get("v.sobjectType"),
        fields: component.get("v.fieldList"),
        page: 1,
        pageSize: tableCmp.get("v.pageSize") * tableCmp.get("v.pageNumber"),
        sortCol: tableCmp.get("v.sortColumnName"),
        sortDir: tableCmp.get("v.sortDirection"),
        whereClause: component.get("v.whereClause")
      },
      function (data) {
        var tableCmp = component.find("dataTable");
        let newData = helper.processTypeAttributes(data);
        tableCmp.set("v.rows", newData);

        tableCmp.toggleSpinner();
      }
    );
  },

  saveRecords: function (component, helper) {
    var table = component.find("dataTable");

    var rows = table.get("v.rows");

    console.log("--rows--");
    console.log(rows);

    let records = [];

    rows.forEach((row) => {
      records.push(row);
      //records.push(row['Contact__r']);
    });

    table.toggleSpinner();
    helper.callAction(
      component,
      "c.upsertRecords",
      {
        records: records
      },

      function (data) {
        table.toggleSpinner();
        component.set("v.editMode", !component.get("v.editMode"));
        helper.queryRecords(component, helper);
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
        helper.queryRecords(component, helper);
      }
    );
  },

  compilePermissions: function (component, helper, records) {
    let fields = [
      "Name",
      "Contact_Full_Name__c",
      "Zip__c",
      "Contact_Title__c",
      "State__c",
      "City__c",
      "Street__c",
      "Phone__c",
      "Email__c",
      "Company_Name__c",
      "Entity_Type__c",
      "Operating_Agreement_Date__c",
      "Company_Type__c",
      "Rental_Units_Owned__c",
      "Years_of_Experience1__c",
      "Cash_Equivalent__c",
      "Cash_Position__c",
      "Annual_Income_Last_Year__c",
      "Annual_Income_2_Years_Ago__c",
      "Experian__c",
      "TransUnion__c",
      "Equifax__c",
      "Net_Worth__c",
      "Background_Risk_Number__c",
      "Liquidity__c",
      "Experience__c",
      "Sponsor_Tier__c",
      "Percentage_Owned__c",
      "Legal_Name__c",
      "Primary_Guarantor__c",
      "Credit_Score_Date__c"
    ];
    component
      .find("util")
      .getPermissions("Deal_Contact__c", fields, (response) => {
        component.set("v.permissionsMap", response);

        var fields = [];
        var columns = component.find("dataTable").get("v.columns");
        for (var i = 0; i < columns.length; i++) {
          fields.push(columns[i].get("v.name"));
        }

        component.set("v.fieldList", fields);
      });
  },
  processTypeAttributes: function (data) {
    console.log(data);
    if(data.length > 0 && data[0].hasOwnProperty("Deal__r") && data[0].Deal__r.hasOwnProperty("IsClosed") && data[0].Deal__r.IsClosed) {
      return data;
    }
    let newData = [];
    data.forEach((v) => {
      let typeAttributes = [];
      let errMessage =
        "These items need to be corrected before the Deal can be updated to Closed Won:";
      let warnMessage =
        "These items will not prevent Closing of this Deal, but should be entered for accuracy of data:";
      let hasError = false;
      let hasWarning = false;

      if (!v.Experian__c || !v.TransUnion__c || !v.Equifax__c) {
        errMessage += "\nRecord is missing a credit score.";
        hasError = true;
      }

      if (v.Credit_Score_Date__c != null) {
        let diff =
          new Date().getTime() - new Date(v.Credit_Score_Date__c).getTime();
        let totalDays = Math.ceil(diff / (1000 * 3600 * 24));
        if (totalDays > 180) {
          errMessage += "\nThe Credit Score date has expired.";
          hasError = true;
        }
      }

      if (v.hasOwnProperty("Contact__r")) {
        if (!v.Contact__r.Email || $A.util.isEmpty(v.Contact__r.Email)) {
          errMessage +=
            "\nContact is missing an email address.  Please enter an email on the Contact.";
          hasError = true;
        }

        if (
          !v.Contact__r.Phone &&
          !v.Contact__r.HomePhone &&
          !v.Contact__r.MobilePhone
        ) {
          errMessage +=
            "\nContact is missing a Phone Number.  Please enter a Phone Number on the Contact.";
          hasError = true;
        }

        if (
          !v.Contact__r.MailingStreet ||
          !v.Contact__r.MailingCity ||
          !v.Contact__r.MailingPostalCode ||
          !v.Contact__r.MailingState
        ) {
          errMessage +=
            "\nAddress is missing.  Please enter on the Contact Record.";
          hasError = true;
        }

        if (!v.Contact__r.Title) {
          warnMessage +=
            "\nTitle missing from this Contact. Please enter the Title on the Contact Record.";
          hasWarning = true;
        }

        if (!v.Contact__r.Salutation) {
          warnMessage +=
            "\nSalutation is missing from this Contact. Please enter the Salutation on the Contact Record.";
          hasWarning = true;
        }
      }

      let newObj = Object.assign({}, v);
      if (hasError) {
        typeAttributes.push({
          iconName: "utility:warning",
          variant: "error",
          alternativeText: "error",
          title: errMessage
        });
      }

      if (hasWarning) {
        typeAttributes.push({
          iconName: "utility:warning",
          variant: "warning",
          alternativeText: "warning",
          title: warnMessage
        });
      }

      if (typeAttributes.length > 0) {
        newObj.typeAttributes = JSON.stringify(typeAttributes);
      }

      newData.push(newObj);
    });

    return newData;
  }
});
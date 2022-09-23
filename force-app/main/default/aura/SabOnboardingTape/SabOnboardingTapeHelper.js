({
  retrieveProperties: function (component, helper) {
    const dataMap = component.get("v.sheetDataMap");

    const fields = ["Id", "Deal__c"];
    for (let i = 0; i < dataMap.length; i++) {
      const curr = dataMap[i];
      if (curr.field != null && curr.field.length > 0 && !fields.includes(curr.field)) {
        fields.push(curr.field);
      }
    }

    const action = component.get("c.query");
    const queryString =
      "SELECT " +
      fields.join(",") +
      " FROM Property__c WHERE Deal__r.isClosed = true AND Deal__r.RecordType.DeveloperName='Single_Asset_Bridge_Loan' AND Deal__r.Onboarding_File_Sent_to_Servicer__c = NULL ORDER BY Deal__r.Deal_Loan_Number__c ASC";
    action.setParams({ queryString });

    action.setCallback(this, function (response) {
      const state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.properties", response.getReturnValue());
        component.set("v.isLoaded", true);
      } else if (state === "ERROR") {
        const errors = response.getError();
        let errMessage = "Error: ";
        if (errors) {
          if (errors[0] && errors[0].message) {
            errMessage += errors[0].message;
          }
        } else {
          errMessage += "Unknown Error.";
        }

        helper.showToast("error", "Error", errMessage);
      }
    });

    $A.enqueueAction(action);
  },

  getTemplate: function (component, helper) {
    const fileName = component.get("v.templateName");

    const action = component.get("c.getTemplate");
    action.setParams({ fileName });
    action.setCallback(this, function (response) {
      const state = response.getState();
      if (state === "SUCCESS") {
        const res = response.getReturnValue();

        component.set("v.templateData", res);
      } else if (state === "ERROR") {
        const errors = response.getError();
        let errMessage = "Error Retrieving Template: ";
        if (errors) {
          if (errors[0] && errors[0].message) {
            errMessage += errors[0].message;
          }
        } else {
          errMessage += "Unknown Error.";
        }

        helper.showToast("error", "Error", errMessage);
      }
    });

    $A.enqueueAction(action);
  },

  saveDealDocument: function (component, helper, fileData, fileName) {
    const action = component.get("c.createDealDocumentsFromFile");
    const dealIds = [];
    const props = component.get("v.properties");
    props.forEach((p) => {
      if (!dealIds.includes(p.Deal__c)) {
        dealIds.push(p.Deal__c);
      }
    });

    action.setParams({
      parentIds: dealIds,
      fileData,
      fileName,
      fileType: "application/vnd.ms-excel"
    });

    action.setCallback(this, function (response) {
      const state = response.getState();
      if (state === "SUCCESS") {
        helper.showToast(
          "success",
          "Success",
          "Data tape successfully saved as Deal Documents."
        );
      } else if (state === "ERROR") {
        const errors = response.getError();
        let errMessage = "Error Saving Deal Documents: ";
        if (errors) {
          if (errors[0] && errors[0].message) {
            errMessage += errors[0].message;
          }
        } else {
          errMessage += "Unknown Error.";
        }

        helper.showToast("error", "Error", errMessage);
      }
    });

    $A.enqueueAction(action);
  },

  showToast: function (type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      type: type,
      message: message
    });
    toastEvent.fire();
  },

  base64ToArrayBuffer: function (base64) {
    var binary_string = window.atob(base64);
    var len = binary_string.length;
    var bytes = new Uint8Array(len);
    // console.log(binary_string);
    console.log(len);
    for (var i = 0; i < len; i++) {
      bytes[i] = binary_string.charCodeAt(i);
    }
    return bytes.buffer;
  }


});
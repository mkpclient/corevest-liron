({
  init: function (component, event, helper) {
    var queryString = location.search;
	
    if (!$A.util.isEmpty(queryString)) {
      var query = {};
      var pairs = (queryString[0] === "?"
        ? queryString.substr(1)
        : queryString
      ).split("&");
      for (var i = 0; i < pairs.length; i++) {
        var pair = pairs[i].split("=");
        query[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1] || "");
      }
	
      component.set("v.recordId", query.id);
    }
  },
  submit: function (component, event, helper) {
    let properties = [];
    $A.util.toggleClass(component.find("spinner"), "slds-hide");
    component.find("submitBtn").set("v.disabled", true);
    let valid = false;
    if (component.get("v.properties").length > 0) {
      let bulkProperties = component.find("bulkProperties");
      if (!$A.util.isArray(bulkProperties)) {
        bulkProperties = [bulkProperties];
      }
      valid = true;
      bulkProperties.forEach(property => {
        if (!property.validateInput()) {
          valid = false;
        }
        properties.push(property.get("v.property"));
      });

      //properties = component.get("v.properties");
    } else {
      valid = component.find("singleProperty").validateInput();
      properties.push(component.find("singleProperty").get("v.property"));
    }

    //console.log("properties");
    //console.log(properties);

    if (valid) {
      if (window.confirm("Submit these Funding Request(s)?")) {
        let action = component.get("c.insertProperties");

        properties.forEach(property => {
          property.sobjectType = "Property__c";
          property.Deal__c = component.get("v.recordId");

          property.Is_Renovation__c =
            property.Is_Renovation__c == "Renovation" ? true : false;
        });
        console.log(JSON.parse(JSON.stringify(properties)));
        action.setParams({
          opportunityId: component.get("v.recordId"),
          properties: JSON.stringify(properties)
        });

        action.setCallback(this, function (response) {
          let state = response.getState();

          if (state === "SUCCESS") {
            $A.util.toggleClass(component.find("spinner"), "slds-hide");
            component.find("submitBtn").set("v.disabled", false);
            let returnValue = response.getReturnValue();
            if (returnValue.length > 1) {
              let dealId = component.get("v.recordId");
              let url = "/portal/s/deal?id=" + dealId;
              location.href = url;
            } else {
              let propertyId = returnValue[0].Id;
              let url = "/portal/s/property?id=" + propertyId;

              location.href = url;
            }
          } else if (state === "ERROR") {
            console.log("--error--");
            console.log(response.getError());
            $A.util.toggleClass(component.find("spinner"), "slds-hide");
            component.find("submitBtn").set("v.disabled", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Error",
              message: response.getError()[0].message
            });
            toastEvent.fire();
          }
        });

        $A.enqueueAction(action);
      } else {
        $A.util.toggleClass(component.find("spinner"), "slds-hide");
        component.find("submitBtn").set("v.disabled", false);
      }
    }
  },

  clearProperties: function (component, event, helper) {
    component.set("v.properties", []);
  },

  back: function (component, event, helper) {
    let recordId = component.get("v.recordId");
    let url = "/portal/s/deal?id=" + recordId;

    location.href = url;
  },

  downloadTemplate: function (component, event, helper) {
    console.log("download template");
    let action = component.get("c.getDatatapeTemplate");

    action.setCallback(this, function (response) {
      let state = response.getState();
      if (state === "SUCCESS") {
        //console.log(response.getReturnValue());
        var link = document.createElement("a");
        link.href =
          "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64," +
          JSON.parse(response.getReturnValue());
        link.download = "BridgePortalDatatape.xlsx";
        link.click();
      } else if (state === "ERROR") {
        console.log("error");
        console.log(response.getError()[0].message);
      }
    });

    $A.enqueueAction(action);
  }
});
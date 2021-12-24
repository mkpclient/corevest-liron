({
  init: function(component, event, helper) {
    let action = component.get("c.validateRecord");

    action.setParams({
      recordId: component.get("v.recordId")
    });

    action.setCallback(this, response => {
      switch (response.getState()) {
        case "SUCCESS":
          let validationResponse = JSON.parse(response.getReturnValue());
          if (validationResponse.result === "success") {
            component.set("v.recordType", validationResponse.recordType);
            $A.util.toggleClass(component.find("successMessage"), "slds-hide");
          } else if (validationResponse.result == "error") {
            //component.set('v.errorMessage', validationResponse.errorMsg);
            component.set("v.errorMessages", validationResponse.errorMsg);
          }

          break;
        case "ERROR":
          console.log(response.getError());
          break;
      }
    });

    $A.enqueueAction(action);
  },

  submitApproval: function(component, event, helper) {
    console.log("submit for approval");

    let action = component.get("c.startApproval");
    action.setParams({
      comments: component.get("v.comments"),
      recordId: component.get("v.recordId"),
      recordType: component.get("v.recordType")
    });
    action.setCallback(this, response => {
      switch (response.getState()) {
        case "SUCCESS":
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success!",
            message: "The deal has been submitted for approval",
            type: "success"
          });
          toastEvent.fire();
          $A.get("e.force:closeQuickAction").fire();
          $A.get("e.force:refreshView").fire();

          break;
        case "ERROR":
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Error",
            message: response.getError(),
            type: "error"
          });
          toastEvent.fire();

          break;
      }
    });

    $A.enqueueAction(action);
  }
});
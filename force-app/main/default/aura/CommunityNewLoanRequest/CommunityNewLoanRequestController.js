({
  init: function(component, event, helper) {
    let action = component.get("c.getContactDetails");
    $A.util.toggleClass(component.find("spinner"), "slds-hide");
    action.setCallback(this, response => {
      let state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.contact", response.getReturnValue());
      } else if (state === "ERROR") {
        console.log("--error--");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  createRequest: function(component, event, helper) {
    let valid = true;
    component.find("requiredField").forEach(input => {
      //console.log('input');
      input.showHelpMessageIfInvalid();
      if (!input.get("v.validity").valid) {
        valid = false;
      }
    });

    if (valid) {
      $A.util.toggleClass(component.find("spinner"), "slds-hide");
      let contact = component.get("v.contact");
      let task = {
        sobjectType: "Task",
        WhoId: contact.Id,
        Subject: "New Loan Request",
        OwnerId: contact.OwnerId,
        
        Description:
          "$" +
          helper.formatMoney(component.get("v.loanAmount")) +
          " - " +
          component.get("v.comments")
      };

      let action = component.get("c.submitRequest");
      action.setParams({ updatedContact: contact, t: task });
      action.setCallback(this, response => {
        let state = response.getState();
        // $A.util.toggleClass(component.find("spinner"), "slds-hide");
        if (state === "SUCCESS") {
          console.log("success");
          location.href = "/portal/s";
        } else if (state === "ERROR") {
          console.log("error");
          console.log(response.getError());
        }
      });

      $A.enqueueAction(action);
    }
  }
});
({
  singleSmartyStreetsCall: function(component, propertyIds) {
    return new Promise((resolve, reject) => {
      let action = component.get("c.callSmartyStreets");
      action.setParams({
        propertyIds: propertyIds
      });
      action.setCallback(this, response => {
        let state = response.getState();
        let res = response.getReturnValue();
        let error = response.getError();
        console.log("state: ", state);
        if (state == "SUCCESS") {
          resolve(res);
        } else {
          let errorMsg = error[0].message;
          reject(new Error(errorMsg));
        }
      });
      $A.enqueueAction(action);
    });
  }
});
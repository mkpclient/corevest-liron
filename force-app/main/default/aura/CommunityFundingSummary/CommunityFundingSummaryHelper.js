({
  queryFundings: function(component, event, helper) {
    let action = component.get("c.getLoanFundings");
    action.setParams({ recordId: component.get("v.recordId") });
    action.setCallback(this, function(response) {
      let state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        component.set("v.properties", response.getReturnValue());
      } else {
        console.log("error");
        console.log(response.getError());
      }
    });
    $A.enqueueAction(action);
  }
});
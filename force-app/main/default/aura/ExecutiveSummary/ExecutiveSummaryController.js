({
  init: function (component, event, helper) {
    const recordId = component.get("v.record.Id");
    console.log(component.get("v.record"));
    const action = component.get("c.getFileId");
    action.setParams({ recordId: recordId });
    action.setCallback(this, (res) => {
      const state = res.getState();
      if (state === "SUCCESS") {
        component.set("v.fileId", res.getReturnValue());
        component.set("v.isLoaded", true);
      } else {
        const errors = res.getError();
        if (errors && errors.length > 0 && errors[0].message) {
          console.error("ERROR IN EXEC SUMMARY: " + errors[0].message);
        }
      }
    });
    $A.enqueueAction(action);
  }
});
({
  redirect: function (component, event, helper) {
    var recordId = component.get("v.recordId");
    var action = component.get("c.getRecordTypeName");
    action.setParams({
      i: recordId
    });
    action.setCallback(this, function (response) {
      let state = response.getState();
      if ("SUCCESS" === state) {
        let returnVal = response.getReturnValue();
        console.log("--record id--");
        console.log(recordId);
				let componentName = returnVal == "Single_Asset_Bridge_Loan" ?  "c:SabFciDataTape" : "c:BridgeDataTape";
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
          componentDef: componentName,
          componentAttributes: {
            recordId: recordId,
            isRedirect: true
          }
        });

        evt.fire();
      } else {
        console.log(response.getError());
      }
    });
    $A.enqueueAction(action);
  }
});

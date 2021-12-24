({
  init: function (component, event, helper) {
    console.log("init");
    let action = component.get("c.returnHistory");
    action.setParams({
      recordId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      let state = response.getState();
      if ("SUCCESS" === state) {
        let returnVal = response.getReturnValue();
        //console.log("approval histories", returnVal);

        const approvalMap = {};

        returnVal.forEach((history) => {
          if (!approvalMap[history.Process_Instance_Id__c]) {
            approvalMap[history.Process_Instance_Id__c] = [];
          }
          approvalMap[history.Process_Instance_Id__c].push(history);
        });

        const histories = [];
        for (const history in approvalMap) {
          histories.push(approvalMap[history]);
        }

        console.log("histories", histories);

        component.set("v.histories", histories);
      } else {
        console.log(response.getError());
      }
    });
    $A.enqueueAction(action);
  }
});
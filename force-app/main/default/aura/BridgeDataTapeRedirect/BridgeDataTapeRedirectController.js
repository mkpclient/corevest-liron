({
  redirect: function (component, event, helper) {
    var recordId = component.get("v.recordId");
    const record = component.get("v.dealRecord");
    const isFciSab = record.Record_Type_Name__c == "Single_Asset_Bridge_Loan" && record.Servicer_Name__c == "FCI";
    let componentName = isFciSab ?  "c:SabFciDataTape" : "c:BridgeDataTape";
    var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
      componentDef: componentName,
      componentAttributes: {
        recordId: recordId,
        isRedirect: true
      }
    });

    evt.fire();  }
});

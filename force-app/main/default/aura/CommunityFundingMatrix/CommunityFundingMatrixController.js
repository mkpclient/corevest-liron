({
  init: function(component, event, helper) {
    var url = location.hash;
    if (!$A.util.isEmpty(url) && $A.util.isEmpty(component.get("v.recordId"))) {
      var recordId = location.hash.split("#!")[1].split("?")[0];

      component.set("v.recordId", recordId);
    }

    let action = component.get("c.initMatrixScreen");
    action.setParams({ recordId: component.get("v.recordId") });
    action.setCallback(this, function(response) {
      let state = response.getState();

      if (state === "SUCCESS") {
        let resp = JSON.parse(response.getReturnValue());
        console.log(resp);

        if (!$A.util.isEmpty(resp.docTypes)) {
          let docTypes = [];
          let picklistMap = { "Asset Diligence": [""] };
          for (let docType in resp.docTypes) {
            docTypes.push({
              type: docType,
              docs: resp.docTypes[docType]
            });

            picklistMap["Asset Diligence"].push(docType);
          }
          console.log(picklistMap);
          // console.log(docTypes);
          component.set("v.picklistMap", picklistMap);
          component.set("v.statusPercent", resp.statusPercent);
          component.set("v.reviewedPercent", resp.docsReviewedPercent);
          component.set("v.totalPercent", resp.totalPercent);
          component.set("v.statusText", resp.statusText);
          component.set("v.reviewedText", resp.docsReviewedText);
          component.set("v.docTypes", docTypes);
          component.set("v.errorMsg", resp.errorMsg);

          let fields = [];
          resp.fields.forEach(field => {
            fields.push({
              label: resp.fieldMap[field][0],
              type: resp.fieldMap[field][1],
              value: resp.property[field],
              fieldName: field
            });
          });

          component.set("v.fields", fields);
        }

        component.set("v.property", resp.property);
        component.set("v.rdy", true);
      } else if (state === "ERROR") {
        console.log("error");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  closeModal: function(component, event, helper) {
    component.set("v.modalOpen", false);
  },

  saveField: function(component, event, helper) {
    let fieldName = event.getSource().get("v.name");
    let value = event.getSource().get("v.value");

    let property = {
      Id: component.get("v.recordId"),
      sobjectType: "Property__c"
    };
    property[fieldName] = value;

    let action = component.get("c.updateRecord");
    action.setParams({ record: property });

    action.setCallback(this, response => {
      let state = response.getState();
      if (state === "SUCCESS") {
        console.log("success");
      } else if (state === "ERROR") {
        console.log("error");
      }
    });

    $A.enqueueAction(action);
  }
});
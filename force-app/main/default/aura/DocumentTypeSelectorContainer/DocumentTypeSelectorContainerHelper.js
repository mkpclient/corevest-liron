({
  closeModal: function() {
    $A.get("e.force:closeQuickAction").fire();
  },
  saveSingle: function(component) {
    console.log("save");

    let selector = component.find("selector");

    let validated = selector.isValidated();

    if (validated) {
      component.set("v.saving", true);

      let sobjectType = component.get("v.sObjectName");
      let recordIds = [];
      if (sobjectType === "Deal_Document__c") {
        recordIds.push(component.get("v.recordId"));
      } else {
        recordIds = component.get("v.recordIds");
      }

      selector
        .updateDocuments(recordIds)
        .then(results => {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success!",
            message: "The records has been updated successfully.",
            type: "success"
          });
          toastEvent.fire();

          $A.get("e.force:refreshView").fire();
          component.set("v.modalOpen", false);
          $A.get("e.force:closeQuickAction").fire();
        })
        .catch(error => {
          console.log(error);
          console.log("saving error");
          component.set("v.saving", false);
        });
    } else {
    }
  },

  saveBulk: function(component) {
    let records = [];

    let validated = true;

    let selectors = component.find("bulkSelector");
    selectors = $A.util.isArray(selectors) ? selectors : [selectors];

    selectors.forEach(selector => {
      let res = JSON.parse(selector.validateAndReturn());
      if (!res.validated) {
        validated = res.validated;
      }

      records = res.record;

      // records.push({
      //   Id: res.record.Id,
      //   Document_Type__c: res.record.Document_Type__c,
      //   Property__c: res.record.Property__c,
      //   Section__c: res.record.Section__c,
      //   Type__c: res.record.Type__c,
      //   sobjectType: "Deal_Document__c"
      // });
    });

    console.log(records);

    if (validated) {
      console.log("upsert");
      console.log(records);
      component.find("util").upsert(records, results => {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success!",
          message: "The records has been updated successfully.",
          type: "success"
        });
        toastEvent.fire();

        $A.get("e.force:refreshView").fire();
        component.set("v.modalOpen", false);
        $A.get("e.force:closeQuickAction").fire();
      });
    }
  }
});
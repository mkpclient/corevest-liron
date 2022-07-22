({
  createAdvance: function (component, feeAmount) {
    let property = component.get("v.record");

    // let renoType = property.Renovation_Type_formula__c;

    // if (renoType == "No Renovation") {
    //   renoType = "Non-Renovation";
    //   /**   else if(renoType == 'Ground Up Construction') {
    //             renoType == 'Ground Up Construction';
    //         }*/
    // } else {
    //   renoType = "Renovation";
    // }

    var advance = {
      sobjectType: "Advance__c",
      Deal__c: property.Deal__c,
      // Status__c: "Pending",
      // Property_Record_Type__c: renoType
    };

    component.find("util").upsert(advance, (data) => {
      let advId = data[0].Id;

      var propertyAdvances = {
        sobjectType: "Property_Advance__c",
        Advance__c: advId,
        Property__c: property.Id,
        Advance_Fee__c: feeAmount
      };

      component.find("util").upsert(propertyAdvances, (pAdvs) => {
        $A.util.addClass(component.find("spinner"), "slds-hide");
        component.find("newAdvance").set("v.disabled", false);
        component.find("navService").navigate({
          type: "standard__recordPage",
          attributes: {
            objectApiName: "Advance__c",
            recordId: advId,
            actionName: "view"
          }
        });
      });
    });
  },

  compilePermissions: function (component, helper, records) {
    let fields = ["Name"];

    component.find("util").getPermissions("Advance__c", fields, (response) => {
      component.set("v.permissionsMap", response);
    });
  }
});
({
  init: function (component, event, helper) {
    let recordId = component.get("v.recordId");
    var queryString = `SELECT Id, Advance__c, Advance__r.Status__c, Advance__r.Name, Advance__r.Wire_Date__c, Purchase_Price__c, Initial_Disbursement__c, Renovation_Reserve__c, Approved_Advance_Amount_Calc__c FROM Property_Advance__c WHERE Property__c = '${recordId}'`;
    console.log(queryString);

    component.find("util").query(queryString, (data) => {
      component.set("v.records", data);
    });

    helper.compilePermissions(component);
  },

  handleClick: function (component, event, helper) {
    event.preventDefault();
    console.log("click");

    console.log(event.target);
    var recordId = event.target.title;
    console.log(recordId);
    component.find("navService").navigate({
      type: "standard__recordPage",
      attributes: {
        objectApiName: "Advance__c",
        recordId: recordId,
        actionName: "view"
      }
    });
  },

  createAdvance: function (component, event, helper) {
    component.find("newAdvance").set("v.disabled", true);
    $A.util.removeClass(component.find("spinner"), "slds-hide");

    let recordId = component.get("v.recordId");
    let queryString = `Select Id, Status__c,  Deal__c, Asset_Maturity_Date__c, Renovation_Type_formula__c, Deal__r.Max_Advance_Fee__c, Advance_Fee_formula__c, Deal__r.Advance_Fee_Remaining__c FROM Property__c`;
    queryString += ` WHERE Id = '${recordId}' `;

    component.find("util").query(queryString, (data) => {
      let property = data[0];
      component.set("v.record", property);
      if (
        property.Status__c != "Due Diligence" &&
        property.Status__c != "Pending" &&
        property.Status__c != "Closing" &&
        (property.Status__c != "Active" && property.Reno_Advance_Amount_Remaining__c != 0)
      ) {
        var toast = $A.get("e.force:showToast");
        toast.setParams({
          type: "warning",
          message: "Property Status must be in Due Diligence, Pending, Closing Status or Active with available Renovation funding"
        });

        toast.fire();
      } else if (
        !$A.util.isEmpty(property.Asset_Maturity_Date__c) &&
        new Date(property.Asset_Maturity_Date__c) < new Date()
      ) {
        var toast = $A.get("e.force:showToast");
        toast.setParams({
          type: "warning",
          message: "The Asset Maturity Date for this Asset has expired."
        });

        $A.util.addClass(component.find("spinner"), "slds-hide");
        component.find("newAdvance").set("v.disabled", false);
        toast.fire();
      } else {
        if (
          property.Deal__r.Max_Advance_Fee__c == "Yes" &&
          property.Advance_Fee_formula__c >
            property.Deal__r.Advance_Fee_Remaining__c
        ) {
          //component.set('v.record')
          var modal = component.find("modal");
          var backdrop = component.find("modal-backdrop");
          $A.util.addClass(modal, "slds-fade-in-open");
          $A.util.removeClass(modal, "slds-modal__close");
          $A.util.addClass(backdrop, "slds-backdrop--open");
        } else {
          helper.createAdvance(component);
        }
      }
    });
  },
  continueAdvance: function (component, event, helper) {
    var modal = component.find("modal");
    var backdrop = component.find("modal-backdrop");
    $A.util.removeClass(modal, "slds-fade-in-open");
    $A.util.addClass(modal, "slds-modal__close");
    $A.util.removeClass(backdrop, "slds-backdrop--open");

    let feeAdjustment = component.get("v.record").Deal__r
      .Advance_Fee_Remaining__c;

    helper.createAdvance(component, feeAdjustment);
  },

  close: function (component, event, helper) {
    var modal = component.find("modal");
    var backdrop = component.find("modal-backdrop");
    $A.util.removeClass(modal, "slds-fade-in-open");
    $A.util.addClass(modal, "slds-modal__close");
    $A.util.removeClass(backdrop, "slds-backdrop--open");
    $A.util.addClass(component.find("spinner"), "slds-hide");
    component.find("newAdvance").set("v.disabled", false);
  }
});
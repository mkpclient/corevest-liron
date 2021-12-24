({
  init: function(component, event, helper) {
    var recordId = component.get("v.recordId");
    var sobjectType = component.get("v.sObjectName");

    var queryString = "SELECT ";
    if (sobjectType == "Opportunity") {
      queryString +=
        "Requested_Max_initial_LTV_LTC__c, Requested_Total_Loan_LTC__c, Requested_ARV_LTV__c, Requested_Rehab_Holdback_Limit__c";
    } else if (sobjectType == "Property__c") {
      queryString +=
        "BPO_Appraisal_Value__c, Purchase_Price__c, After_Repair_Value__c, Rehab_Budget__c, Initial_Disbursement__c, Approved_Renovation_Holdback__c, Deal__r.Max_Initial_LTV_LTC__c, Deal__r.Total_Loan_LTC__c, Deal__r.Total_ARV_LTV__c, Deal__r.Rehab_Holdback_Limit__c";
    }

    queryString += " FROM " + sobjectType;
    queryString += " WHERE Id = '" + recordId + "'";

    component.find("util").query(queryString, function(data) {
      console.log(data);

      var maxInitialLTVLTC;
      var totalARVLTV;
      var rehabHoldbackLimit;
      var totalLoanLTC;
      var asIsValue;
      var afterRehabValue;
      var purchasePrice;
      var rehabBudget;
      var initialDisbursement;
      var approvedRenoAdvance;
      if (sobjectType == "Opportunity") {
        maxInitialLTVLTC = $A.util.isUndefinedOrNull(
          data[0].Requested_Max_Initial_LTV_LTC__c
        )
          ? 0
          : data[0].Requested_Max_Initial_LTV_LTC__c;
        totalARVLTV = $A.util.isUndefinedOrNull(data[0].Requested_ARV_LTV__c)
          ? 0
          : data[0].Requested_ARV_LTV__c;
        rehabHoldbackLimit = $A.util.isUndefinedOrNull(
          data[0].Requested_Rehab_Holdback_Limit__c
        )
          ? 0
          : data[0].Requested_Rehab_Holdback_Limit__c;
        totalLoanLTC = $A.util.isUndefinedOrNull(
          data[0].Requested_Total_Loan_LTC__c
        )
          ? 0
          : data[0].Requested_Total_Loan_LTC__c;
      }

      if (sobjectType == "Property__c") {
        maxInitialLTVLTC = $A.util.isUndefinedOrNull(
          data[0].Deal__r.Max_Initial_LTV_LTC__c
        )
          ? 0
          : data[0].Deal__r.Max_Initial_LTV_LTC__c;
        totalARVLTV = $A.util.isUndefinedOrNull(
          data[0].Deal__r.Total_ARV_LTV__c
        )
          ? 0
          : data[0].Deal__r.Total_ARV_LTV__c;
        rehabHoldbackLimit = $A.util.isUndefinedOrNull(
          data[0].Deal__r.Rehab_Holdback_Limit__c
        )
          ? 0
          : data[0].Deal__r.Rehab_Holdback_Limit__c;
        totalLoanLTC = $A.util.isUndefinedOrNull(
          data[0].Deal__r.Total_Loan_LTC__c
        )
          ? 0
          : data[0].Deal__r.Total_Loan_LTC__c;
        asIsValue = $A.util.isUndefinedOrNull(data[0].BPO_Appraisal_Value__c)
          ? 0
          : data[0].BPO_Appraisal_Value__c;
        afterRehabValue = $A.util.isUndefinedOrNull(
          data[0].After_Repair_Value__c
        )
          ? 0
          : data[0].After_Repair_Value__c;
        purchasePrice = $A.util.isUndefinedOrNull(data[0].Purchase_Price__c)
          ? 0
          : data[0].Purchase_Price__c;
        rehabBudget = $A.util.isUndefinedOrNull(data[0].Rehab_Budget__c)
          ? 0
          : data[0].Rehab_Budget__c;
        initialDisbursement = $A.util.isUndefinedOrNull(
          data[0].Initial_Disbursement__c
        )
          ? 0
          : data[0].Initial_Disbursement__c;
        approvedRenoAdvance = $A.util.isUndefinedOrNull(
          data[0].Approved_Renovation_Holdback__c
        )
          ? 0
          : data[0].Approved_Renovation_Holdback__c;
      }

      var calculatorFields = {
        asIsValue: asIsValue,
        afterRehabValue: afterRehabValue,
        purchasePrice: purchasePrice,
        rehabBudget: rehabBudget,
        interestRate: 0,
        totalCostBasisValue: 0,
        maxInitialLTVLTC: maxInitialLTVLTC,
        totalARVLTV: totalARVLTV,
        rehabHoldbackLimit: rehabHoldbackLimit,
        totalLoanLTC: totalLoanLTC,
        initialDisbursement: initialDisbursement,
        approvedRenoAdvance: approvedRenoAdvance
      };

      console.log(calculatorFields);
      component.set("v.calculatorFields", calculatorFields);

      helper.calculateFields(component);
    });
  },

  toggleSection: function(component, event, helper) {
    var id = event.target.getAttribute("data-id");

    $A.util.toggleClass(component.find(id), "slds-is-open");
    $A.util.toggleClass(
      component.find(id + "-icon"),
      "slds-accordion__summary-action-icon"
    );
  },

  calculateFields: function(component, event, helper) {
    helper.calculateFields(component);
  },

  saveField: function(component, event, helper) {
    component
      .find("saveSpinner")
      .forEach(spinner => $A.util.toggleClass(spinner, "slds-hide"));
    let recordId = component.get("v.recordId");
    let fieldName = event.getSource().get("v.name");
    let value =
      fieldName == "Override_Initial_Disbursement__c"
        ? component.get("v.calculatorFields").initialAdvance
        : component.get("v.calculatorFields").holdbackAdvance;

    let property = {
      Id: component.get("v.recordId"),
      sobjectType: "Property__c"
    };
    property[fieldName] = value;

    component.find("util").upsert(property, res => {
      console.log("this occurred");
      $A.get("e.force:refreshView").fire();
      component
        .find("saveSpinner")
        .forEach(spinner => $A.util.toggleClass(spinner, "slds-hide"));
    });
  }
});
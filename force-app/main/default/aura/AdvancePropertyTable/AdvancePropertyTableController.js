({
  init: function (component, event, helper) {
    helper.resetPropertyStatusSelection(component);
    helper.clearUpdatedPropertyStatuses(component);
    helper.queryRecord(component);
    helper.queryPropertyAdvances(component, helper);
    helper.queryWires(component);
    helper.compilePermissions(component);
    helper.queryDealNotes(component);
    helper.compilePropertyPermissions(component);
    helper.retrievePropertyStatusPicklistValues(component);
  },
  handleOutsideClick: function (component, event, helper) {
    if (
      !$A.util.isUndefinedOrNull(component.get("v.currentlyEditing")) ||
      !$A.util.isUndefinedOrNull(component.get("v.currentEditingValue"))
    ) {
      const updatedStatuses = Object.assign(
        {},
        component.get("v.updatedPropertyStatuses")
      );
      const propObj = {
        sobjectType: "Property__c",
        Id: component.get("v.currentlyEditing"),
        Status__c: component.get("v.currentEditingValue")
      };
      updatedStatuses[component.get("v.currentlyEditing")] = propObj;
      component.set("v.updatedPropertyStatuses", updatedStatuses);
      helper.resetPropertyStatusSelection(component);
    }
  },
  handleKeyPress: function (component, event, helper) {
    if (
      (event.keyCode == 13 || event.keyCode == 27) &&
      !$A.util.isUndefinedOrNull(component.get("v.currentEditingValue")) &&
      !$A.util.isUndefinedOrNull(component.get("v.currentlyEditing"))
    ) {
      const updatedStatuses = Object.assign(
        {},
        component.get("v.updatedPropertyStatuses")
      );
      const propObj = {
        sobjectType: "Property__c",
        Id: component.get("v.currentlyEditing"),
        Status__c: component.get("v.currentEditingValue")
      };
      updatedStatuses[component.get("v.currentlyEditing")] = propObj;
      component.set("v.updatedPropertyStatuses", updatedStatuses);
      helper.resetPropertyStatusSelection(component);
    }
  },
  handleStatusButtonsClick: function (component, event, helper) {
    if (event.getSource().get("v.title") == "update") {
      if (
        !$A.util.isUndefinedOrNull(component.get("v.currentlyEditing")) ||
        !$A.util.isUndefinedOrNull(component.get("v.currentEditingValue"))
      ) {
        const updatedStatuses = Object.assign(
          {},
          component.get("v.updatedPropertyStatuses")
        );
        const propObj = {
          sobjectType: "Property__c",
          Id: component.get("v.currentlyEditing"),
          Status__c: component.get("v.currentEditingValue")
        };
        updatedStatuses[component.get("v.currentlyEditing")] = propObj;
        component.set("v.updatedPropertyStatuses", updatedStatuses);
      }
      helper.updatePropertyStatuses(component, helper);
    } else {
      helper.resetPropertyStatusSelection(component);
      helper.clearUpdatedPropertyStatuses(component);
      $A.get("e.force:refreshView").fire();
    }
  },
  toggleStatusEdit: function (component, event, helper) {
    event.preventDefault();
    event.stopPropagation();
    const propertyDetails = JSON.parse(
      JSON.stringify(event.getSource().get("v.value"))
    );
    if (component.get("v.currentlyEditing") != propertyDetails.Id) {
      component.set("v.currentlyEditing", propertyDetails.Id);
      component.set("v.currentEditingValue", propertyDetails.Status__c);
      if (!component.get("v.isEditButtonClicked")) {
        component.set("v.isEditButtonClicked", true);
      }
    } else {
      const updatedStatuses = Object.assign(
        {},
        component.get("v.updatedPropertyStatuses")
      );
      const propObj = {
        sobjectType: "Property__c",
        Id: component.get("v.currentlyEditing"),
        Status__c: component.get("v.currentEditingValue")
      };
      updatedStatuses[component.get("v.currentlyEditing")] = propObj;
      component.set("v.updatedPropertyStatuses", updatedStatuses);
      helper.resetPropertyStatusSelection(component);
    }
  },

  handleStatusSelect: function (component, event, helper) {
    if (component.get("v.currentlyEditing") != null) {
      component.set("v.currentEditingValue", event.getParam("value"));
    }
  },

  calculateSubTotals: function (component, event, helper) {
    let inspectionFeeSubtotal = 0;
    let servicingFeeSubtotal = 0;

    component.get("v.propertyAdvances").forEach((pAdv) => {
      inspectionFeeSubtotal += !$A.util.isUndefinedOrNull(
        parseFloat(pAdv.Inspection_Fee__c)
      )
        ? pAdv.Inspection_Fee__c
        : 0;
      servicingFeeSubtotal += !$A.util.isUndefinedOrNull(
        parseFloat(pAdv.Servicing_Fee__c)
      )
        ? pAdv.Servicing_Fee__c
        : 0;
    });

    let record = component.get("v.record");
    console.log("appraisal fee netted", record.Appraisal_Fee_Netted__c);
    let appraisalFee = record.BPO_Appraisal_Fee_Subtotal__c;
    let reportFees = record.Report_Fee_Subtotal__c;
    if (!record.Appraisal_Fee_Netted__c) {
      appraisalFee = 0;
    }
    if (!record.Report_Fees_Netted__c) {
      reportFees = 0;
    }
    record.Inspection_Fee_Subtotal__c = inspectionFeeSubtotal;
    record.Servicing_Fee_Subtotal__c = servicingFeeSubtotal;
    record.Net_Funding_Subtotal__c =
      record.Approved_Advance_Amount_Total__c -
      (record.Origination_Fee_Subtotal__c +
        record.Advance_Fee_Subtotal__c +
        appraisalFee +
        record.Doc_Prep_Fee_Subtotal__c +
        record.BlackSquare_Fee_Total__c +
        record.Daily_Interest_Rate_Subtotal__c +
        record.Inspection_Fee_Subtotal__c +
        record.Servicing_Fee_Subtotal__c +
        record.Wire_Fee_Subtotal__c +
        reportFees);
    console.log("net funding subtotal", record.Net_Funding_Subtotal__c);
    component.set("v.record", record);
  },

  handleNetted: function (component, event, helper) {
    let record = component.get("v.record");
    let propAdvances = component.get("v.propertyAdvances");
    let dataName = event.getSource().get("v.name");
    console.log("data name", dataName);

    if (dataName === "appraisalFee") {
      if (record.Appraisal_Fee_Netted__c) {
        record.Net_Funding_Subtotal__c =
          record.Net_Funding_Subtotal__c - record.BPO_Appraisal_Fee_Subtotal__c;
        propAdvances.forEach((pAdv) => {
          pAdv.Net_Funding__c = pAdv.Net_Funding__c - pAdv.BPO_Appraisal_Fee__c;
        });
      } else {
        record.Net_Funding_Subtotal__c =
          record.Net_Funding_Subtotal__c + record.BPO_Appraisal_Fee_Subtotal__c;
        propAdvances.forEach((pAdv) => {
          pAdv.Net_Funding__c = pAdv.Net_Funding__c + pAdv.BPO_Appraisal_Fee__c;
        });
      }
    } else if (dataName === "reportFees") {
      if (record.Report_Fees_Netted__c) {
        record.Net_Funding_Subtotal__c =
          record.Net_Funding_Subtotal__c - record.Report_Fee_Subtotal__c;
        propAdvances.forEach((pAdv) => {
          pAdv.Net_Funding__c = pAdv.Net_Funding__c - pAdv.Report_Fee_Total__c;
        });
      } else {
        record.Net_Funding_Subtotal__c =
          record.Net_Funding_Subtotal__c + record.Report_Fee_Subtotal__c;
        propAdvances.forEach((pAdv) => {
          pAdv.Net_Funding__c = pAdv.Net_Funding__c + pAdv.Report_Fee_Total__c;
        });
      }
    }
    component.set("v.record", record);
    component.set("v.propertyAdvances", propAdvances);
  },

  handlePropAdvChange: function (component, event, helper) {
    let propAdvances = component.get("v.updatedPropAdvances") || [];
    const evSource = event.getSource();
    const currId = evSource.get("v.title");
    let propAdvancesRecord = component.get("v.propertyAdvances");
    const propAdvRecord = propAdvancesRecord.find((padv) => padv.Id == currId);
    let val = evSource.get("v.value");
    val = isNaN(val) || !val ? 0 : val;
    const keyName = evSource.get("v.name");
    if (keyName == "Holdback_To_Rehab_Ratio__c") {
      component.set("v.isHoldbackToRehabChanged", true);
    }
    if (
      keyName == "Approved_Amount__c" &&
      propAdvRecord.hasOwnProperty("Holdback_To_Rehab_Ratio__c")
    ) {
      propAdvRecord.Renovation_Reserve__c = parseFloat(
        (val * (propAdvRecord.Holdback_To_Rehab_Ratio__c / 100)).toFixed(2)
      );
      if (component.get("v.record").Status__c == "Completed") {
        let renovAdvanceUsed = propAdvRecord.Renovation_Reserve__c;
        propAdvancesRecord.forEach((padv) => {
          if (padv.Id != currId && padv.Advance__r.Status == "Completed") {
            renovAdvanceUsed += isNaN(padv.Renovation_Reserve__c)
              ? 0
              : padv.Renovation_Reserve__c;
          }
        });

        propAdvRecord.Property__r.Reno_Advance_Amount_Remaining__c =
          propAdvRecord.Approved_Renovation_Holdback__c - renovAdvanceUsed;
      }

      const advRecord = component.get("v.record");
      let renovTotal = 0;
      propAdvancesRecord = propAdvancesRecord.map((padv) => {
        if (padv.Id == currId) {
          renovTotal += propAdvRecord.Renovation_Reserve__c;
          return propAdvRecord;
        } else {
          renovTotal += padv.Renovation_Reserve__c;
          return padv;
        }
      });
      advRecord.Renovation_Reserve_Total__c = renovTotal;
      component.set("v.record", advRecord);
      component.set("v.propertyAdvances", propAdvancesRecord);
    }

    const updatedRec = {
      [keyName]: val,
      Id: currId
    };
    let propAdv = propAdvances.find((pAdv) => pAdv.Id == currId);
    if (propAdv != null && propAdv.hasOwnProperty("Id")) {
      propAdv = Object.assign(propAdv, updatedRec);
    } else {
      propAdv = updatedRec;
    }
    propAdvancesRecord = propAdvancesRecord.map((padv) => {
      if (padv.Id == currId) {
        return Object.assign(padv, updatedRec);
      } else {
        return padv;
      }
    });
    component.set("v.propertyAdvances", propAdvancesRecord);
    propAdvances = propAdvances.filter((pAdv) => pAdv.Id != currId);
    propAdvances.push(propAdv);
    component.set("v.updatedPropAdvances", propAdvances);
    console.log("propAdvances", propAdvances);
    helper.calculatePropAdvTotals(component);
  },

  saveRecord: function (component, event, helper) {
    $A.util.toggleClass(component.find("spinner"), "slds-hide");
    component.find("save").set("v.disabled", true);
    console.log(component.get("v.record"));
    var record = component.get("v.record");

    var upsertRecord = {
      Advance_Fee_Adjustment__c: record["Advance_Fee_Adjustment__c"],
      Origination_Fee_Adjustment__c: record["Origination_Fee_Adjustment__c"],
      Daily_Interest_Rate_Adjustment__c:
        record["Daily_Interest_Rate_Adjustment__c"],
      BPO_Appraisal_Fee_Adjustment__c:
        record["BPO_Appraisal_Fee_Adjustment__c"],
      Doc_Prep_Fee_Adjustment__c: record["Doc_Prep_Fee_Adjustment__c"],
      sobjectType: "Advance__c",
      BlackSquare_Fee_Adjustment__c: record["BlackSquare_Fee_Adjustment__c"],
      Inspection_Fee_Adjustment__c: record["Inspection_Fee_Adjustment__c"],
      Servicing_Fee_Adjustment__c: record["Servicing_Fee_Adjustment__c"],
      Wire_Fee_Adjustment__c: record["Wire_Fee_Adjustment__c"],
      Appraisal_Fee_Netted__c: record["Appraisal_Fee_Netted__c"],
      Report_Fees_Netted__c: record["Report_Fees_Netted__c"],
      Id: record["Id"]
    };

    const records = [upsertRecord].concat(component.get("v.propertyAdvances"));
    if (component.get("v.updatedPropAdvances").length > 0) {
      helper.calculatePropAdvTotals(component);
      records.concat(component.get("v.updatedPropAdvances"));
    }

    if (component.get("v.isHoldbackToRehabChanged")) {
      const dealRec = {
        Id: record["Deal__c"],
        Holdback_To_Rehab_Ratio__c: component.get("v.propertyAdvances")[0][
          "Holdback_To_Rehab_Ratio__c"
        ],
        sobjectType: "Opportunity"
      };
      records.push(dealRec);
    }
    console.log(records);
    var action = component.get("c.upsertRecords");
    action.setParams({
      records: records
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        //console.log('success');
        $A.util.toggleClass(component.find("spinner"), "slds-hide");
        helper.queryWires(component);
        $A.get("e.force:refreshView").fire();
        component.find("save").set("v.disabled", false);
        $A.get("e.force:showToast")
          .setParams({
            title: "Success!",
            message: "Advances saved",
            type: "success"
          })
          .fire();
      } else if (state === "ERROR") {
        $A.util.toggleClass(component.find("spinner"), "slds-hide");
        console.log("error");
        console.log(response.getError());
        $A.get("e.force:showToast")
          .setParams({
            title: "Error!",
            message: response.getError(),
            type: "error"
          })
          .fire();
        component.find("save").set("v.disabled", false);
      }
    });

    $A.enqueueAction(action);
  },

  handleClick: function (component, event, helper) {
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: event.getSource().get("v.title")
    });
    navEvt.fire();
  },

  delete: function (component, event, helper) {
    console.log("delete clicked");

    var arr = component.find("checkbox") || [];

    if (!$A.util.isArray(arr)) {
      arr = [arr];
    }

    var records = [];
    arr.forEach(function (row) {
      if (row.get("v.value")) {
        records.push({
          Id: row.get("v.name")
        });
      }
    });

    var action = component.get("c.deleteRecords");
    action.setParams({
      records: records
    });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state == "SUCCESS") {
        console.log("success");
        $A.get("e.force:refreshView").fire();
      } else {
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  refresh: function (component, event, helper) {
    component.find("refresh").set("v.disabled", true);
    var records = component.get("v.propertyAdvances");

    var action = component.get("c.upsertRecords");

    action.setParams({
      records: records
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        //var data = response.getReturnValue();
        //component.set('v.propertyAdvances', records);
        $A.get("e.force:refreshView").fire();
      } else if (state == "ERROR") {
        console.log("error");
      }
    });

    $A.enqueueAction(action);
  }
});
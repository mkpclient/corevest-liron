({
  init: function (component, event, helper) {
    var action = component.get("c.getCurrentUserDetails");
    action.setCallback(this, function (response) {
      if (response.getState() === "SUCCESS") {
        component.set("v.User", response.getReturnValue());
        component.set("v.dealEdit", {});
        helper.fetchDealData(component, event);
        let queryString = "";
        let recordId = component.get("v.recordId");
        let sobjectType = component.get("v.sObjectName");
        queryString = `SELECT Id, Advance_Period__c, StageName, RecordType.DeveloperName, Product_Sub_Type__c,LOC_Loan_Type__c, LOC_Commitment__c `;
        queryString += `FROM Opportunity WHERE Id = '${recordId}'`;

        component.find("util").query(queryString, (result) => {
          let filterFields = {};
          filterFields["StageName"] = result[0].StageName;
          filterFields["RecordType"] = result[0].RecordType.DeveloperName;
          filterFields["ProductSubType"] = result[0].Product_Sub_Type__c;
          filterFields["ProductType"] = result[0].LOC_Loan_Type__c;

          // let loanAmount = result[0].LOC_Commitment__c ? Number(result[0].LOC_Commitment__c).toLocaleString(undefined, { maximumFractionDigits: 2 }) : "0";
          // loanAmount = "$" + String(loanAmount).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
          // const dealEdit = component.get("v.dealEdit");
          // dealEdit.outsideAdvanceDate = result[0].Advance_Period__c;
          // component.set("v.dealEdit", dealEdit);
          // component.set("v.loanAmount", loanAmount);
          component.set("v.filterFields", filterFields);
        });
      } else if (response.getState() === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  sendEmail: function (component, event, helper) {
    component.set("v.emailAddress", "");

    let hasNullValue = false;
    let borrowerEntity = component.get("v.record.Deal__r.Borrower_Entity__r");
    let requiredKeys = [
      "Name",
      "Company_Jurisdiction__c",
      "Date_of_Cert_of_Good_Standing__c",
      "Entity_Filing_Date__c",
      "Operating_Agreement_Date__c",
      "Business_Tax_ID_EIN__c",
      "Entity_Type__c",
      "Entity_Number__c",
      "Address_1__c",
      "City__c",
      "State__c",
      "Zip__c"
    ];

    if (!borrowerEntity) {
      hasNullValue = true;
    }

    if (!hasNullValue) {
      for (const key of requiredKeys) {
        if (
          !borrowerEntity.hasOwnProperty(key) ||
          borrowerEntity[key] == null
        ) {
          hasNullValue = true;
          break;
        }
      }
    }

    if (hasNullValue) {
      component.set("v.showNullFieldsModal", true);
    } else {
      component.set("v.showAskEmailAddressModal", true);
    }
  },
  validateEmail: function (cmp, event) {
    const emailsString = event.getSource().get("v.value");
    // var regExpEmailformat = "^[^.][a-zA-Z0-9!#$%&'*/=?^_+-`{|}~]*@[a-zA-Z0-9-]+\.[a-z]{2,}$";
    const regExpEmailformat = "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"; // changed to accept email addresses with additional domain level past .com/org/etc
    event.getSource().setCustomValidity("");
    if (!$A.util.isEmpty(emailsString)) {
      const emails = emailsString.split(";");
      for (const email of emails) {
        if (!email.match(regExpEmailformat)) {
          event
            .getSource()
            .setCustomValidity(email + " is not a valid email address.");
          break;
        }
      }
    }
    event.getSource().reportValidity();
  },

  hideAskEmailAddressModal: function (component, event, helper) {
    component.set("v.showAskEmailAddressModal", false);
    if (
      !$A.util.isEmpty(component.get("v.fileIds")) &&
      !$A.util.isUndefined(component.get("v.fileIds")) &&
      component.get("v.fileIds").length > 0
    ) {
      helper.removeAttchedFile(component, event, helper, null);
    }
  },

  hideNullValuesModal: function (component, event, helper) {
    component.set("v.showNullFieldsModal", false);
  },

  goToBorrowerEntity: function (component, event, helper) {
    const navEvt = $A.get("e.force:navigateToSObject");

    navEvt.setParams({
      recordId: component.get("v.record.Deal__r.Borrower_Entity__c")
    });
    navEvt.fire();
  },

  handleSuccessBorrowerEntityEdit: function (component, event, helper) {
    helper.fetchDealData(component, event);
    component.set("v.showNullFieldsModal", false);
    component.set("v.showAskEmailAddressModal", true);
  },

  sendEmailWithAttach: function (cmp, event, helper) {
    if (cmp.get("v.emailAddress")) {
      cmp.set("v.isSendEmail", true);
      let val = "docx-Bridge_Intake_Form.docx";

      if (!$A.util.isEmpty(val)) {
        helper.generateDocx(cmp, val.substring(5));
      }
    } else {
      alert("Please enter a valid Email.");
    }
  },
  handleClickPreview: function (component, event, helper) {
    component.set("v.isSendEmail", false);
    let val = "docx-Bridge_Intake_Form.docx";

    if (!$A.util.isEmpty(val)) {
      helper.generateDocx(component, val.substring(5));
    }
  },

  cancel: function (component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  },
  handleUploadFinished: function (cmp, event) {
    // Get the list of uploaded files
    var fileIds = cmp.get("v.fileIds");
    if (!fileIds) {
      fileIds = [];
    }
    var uploadedFiles = event.getParam("files");
    uploadedFiles.forEach(function (item) {
      fileIds.push({
        name: item.name,
        documentId: item.documentId
      });
    });
    cmp.set("v.fileIds", fileIds);
  },
  updateRenovationFundingType: function (component, event, helper) {
    if (
      event.getSource().get("v.value") == "Yes" &&
      component.get("v.record.Deal__r.Reno_Funding_Type__c")
    ) {
      component.set(
        "v.dealEdit.renovationFunding",
        component.get("v.record.Deal__r.Reno_Funding_Type__c")
      );
    } else {
      component.set("v.dealEdit.renovationFunding", "N/A");
    }
  },
  closeSendEmailModal: function (component, event, helper) {
    component.set("v.showAskEmailAddressModal", false);
  },
  deleteSelectedFile: function (component, event, helper) {
    helper.removeAttchedFile(
      component,
      event,
      helper,
      event.getSource().get("v.name")
    );
  },
  handleDeleteItem: function (component, event, helper) {
    helper.handleDeleteItem(component, event);
  },
  handleChangeInterestRateType: function (component, event, helper) {
    helper.handleChangeInterestRateType(component, event);
  }
});
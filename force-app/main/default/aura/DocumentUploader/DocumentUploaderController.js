({
  init: function (component, event, helper) {
    if ($A.util.isUndefinedOrNull(component.get("v.picklistMap"))) {
      helper.queryPicklists(component);
    } else {
      let sections = [""];
      for (let x in component.get("v.picklistMap")) {
        sections.push(x);
      }
      component.set("v.sections", sections);
    }

    helper.queryValidations(component);
    // console.log('--test--');

    // helper.queryAttachments(component);
  },

  picklistChange: function (component, event, helper) {
    var target = event.getSource();

    var rowString = target.get("v.class");
    console.log(rowString);
    if (rowString == "bulk") {
      var typeOptions =
        component.get("v.picklistMap")[component.get("v.section")];

      console.log(typeOptions);

      component.set("v.documentTypes", typeOptions);

      var files = component.get("v.files");

      files.forEach(function (file) {
        file.section = component.get("v.section");

        file.requireValidations = false;
        file.documentType = "";
        file.typeOptions = typeOptions;
      });
      console.log(files[row]);
      component.set("v.files", files);
    } else {
      var row = rowString.split("-")[1];

      var files = component.get("v.files");
      //console.log(files[row]);

      files[row].typeOptions =
        component.get("v.picklistMap")[files[row].section];

      //console.log(files[row].typeOptions.indexOf(files[row].documentType));

      //if(files[row].typeOptions.indexOf(files[row].documentType) == -1){
      files[row].documentType = "";
      files[row].requireValidations = false;
      //}
      console.log(files[row]);
      component.set("v.files", files);
    }
  },

  saveFiles: function (component, event, helper) {
    var promises = [];

    var files = component.get("v.files");
    let close = $A.get("e.force:closeQuickAction");

    helper.saveFilesPromise(component, helper, files).then(function () {
      console.log("all done");
      let savedCount = 0;

      files = component.get("v.files");

      let requireValidations = false;
      let fileForValidation = {};
      files.forEach((file) => {
        // let savedCount = 0;
        if (file.status == "success") {
          savedCount++;
        }

        if (file.documentType == "Insurance Review Data Tape") {
          component.set("v.contentVersionId", file.contentVersionId);
          helper.convertToJson(component, helper);
        }

        if (file.requireValidations) {
          requireValidations = true;
          fileForValidation = file;
        }
      });

      console.log(files);

      if (requireValidations) {
        console.log("fire validation event here");

        let payload = {
          recordId: component.get("v.recordId"),
          sobjectType: component.get("v.sobjectType"),
          file: fileForValidation
        };
        // $A.get("e.force:closeQuickAction").fire();
        // let close = $A.get("e.force:closeQuickAction");
        close.fire();

        // var element = document.getElementsByClassName(
        //   "DESKTOP uiModal forceModal"
        // );
        // element.forEach(function (e, t) {
        //   $A.util.addClass(e, "slds-hide");
        // });
        component.find("validator").publish(payload);

        // close.fire();
        // $A.get("e.force:closeQuickAction").fire();
      } else if (files.length > 0 && savedCount == files.length) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success!",
          type: "success",
          message: files.length + " files saved."
        });
        toastEvent.fire();

        $A.get("e.force:closeQuickAction").fire();
      }
    });
  },

  deleteAttachment: function (component, event, helper) {
    console.log("delete");
    console.log(event.getSource().get("v.value"));

    var rowIndex = event.getSource().get("v.value");

    var files = component.get("v.files");

    var toDelete = files.splice(rowIndex, 1);
    var attachments = [];
    for (var i = 0; i < toDelete.length; i++) {
      var attachment = {
        Id: toDelete[i].attachmentId,
        sobjectType: "Attachment"
      };

      attachments.push(attachment);
    }
    console.log(component);

    var action = component.get("c.deleteRecords");

    action.setParams({ records: attachments });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        console.log("delete success");
        component.set("v.files", files);
      } else if (state === "ERROR") {
        console.log("delete errors");
      }
    });

    $A.enqueueAction(action);
  },

  documentTypeChange: function (component, event, helper) {
    var documentType = component.get("v.documentType");
    var docTypes = component.get("v.documentTypes");
    var section = component.get("v.section");

    var files = component.get("v.files");

    files.forEach(function (file) {
      if (file.section != section) {
        file.section = section;
        file.typeOptions = docTypes;
      }

      file.documentType = documentType;
    });

    console.log("--doc type change--");
    console.log(files);

    component.set("v.files", files);
  },

  singleDocTypeChange: function (component, event, helper) {
    var target = event.getSource();
    console.log("single doc type change");
    var rowString = target.get("v.class");
    var row = rowString.split("-")[1];

    var files = component.get("v.files");

    console.log(files[row]);

    const validationMap = component.get("v.validationMap");

    if (validationMap[files[row].section + " | " + files[row].documentType]) {
      //console.log("true");
      files[row].requireValidations = true;
      files[row].docStructureId =
        validationMap[files[row].section + " | " + files[row].documentType];
    } else {
      files[row].requireValidations = false;
    }

    component.set("v.files", files);
  },

  filesChanged: function (component, event, helper) {
    console.log("files changed");
  },

  handleJsonConvert: function (component, event, helper) {
    const sheetData = JSON.parse(event.getParam("fileJson"));
    const fileData = JSON.parse(sheetData.Sheet1).map((d) => {
      let newReturn = {};
      Object.keys(d).forEach((k) => {
        let newKey = k.trim();
        newReturn[newKey] = d[k];
      });
      return newReturn;
    });
    let queryStringProp =
      "SELECT Id, Name FROM Property__c WHERE Deal__r.Deal_Loan_Number__c = '" +
      fileData[0]["Deal Number"] +
      "' AND Name IN ('" +
      fileData.map((d) => d["Street Address"]).join("','") +
      "')";

    let insuranceCompanies = [];

    fileData.forEach((d) => {
      if (!insuranceCompanies.includes(d["Insurance Company"])) {
        insuranceCompanies.push(d["Insurance Company"]);
      }
    });
    let queryStringAcct = "SELECT Id, Name FROM Account WHERE Name ";
    if (insuranceCompanies.length > 1) {
      queryStringAcct += "IN ('" + insuranceCompanies.join("','") + "')";
    } else {
      queryStringAcct += "='" + insuranceCompanies[0] + "'";
    }

    Promise.all([
      component.find("jsonConverter").getRecords(queryStringAcct),
      component.find("jsonConverter").getRecords(queryStringProp)
    ])
      .then(([accs, props]) => {
        let records = [];
        props.forEach((d) => {
          let newVals = fileData.find((fd) => fd["Street Address"] == d.Name);
          let propRecord = {
            Id: d.Id,
            sobjectType: "Property__c",
            Insurance_Company__c: accs.find(a => a.Name == newVals["Insurance Company"]).Id,
            Insurance_Effective_Date__c: newVals["Insurance Effective Date"],
            Insurance_Expiration_Date__c: newVals["Insurance Expiration Date"],
            Insurance_Status__c: "Approved"
          };
          records.push(propRecord);
        });
        component.find("jsonConverter").saveRecords(records);
      })
      .catch((error) => console.error(error));
  }
});

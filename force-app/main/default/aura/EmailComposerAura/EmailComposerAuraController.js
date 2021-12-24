({
  init: function (component, event, helper) {
    // console.log("email init");
    // let params = event.getParam("arguments");
    // console.log(params);
    // console.log(JSON.parse(JSON.stringify(params.defaults)));
    // component.set("v.body", params.defaults.htmlBody);
    // $A.util.addClass(component.find("modal"), "slds-fade-in-open");
    // $A.util.addClass(component.find("backdrop"), "slds-backdrop_open");
    console.log("composer init");
    helper.setEmailOptions(component, event, helper);
  },

  showBCCc: function (component, event, helper) {
    component.set("v.showBCC", true);
  },

  showCCc: function (component, event, helper) {
    component.set("v.showCC", true);
  },

  handleChange: function (component, event, helper) {
    let emails = event.getSource().getElement().emails;
    let fieldName = event.getSource().getLocalId();
    console.log(emails);
    console.log(fieldName);

    // console.log(event);

    component.set(fieldName, emails);
  },

  send: function (component, event, helper) {
    // console.log("sending");
    // console.log(component.get("v.selectedFiles"));

    let fileIds = [];

    if (!$A.util.isEmpty(component.get("v.selectedFiles"))) {
      component.get("v.selectedFiles").forEach((file) => {
        fileIds.push(file.Id);
      });
    }

    let inputs = {
      from: component.get("v.from"),
      to: component.get("v.to"),
      cc: component.get("v.cc"),
      bcc: component.get("v.bcc"),
      body: component.get("v.body"),
      subject: component.get("v.subject"),
      fileIds: fileIds,
      recordId: component.get("v.recordId")
    };

    // console.log(inputs);

    if (
      $A.util.isEmpty(inputs.from) ||
      $A.util.isEmpty(inputs.to) ||
      $A.util.isEmpty(inputs.subject) ||
      $A.util.isEmpty(inputs.body)
    ) {
      console.log("not validated");
    } else {
      console.log("send email");

      let action = component.get("c.SendEmail");
      action.setParams({ inputs: inputs });

      action.setCallback(this, (response) => {
        let state = response.getState();

        if (state === "SUCCESS") {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success!",
            type: "success",
            message: "Email sent"
          });
          toastEvent.fire();

          var params = event.getParam("arguments");
          if (params && params.callback) {
            params.callback();
          } else if (state === "ERROR") {
            console.log(response.getError());
          }
        }
      });

      $A.enqueueAction(action);
    }
  },

  toggleAttachmentModal: function (component, event, helper) {
    if ($A.util.isEmpty(component.get("v.fileColumns"))) {
      helper.setFiles(component);
    }

    $A.util.toggleClass(component.find("attachmentModal"), "slds-fade-in-open");
    $A.util.toggleClass(
      component.find("attachmentModalBackdrop"),
      "slds-backdrop_open"
    );
  },

  uploadFinished: function (component, event, helper) {
    console.log(JSON.parse(JSON.stringify(event)));
    let uploadedFiles = event.getParam("files");
    let filesLength = uploadedFiles.length;

    let queryString =
      "SELECT Id, Title, FileExtension, Owner.Name, LatestPublishedVersionId FROM ContentDocument WHERE Id IN (";

    uploadedFiles.forEach((file) => {
      queryString += `'${file.documentId}',`;
    });

    queryString = queryString.substring(0, queryString.lastIndexOf(",")) + ")";

    component.find("util").query(queryString, (resp) => {
      var selectedFiles = component.get("v.selectedFiles");
      resp.forEach((file) => {
        selectedFiles.push(file);
      });

      component.set("v.selectedFiles", selectedFiles);

      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Success!",
        type: "success",
        message: "Uploaded " + filesLength + " file(s)"
      });
      toastEvent.fire();
    });

    helper.setFiles(component);
  },

  handleRowAction: function (component, event, helper) {
    console.log("row action");

    var action = event.getParam("action");
    var row = event.getParam("row");

    switch (action.name) {
      case "remove":
        // console.log('remove');
        // console.log(JSON.stringify(row));
        var selectedFiles = component.get("v.selectedFiles");
        var rowIndex = selectedFiles.indexOf(row);

        selectedFiles.splice(rowIndex, 1);

        component.set("v.selectedFiles", selectedFiles);

        break;
      default:
        break;
    }
  },

  removeSelected: function (component, event, helper) {
    console.log("remove selected");
    console.log(event);

    let rowIndex = event.getSource().get("v.title");

    var selectedFiles = component.get("v.selectedFiles");

    selectedFiles.splice(rowIndex, 1);

    console.log(selectedFiles);

    component.set("v.selectedFiles", selectedFiles);
  },

  openFilePreview: function (component, event, helper) {
    console.log("open file preview");
    console.log(event);

    let docId = event.target.title;
    $A.get("e.lightning:openFiles").fire({
      recordIds: [docId]
    });
  },

  fileTabSelected: function (component, event, helper) {
    console.log("--file tab selected--");
    var name = event.getParam("name");

    console.log(name);

    if (name === "selected") {
      component.find("selected").set("v.isTrue", true);
      component.find("files").set("v.isTrue", false);
    } else {
      component.find("selected").set("v.isTrue", false);
      component.find("files").set("v.isTrue", true);
    }

    // component.find('ownedItems').set('v.isTrue', );
  },

  addFiles: function (component, event, helper) {
    console.log("add files");

    var fileIds = new Set();
    var selectedFiles = component.get("v.selectedFiles");
    selectedFiles.forEach((file) => {
      fileIds.add(file.Id);
    });

    component
      .find("fileTable")
      .getSelectedRows()
      .forEach((file) => {
        if (!fileIds.has(file.Id)) {
          selectedFiles.push(file);
        }
      });

    component.set("v.selectedFiles", selectedFiles);

    $A.util.toggleClass(component.find("attachmentModal"), "slds-fade-in-open");
    $A.util.toggleClass(
      component.find("attachmentModalBackdrop"),
      "slds-backdrop_open"
    );
  }
});
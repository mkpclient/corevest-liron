({
  init: function(component, event, helper) {
    var url = location.hash;
    if (!$A.util.isEmpty(url) && $A.util.isEmpty(component.get("v.recordId"))) {
      var recordId = location.hash.split("#!")[1].split("?")[0];
      component.set("v.recordId", recordId);
    }

    let wrappers = component.get("v.wrappers");
    //if(component.get('v.paginationEnabled')){
    // let paginationSize = component.get("v.paginationEnabled")
    //   ? Math.max(wrappers.length, component.get("v.paginationSize"))
    //   : wrappers.length;
    // let paginationSize = Math.max(wrappers.length, component.get('v.paginationSize'));//component.get('v.paginationSize');

    var pageSize = component.get("v.paginationEnabled")
      ? component.get("v.pageSize")
      : wrappers.length;
    var currentPage = component.get("v.currentPage");

    component.set("v.maxPage", Math.ceil(wrappers.length / pageSize));

    let selectedWrappers = wrappers.slice(
      (currentPage - 1) * pageSize,
      currentPage * pageSize
    );

    console.log("--selected wrappers--");
    console.log(selectedWrappers);

    component.set("v.selectedWrappers", selectedWrappers);

    //if(pagignationSize > )

    // }else{

    // }

    // component.set("v.selectedWrappers", selectedWrappers);

    // let action = component.get("c.initScreen");

    // action.setParams({ recordId: component.get("v.recordId") });
    // action.setCallback(this, response => {
    //   let state = response.getState();
    //   if (state === "SUCCESS") {
    //     console.log(JSON.parse(response.getReturnValue()));
    //     let resp = JSON.parse(response.getReturnValue());
    //     component.set("v.wrappers", resp.wrappers);
    //   } else if (state === "ERROR") {
    //     console.log("--error--");
    //     console.log(response.getError());
    //   }
    // });

    // $A.enqueueAction(action);
  },
  handleUpload: function(component, event, helper) {
    //console.log(event.getSource().get('v.title'));
    //console.log(event.getSource())
    //console.log(JSON.parse(JSON.stringify(event.getParams())));

    let docIds = [];
    event.getParam("files").forEach(file => docIds.push(file.documentId));

    //console.log(docIds);

    let action = component.get("c.createDealDocs");

    action.setParams({
      recordId: component.get("v.recordId"),
      docIds: docIds,
      docString: event.getSource().get("v.title"),
      propertyId: event.getSource().get("v.name")
    });

    action.setCallback(this, function(response) {
      let state = response.getState();

      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success!",
          message: docIds.length + " file(s) uploaded successfully",
          type: "success"
        });
        toastEvent.fire();
      } else if (state === "ERROR") {
        console.log("error");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  viewFile: function(component, event, helper) {
    //let fileId = event.getSource().get('v.title');
    //console.log(event.target.source);
    let fileId = event.target.title;
    console.log(fileId);
    $A.get("e.lightning:openFiles").fire({
      recordIds: [fileId]
    });
  },

  viewFiles: function(component, event, helper) {
    let docId = event.target.title;
    component.set("v.selectedDocIdList", docId);

    console.log(docId);

    let action = component.get("c.getFiles");

    action.setParams({
      dealId: component.get("v.recordId"),
      docInfoId: docId
    });

    action.setCallback(this, response => {
      let state = response.getState();

      if (state === "SUCCESS") {
        $A.util.toggleClass(component.find("listSpinner"), "slds-hide");
        let docs = JSON.parse(response.getReturnValue());
        //console.log(docs);

        docs.forEach((doc, index) => {
          doc.checked = false;
          doc.mostRecent = false;
          if (index === docs.length - 1) {
            doc.mostRecent = true;
          }
        });

        component.set("v.documentList", docs);
      } else if (state === "ERROR") {
        console.log("error");

        console.log(resposne.getError());
      }
    });

    $A.enqueueAction(action);
  },

  openEditModal: function(component, event, helper) {
    let docInfoId = event.getParam("value");

    let wrappers = component.get("v.wrappers");
    let docInfo = { sobjectType: "Document_Information__c", Id: docInfoId };
    wrappers.forEach(wrapper => {
      wrapper.documentWrappers.forEach(doc => {
        if (doc.docInfoId == docInfoId) {
          docInfo.External_Comments__c = doc.comments;
          docInfo.Required_for_Borrower_Checklist__c = doc.includeInChecklist;
        }
      });
    });

    component.set("v.docInfo", docInfo);
    // component.set('v.docComments', comments);
    // component.set(' v.includeInChecklist', includeInChecklist);

    component.set("v.selectedDocId", docInfoId);
  },

  closeEditModal: function(component, event, helper) {
    component.set("v.selectedDocId", null);
  },

  closeEditModalList: function(component, event, helper) {
    component.set("v.selectedDocIdList", null);
  },

  save: function(component, event, helper) {
    component
      .find("edit")
      .get("e.recordSave")
      .fire();
  },

  handleSaveSuccess: function(component, event, helper) {
    component.set("v.selectedDocId", null);
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "Success!",
      message: "Document updated succesfully",
      type: "success"
    });
    toastEvent.fire();
  },

  nextPage: function(component, event, helper) {
    var records = component.get("v.wrappers");
    var currentPage = component.get("v.currentPage") + 1;
    var pageSize = component.get("v.pageSize");

    // var table = component.find("dataTable");

    var recordsToDisplay = records.slice(
      (currentPage - 1) * pageSize,
      currentPage * pageSize
    );

    //table.set("v.rows", recordsToDisplay);
    component.set("v.selectedWrappers", recordsToDisplay);

    component.set("v.currentPage", currentPage);
  },

  prevPage: function(component, event, helper) {
    var records = component.get("v.wrappers");
    var currentPage = component.get("v.currentPage") - 1;
    var pageSize = component.get("v.pageSize");

    // var table = component.find("dataTable");
    var recordsToDisplay = records.slice(
      (currentPage - 1) * pageSize,
      currentPage * pageSize
    );
    //table.set("v.rows", recordsToDisplay);
    component.set("v.selectedWrappers", recordsToDisplay);
    component.set("v.currentPage", currentPage);
  },

  lastPage: function(component, event, helper) {
    var records = component.get("v.wrappers");
    var currentPage = component.get("v.maxPage");
    var pageSize = component.get("v.pageSize");

    var table = component.find("dataTable");
    var recordsToDisplay = records.slice(
      (currentPage - 1) * pageSize,
      currentPage * pageSize
    );
    //table.set("v.rows", recordsToDisplay);
    component.set("v.selectedWrappers", recordsToDisplay);
    component.set("v.currentPage", currentPage);
  },

  firstPage: function(component, event, helper) {
    var records = component.get("v.wrappers");
    var currentPage = 1;
    var pageSize = component.get("v.pageSize");

    //var table = component.find("dataTable");
    var recordsToDisplay = records.slice(
      (currentPage - 1) * pageSize,
      currentPage * pageSize
    );
    //table.set("v.rows", recordsToDisplay);
    component.set("v.selectedWrappers", recordsToDisplay);
    component.set("v.currentPage", currentPage);
  },

  review: function(component, event, helper) {
    console.log("review");
    component.find("reviewBtn").set("v.disabled", true);
    let docs = component.get("v.documentList");
    let docIds = [];
    let mostRecent = false;
    docs.forEach(doc => {
      if (doc.checked && $A.util.isEmpty(doc.Reviewed_On__c)) {
        docIds.push(doc.Id);

        if (doc.mostRecent) {
          mostRecent = true;
        }
      }
    });

    console.log(docIds);
    console.log(mostRecent);

    if (docIds.length > 0) {
      // do stuff
      $A.util.toggleClass(component.find("listSpinner"), "slds-hide");
      let action = component.get("c.reviewDocuments");
      action.setParams({ docIds: docIds });

      action.setCallback(this, response => {
        let state = action.getState();
        if (state === "SUCCESS") {
          let updatedDocs = JSON.parse(response.getReturnValue());
          console.log(updatedDocs);
          updatedDocs.forEach(updatedDoc => {
            docs.forEach(doc => {
              if (doc.Id === updatedDoc.Id) {
                doc.Reviewed_On__c = updatedDoc.Reviewed_On__c;
                doc.Reviewed_By__c = updatedDoc.Reviewed_By__c;
                doc.Reviewed_By__r = { Name: updatedDoc.Reviewed_By__r.Name };
              }
            });

            if (mostRecent) {
              // this.init();
            }
          });

          if (mostRecent) {
            //

            let selectedWrappers = component.get("v.selectedWrappers");

            selectedWrappers.forEach(wrapper => {
              wrapper.documentWrappers &&
                wrapper.documentWrappers.forEach(doc => {
                  if (doc.docInfoId == component.get("v.selectedDocIdList")) {
                    doc.reviewedOn = $A.localizationService.formatDate(
                      new Date(),
                      "YYYY-MM-DD"
                    );
                  }
                });
            });

            component.set("v.selectedWrappers", selectedWrappers);
            $A.enqueueAction(component.get("v.initAction"));
          // $A.enqueueAction(component.get("c.initAction"));
          }

          component.set("v.documentList", docs);
          component.find("reviewBtn").set("v.disabled", false);
          $A.util.toggleClass(component.find("listSpinner"), "slds-hide");
        } else if (state === "ERROR") {
          $A.util.toggleClass(component.find("listSpinner"), "slds-hide");
          console.log("error");
          component.find("reviewBtn").set("v.disabled", false);
        }
      });

      $A.enqueueAction(action);
    } else {
      component.find("reviewBtn").set("v.disabled", false);
    }
  },
  
});
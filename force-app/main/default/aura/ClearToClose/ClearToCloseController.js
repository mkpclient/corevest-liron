({
  init: function (component, event, helper) {
    // var queryString = 'SELECT Id, Label, Section_Order__c,'
    // queryString += ' (SELECT Id, Document_Type__c, Folder_Structure_String__c FROM Document_Structures__r)';
    // queryString +=' FROM Clear_To_Close__mdt Order By Section_Order__c Asc';

    // component.find('util').query(queryString, data => {
    // 	console.log(data);
    // 	component.set('v.settings', data);
    // });

    var action = component.get("c.compileClearToCloseTabData");

    action.setParams({
      opportunityId: component.get("v.recordId")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state == "SUCCESS") {
        var data = JSON.parse(response.getReturnValue());
        //console.log('--response data--');
        console.log(data);

        let sections = [];

        data.settings.forEach(function (setting) {
          if (!$A.util.isUndefinedOrNull(setting.Document_Structures__r)) {
            setting.Document_Structures__r.forEach(function (record) {
              //console.log(record);
              var key =
                record.Folder_Structure_String__c +
                "|" +
                record.Document_Type__c;

              // console.log(key);
              // console.log(record);
              // console.log(data.wrapper.docMap);

              if (data["wrapper"]["docMap"][key]) {
                record["loaded"] =
                  data["wrapper"]["docMap"][key].documentLoaded; //data["wrapper"]["docMap"][key][0];
                record["reviewed"] =
                  data["wrapper"]["docMap"][key].documentReviewed; //data["wrapper"]["docMap"][key][1];
                record["required"] = data["wrapper"]["docMap"][key].required; //data["wrapper"]["docMap"][key][2];
                record["docId"] = data["wrapper"]["docMap"][key].docId; //data["wrapper"]["docMap"][key][3];
                record["comments"] =
                  data["wrapper"]["docMap"][key].internalComments; //data["wrapper"]["docMap"][key][4];
                record["docInfoId"] = data["wrapper"]["docMap"][key].docInfoId;
                record["documentCount"] =
                  data["wrapper"]["docMap"][key].documentCount;
              } else {
                console.log(key);
              }
            });
          }

          if (
            sections.length == 0 ||
            sections[sections.length - 1].headerName != setting.Header_Name__c
          ) {
            sections.push({ headerName: setting.Header_Name__c, settings: [] });
          }
          sections[sections.length - 1].settings.push(setting);
        });

        sections.forEach((section) => {
          section.settings.forEach((setting) => {
            console.log(setting);
            setting.Document_Structures__r.records = setting.Document_Structures__r.sort(
              (a, b) => {
                let v1 = a.C2C_Sort__c;
                let v2 = b.C2C_Sort__c;
                if (v1 < v2) return -1;
                if (v1 > v2) return 1;
                return 0;
              }
            );
          });
        });

        //console.log(console.log('v.'));
        console.log(sections);
        console.log(data.settings);

        // component.set("v.settings", data.settings);
        component.set("v.sections", sections);
        console.log("--sections--", sections);
        component.set("v.clearToClose", data.wrapper.clearToClose);
      } else if (state == "ERROR") {
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  viewFile: function (component, event, helper) {
    //let fileId = event.getSource().get('v.title');
    //console.log(event.target.source);
    let fileId = event.target.title;
    console.log(fileId);
    $A.get("e.lightning:openFiles").fire({
      recordIds: [fileId]
    });
  },

  viewFiles: function (component, event, helper) {
    let docId = event.target.id;
    component.set("v.selectedDocIdList", docId);

    console.log(docId);

    let action = component.get("c.getFiles");

    action.setParams({
      dealId: component.get("v.recordId"),
      docInfoId: docId
    });

    action.setCallback(this, (response) => {
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

  toggleSection: function (component, event, helper) {
    // var id = event.target.getAttribute("data-id");
    // var sectionId = event.target.getAttribute('data-sectionIndex');
    // console.log(id);

    let name = event.target.getAttribute("data-name");

    component.find("sections").forEach((section) => {
      // console.log(section.getElement().getAttribute("data-name"));
      // console.log(section);
      // conso;

      if (name === section.getElement().getAttribute("data-name")) {
        $A.util.toggleClass(section, "slds-is-open");
      }
    });

    component.find("sections-icon").forEach((icon) => {
      if (name === icon.get("v.title")) {
        $A.util.toggleClass(icon, "slds-accordion__summary-action-icon");
      }
    });

    //
    // $A.util.toggleClass(
    //   component.find("sections-icon")[id],
    //   "slds-accordion__summary-action-icon"
    // );
  },

  openEditModal: function (component, event, helper) {
    let docInfoId = event.getParam("value");

    console.log(docInfoId);

    // wrappers.forEach(wrapper => {
    //   wrapper.documentWrappers.forEach(doc => {
    //     if(doc.docInfoId == docInfoId){
    //       docInfo.External_Comments__c = doc.comments;
    //       docInfo.Required_for_Borrower_Checklist__c = doc.includeInChecklist;
    //     }
    //   })
    // });

    // component.set('v.docComments', comments);
    // component.set(' v.includeInChecklist', includeInChecklist);

    component.set("v.selectedDocId", docInfoId);
  },

  closeEditModal: function (component, event, helper) {
    component.set("v.selectedDocId", null);
  },

  save: function (component, event, helper) {
    component.find("edit").get("e.recordSave").fire();
  },

  handleSaveSuccess: function (component, event, helper) {
    component.set("v.selectedDocId", null);
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "Success!",
      message: "Document updated succesfully",
      type: "success"
    });
    toastEvent.fire();
  },

  closeEditModalList: function (component, event, helper) {
    component.set("v.selectedDocIdList", null);
  },

  review: function (component, event, helper) {
    console.log("review");
    component.find("reviewBtn").set("v.disabled", true);
    let docs = component.get("v.documentList");
    let docIds = [];
    let mostRecent = false;
    docs.forEach((doc) => {
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

      let that = this;
      action.setCallback(this, (response) => {
        let state = action.getState();
        if (state === "SUCCESS") {
          let updatedDocs = JSON.parse(response.getReturnValue());
          console.log(updatedDocs);
          updatedDocs.forEach((updatedDoc) => {
            docs.forEach((doc) => {
              if (doc.Id === updatedDoc.Id) {
                doc.Reviewed_On__c = updatedDoc.Reviewed_On__c;
                doc.Reviewed_By__c = updatedDoc.Reviewed_By__c;
                doc.Reviewed_By__r = { Name: updatedDoc.Reviewed_By__r.Name };
                // doc.Reviewed_By__r.Name = updatedDoc.Reviewed_By__r.Name;
              }
            });

            // if (mostRecent) {
            //   // this.init();
            // }
          });

          if (mostRecent) {
            $A.enqueueAction(component.get("c.init"));
            //that.init();
            // let sections = component.get("v.sections");
            // let docInfoId = component.get("v.selectedDocIdList");
            // sections.forEach(section => {
            //   sections.settings.forEach(setting => {
            //     if (setting.docInfoId === docInfoId) {
            //       setting.reviewed = true;
            //     }
            //   });
            // });

            // component.set("v.sections", sections);
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
  }
});
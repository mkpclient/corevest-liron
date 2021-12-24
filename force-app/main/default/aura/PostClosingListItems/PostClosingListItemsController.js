({
  init: function (component, event, helper) {
    //console.log("init");
    // let wrappers = component.get("v.itemWrappers");
    // //if(component.get('v.paginationEnabled')){
    // // let paginationSize = component.get("v.paginationEnabled")
    // //   ? Math.max(wrappers.length, component.get("v.paginationSize"))
    // //   : wrappers.length;
    // // let paginationSize = Math.max(wrappers.length, component.get('v.paginationSize'));//component.get('v.paginationSize');
    // var pageSize = component.get("v.paginationEnabled")
    //   ? component.get("v.pageSize")
    //   : wrappers.length;
    // var currentPage = component.get("v.currentPage");
    // component.set("v.maxPage", Math.ceil(wrappers.length / pageSize));
    // let selectedWrappers = wrappers.slice(
    //   (currentPage - 1) * pageSize,
    //   currentPage * pageSize
    // );
    // //console.log("--selected wrappers--");
    // //console.log(selectedWrappers);
    // component.set("v.selectedItemWrappers", selectedWrappers);
  },

  handleActive: function (component, event, helper) {
    let tab = event.getSource();
    console.log(tab);
    component.set("v.selectedTabId", tab.get("v.id"));
  },

  openEditModal: function (component, event, helper) {
    let itemId = event.getParam("value");

    //let wrappers = component.get("v.itemWrappers");
    //console.log(wrappers);
    //let closingItem = { sobjectType: "Post_Closing_Item__c", Id: itemId };
    // wrappers.forEach((wrapper) => {
    //   wrapper.Post_Closing_Items__r.forEach((item) => {
    //     if (item.Id == itemId) {
    //       closingItem.Status__c = item.Status__c;
    //       closingItem.Uploaded__c = item.Recorded__c;
    //       closingItem.Required__c = item.Required__c;
    //     }
    //   });
    // });

    //component.set("v.selectedItemId", closingItem);
    // component.set('v.docComments', comments);
    // component.set(' v.includeInChecklist', includeInChecklist);

    component.set("v.selectedItemId", itemId);
  },

  save: function (component, event, helper) {
    component.find("edit").get("e.recordSave").fire();
  },

  handleSaveSuccess: function (component, event, helper) {
    component.set("v.selectedItemId", null);
    // var toastEvent = $A.get("e.force:showToast");
    // toastEvent.setParams({
    //   title: "Success!",
    //   message: "Closing Itrem updated succesfully",
    //   type: "success"
    // });
    // toastEvent.fire();

    $A.enqueueAction(component.get("v.initAction"));
  },

  closeEditModal: function (component, event, helper) {
    component.set("v.selectedItemId", null);
  },

  handleUpload: function (component, event, helper) {
    //console.log(event.getSource().get('v.title'));
    //console.log(event.getSource())
    //console.log(JSON.parse(JSON.stringify(event.getParams())));

    let docIds = [];
    event.getParam("files").forEach((file) => docIds.push(file.documentId));

    //console.log(docIds);

    let action = component.get("c.createDealDocs");

    // console.log("docStructureId");
    // console.log(event.getSource().get("v.title"));
    // console.log("itemId");
    // console.log(event.getSource().get("v.name"));

    action.setParams({
      recordId: component.get("v.recordId"),
      docIds: docIds,
      docStructureId: event.getSource().get("v.title"),
      itemId: event.getSource().get("v.name"),
      sobjectType: component.get("v.sObjectName")
    });

    // console.log({
    //   recordId: component.get("v.recordId"),
    //   docIds: docIds,
    //   docStructureId: event.getSource().get("v.title"),
    //   itemId: event.getSource().get("v.name"),
    //   sobjectType: component.get("v.sObjectName")
    // });

    action.setCallback(this, function (response) {
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

  viewFiles: function (component, event, helper) {
    let itemId = event.target.title;
    component.set("v.selectedItemIdList", itemId);

    console.log(itemId);

    // let action = component.get("c.getFiles");

    // action.setParams({
    //   dealId: component.get("v.recordId"),
    //   itemId: itemId
    // });

    // action.setCallback(this, (response) => {
    //   let state = response.getState();

    //   if (state === "SUCCESS") {
    //     $A.util.toggleClass(component.find("listSpinner"), "slds-hide");
    //     let docs = JSON.parse(response.getReturnValue());
    //     //console.log(docs);

    //     docs.forEach((doc, index) => {
    //       doc.checked = false;
    //       doc.mostRecent = false;
    //       if (index === docs.length - 1) {
    //         doc.mostRecent = true;
    //       }
    //     });

    //     component.set("v.documentList", docs);
    //   } else if (state === "ERROR") {
    //     console.log("error");

    //     console.log(resposne.getError());
    //   }
    // });

    // $A.enqueueAction(action);
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

  closeEditModalList: function (component, event, helper) {
    component.set("v.selectedItemIdList", null);
  },

  openNewTaskModal: function (component, event, helper) {
    let itemId = event.target.getAttribute("data-value");

    component.set("v.taskRelatedId", itemId);
  },

  saveTask: function (component, event, helper) {
    const subject = component.find("taskSubject").get("v.value");
    const lookupSelections = component.find("taskLookup").getSelection();
    const activityDate = component.find("taskDueDate").get("v.value");
    const description = component.find("taskComments").get("v.value");
    // component.set("v.taskRelatedId", null);

    console.log(lookupSelections.length > 0);

    if (
      !$A.util.isEmpty(subject) &&
      !$A.util.isEmpty(activityDate) &&
      lookupSelections.length > 0
    ) {
      const task = {
        sobjectType: "Task",
        Subject: subject,
        ActivityDate: activityDate,
        Description: description,
        OwnerId: lookupSelections[0].id,
        RecordTypeId: "0125b000001DmntAAC",
        WhatId: component.get("v.taskRelatedId")
      };

      component.find("util").upsert([task], (results) => {
        component.set("v.taskRelatedId", null);
        $A.enqueueAction(component.get("v.initAction"));
      });

      // console.log(task);
    }
  },

  closeTaskModal: function (component, event, helper) {
    component.set("v.taskRelatedId", null);
  },

  openNewItemModal: function (component, event, helper) {
    let sectionId = event.target.getAttribute("data-value");

    helper.queryItemPicklists(component, sectionId);

    component.set("v.newItemSectionId", sectionId);
  },

  saveNewItem: function (component, event, helper) {
    const docStructId = component.find("newItemDocType").get("v.value");

    // console.log(docStructId);

    if (!$A.util.isEmpty(docStructId)) {
      const docStruct = component.get("v.docStructureMap")[docStructId];

      console.log(component.get("v.itemWrappers"));

      //console.log(docStruct);

      let sectionId = "";

      component.get("v.itemWrappers").forEach((wrapper) => {
        if (component.get("v.newItemSectionId") === wrapper.mdt_Id__c) {
          sectionId = wrapper.Id;
        }
      });

      let item = {
        sobjectType: "Post_Closing_Item__c",
        Post_Closing_Section__c: sectionId,
        mdt_Id__c: docStruct.Id,
        Sort__c: docStruct.Post_Closing_Sort__c,
        Required__c: docStruct.Post_Closing_Required__c,
        Name: docStruct.Document_Type__c
      };

      //console.log(item);

      component.find("util").upsert([item], (response) => {
        component.set("v.newItemSectionId", null);
        component.set("v.docStructureMap", {});
        component.set("v.docStructureOptions", []);
        $A.enqueueAction(component.get("v.initAction"));
      });
    }

    // component.set("v.newItemSectionId", null);
  },

  closeNewItemModal: function (component, event, helper) {
    component.set("v.newItemSectionId", null);
    component.set("v.docStructureMap", {});
    component.set("v.docStructureOptions", []);
  },

  handleEdit: function (component, event, helper) {
    //console.log("handle edit");
    //console.log(event.target);

    const itemId = event.target.getAttribute("data-value");
    //console.log(itemId);
    const wrappers = component.get("v.itemWrappers");
    //console.log(wrappers);
    const closingItem = { sobjectType: "Post_Closing_Item__c", Id: itemId };

    component.set("v.selectedItemId", closingItem);

    component.set("v.selectedItemId", itemId);
  },

  cloneItemC: function (component, event, helper) {
    const itemId = event.target.getAttribute("data-value");
    // console.log(itemId);
    // console.log("clone item");

    const btn = document.querySelector(`[data-name="clone_${itemId}"]`);
    btn.disabled = true;

    const action = component.get("c.cloneItem");

    action.setParams({ itemId: itemId });

    action.setCallback(this, function (response) {
      const state = response.getState();

      if (state === "SUCCESS") {
        $A.enqueueAction(component.get("v.initAction"));
        btn.disabled = false;
      } else {
        console.log(response.getError());
        btn.disabled = false;
      }
    });

    $A.enqueueAction(action);
  },

  deleteItem: function (component, event, helper) {
    const itemId = event.target.getAttribute("data-value");
    //console.log(itemId);
    //console.log("delete item");

    const btn = document.querySelector(`[data-name="clone_${itemId}"]`);
    btn.disabled = true;

    if (confirm("Delete this item?")) {
      console.log("--deleting--");
      btn.disabled = true;

      const record = {
        sobjectType: "Post_Closing_Item__c",
        Id: itemId
      };

      component.find("util").delete([record], (response) => {
        $A.enqueueAction(component.get("v.initAction"));
      });
    } else {
      btn.disabled = false;
    }
  },

  handleTaskSearch: function (component, event, helper) {
    console.log("helper");
    console.log(event.getParam("searchTerm"));

    if (event.getParam("searchTerm")) {
      //let index = event.detail.index;
      //let fieldName = event.detail.name;
      let searchTerm = event.getParam("searchTerm") + "*";
      //console.log("search term");
      //console.log(searchTerm);

      let searchQuery = `FIND '*' IN Name Fields RETURNING `;
      if (event.getParam("searchTerm")) {
        searchQuery = `FIND '${searchTerm}' IN Name Fields RETURNING `;
      }

      searchQuery += `User (Id, Name WHERE IsActive = true AND ContactId = null)`;

      // if (fieldName === "Account__c") {
      //   searchQuery += `Account (Id, Name WHERE RecordType.DeveloperName = 'Vendor' AND Account_Status__c = 'Active CoreVest Vendor')`;
      // } else if (fieldName === "Contact__c") {
      //   let accountId = this.vendors[index].Account__c
      //     ? this.vendors[index].Account__c
      //     : "";
      //   searchQuery += `Contact (Id, Name WHERE AccountId = '${accountId}')`;
      // }

      console.log("searchQuery=", searchQuery);

      const action = component.get("c.search");

      action.setParams({ searchQuery: searchQuery });

      action.setCallback(this, (response) => {
        let state = response.getState();

        if (state === "SUCCESS") {
          let results = response.getReturnValue();
          console.log(results);

          let searchResults = [];
          results[0].forEach((result) => {
            searchResults.push({
              id: result.Id,
              sObjectType: "User",
              icon: "standard:user",
              title: result.Name,
              subtitle: result.Name
            });
          });

          console.log(searchResults);

          // component.find("taskFields").forEach((elm) => {
          // console.log(elm.getElement());
          // });

          component.find("taskLookup").setSearchResults(searchResults);
        } else if (state === "ERROR") {
          console.log("error");
          console.log(results.getError());
        }
      });

      $A.enqueueAction(action);
    }
  },

  review: function (component, event, helper) {
    component.find("documentsList").review();
  }
});
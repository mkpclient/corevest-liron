import { LightningElement, api } from "lwc";
import queryDocumentTypes from "@salesforce/apex/ChecklistController.queryDocumentTypes";
import upsertItem from "@salesforce/apex/ChecklistController.upsertItem";
import upsertItems from "@salesforce/apex/ChecklistController.insertItems";

export default class ChecklistItemNew extends LightningElement {
  sectionId = null;
  itemType = "";
  documentTypes = [];
  sectionIds = [];

  @api milestone;
  @api
  open(sectionId, itemType, sectionIds) {
    // console.log(this.sectionId);
    this.sectionIds = sectionIds;
    this.itemType = itemType;
    if (itemType == "upload") {
      queryDocumentTypes({ sectionId })
        .then((results) => {
          // console.log(results);
          this.documentTypes = results;
          this.sectionId = sectionId;
        })
        .catch((error) => {
          console.log("document types errors");
          console.log(error);
        });
    } else {
      this.sectionId = sectionId;
    }

    console.log("--new --");
    console.log(sectionIds);

    this.template.querySelector("c-modal").openModal();
  }

  get showDocumentTypes() {
    return this.itemType == "upload";
  }

  get showMassSave() {
    return this.sectionIds.length > 0;
  }

  close() {
    this.sectionId = null;
    this.itemType = null;
    this.template.querySelector("c-modal").closeModal();
  }

  saveMass() {
    const items = [];
    this.sectionIds.forEach((sectionId) => {
      items.push({
        sobjectType: "Checklist_Item__c",
        Milestone__c: this.milestone,
        Checklist_Section__c: sectionId
      });
    });

    this.template.querySelectorAll("lightning-input-field").forEach((field) => {
      // console.log(field);
      items.forEach((item) => {
        item[field.fieldName] = field.value;
      });
    });

    // console.log(item);

    if (this.itemType == "upload") {
      const documentType = this.template.querySelector("lightning-combobox")
        .value;

      items.forEach((item) => {
        item.Doc_Structure_Id__c = documentType;
      });
    } else if (this.itemType == "task") {
      const taskType = this.template.querySelector("lightning-input").value;

      items.forEach((item) => {
        item.Uploader__c = taskType;
      });
    }

    //console.log(documentType);
    console.log(items);
    if (
      (this.itemType == "upload" &&
        items[0].Doc_Structure_Id__c &&
        items[0].Name) ||
      (this.itemType == "task" && items[0].Responsible_Party && items[0].Name)
    ) {
      console.log("in the here");
      console.log(this.itemType);
      upsertItems({ items, itemType: this.itemType })
        .then((results) => {
          console.log(results);
          this.dispatchEvent(new CustomEvent("save"));
          this.close();
        })
        .catch((error) => {
          console.log("save item error");
          console.log(error);
        });
    }
  }

  save() {
    const item = {
      sobjectType: "Checklist_Item__c",
      Id: this.section,
      Milestone__c: this.milestone,
      Checklist_Section__c: this.sectionId
    };
    this.template.querySelectorAll("lightning-input-field").forEach((field) => {
      // console.log(field);
      item[field.fieldName] = field.value;
    });

    // console.log(item);

    if (this.itemType == "upload") {
      const documentType = this.template.querySelector("lightning-combobox")
        .value;

      item.Doc_Structure_Id__c = documentType;
    } else if (this.itemType == "task") {
      const taskType = this.template.querySelector("lightning-input").value;
      item.Uploader__c = taskType;
    }

    //console.log(documentType);
    console.log(item);
    if (
      (this.itemType == "upload" && item.Doc_Structure_Id__c && item.Name) ||
      (this.itemType == "task" && item.Uploader__c && item.Name)
    ) {
      upsertItem({ item, itemType: this.itemType })
        .then((results) => {
          console.log(results);
          this.dispatchEvent(new CustomEvent("save"));
          this.close();
        })
        .catch((error) => {
          console.log("save item error");
          console.log(error);
        });
    }
  }
}
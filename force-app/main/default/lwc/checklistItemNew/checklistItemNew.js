import { LightningElement, api } from "lwc";
import queryDocumentTypes from "@salesforce/apex/ChecklistController.queryDocumentTypes";
import upsertItem from "@salesforce/apex/ChecklistController.upsertItem";
export default class ChecklistItemNew extends LightningElement {
  sectionId = null;

  documentTypes = [];
  @api milestone;
  @api
  open(sectionId) {
    // console.log(this.sectionId);

    queryDocumentTypes({ sectionId })
      .then((results) => {
        console.log(results);
        this.documentTypes = results;
        this.sectionId = sectionId;
      })
      .catch((error) => {
        console.log("document types errors");
        console.log(error);
      });
    this.template.querySelector("c-modal").openModal();
  }

  close() {
    this.sectionId = null;
    this.template.querySelector("c-modal").closeModal();
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
    const documentType = this.template.querySelector("lightning-combobox")
      .value;

    item.Doc_Structure_Id__c = documentType;

    //console.log(documentType);
    console.log(item);
    if (item.Doc_Structure_Id__c && item.Name) {
      upsertItem({ item })
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
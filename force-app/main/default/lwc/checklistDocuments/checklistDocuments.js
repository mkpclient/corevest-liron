import { LightningElement, api } from "lwc";
import upsert from "@salesforce/apex/lightning_Controller.upsertRecords";
import query from "@salesforce/apex/lightning_Util.query";
import { NavigationMixin } from "lightning/navigation";
export default class ChecklistDocuments extends NavigationMixin(
  LightningElement
) {
  itemId;
  documents;
  @api openModal(itemId) {
    this.itemId = itemId;
    this.queryDocuments();

    this.template.querySelector("c-modal").openModal();
  }

  handleUpdate(event) {
    const index = event.target.getAttribute("data-index");
    const checked = event.target.checked;

    console.log(index);
    console.log(checked);

    const documents = JSON.parse(JSON.stringify(this.documents));
    documents[index].checked = checked;
    this.documents = documents;
  }

  queryDocuments() {
    let queryString =
      "SELECT Id, File_Name__c, Status__c, Attachment_Id__c, Reviewed_By__r.Name, Reviewed_On__c FROM Deal_Document__c";
    queryString += ` WHERE Checklist_Item__c = '${this.itemId}'`;
    queryString += ` ORDER BY CreatedDate DESC `;

    query({ queryString })
      .then((documents) => {
        this.documents = documents;
      })
      .catch((error) => {
        console.log(error);
        console.log("--error--");
      });
  }

  approveDocuments() {
    //const indexMap = {};

    const hasChecked = false;

    const records = [];
    this.documents.forEach((document, index) => {
      if (document.checked) {
        records.push({
          sobjectType: "Deal_Document__c",
          Reviewed__c: true,
          Status__c: "Approved",
          Id: document.Id
        });
      }
    });

    if (records.length > 0) {
      console.log(records);

      upsert({ records: records })
        .then((results) => {
          this.queryDocuments();
        })
        .catch((error) => {
          console.log(error);
          console.log("--error--");
        });
    }
  }

  rejectDocuments() {
    //const indexMap = {};

    const hasChecked = false;

    const records = [];
    this.documents.forEach((document, index) => {
      if (document.checked) {
        records.push({
          sobjectType: "Deal_Document__c",
          Reviewed__c: true,
          Status__c: "Rejected",
          Id: document.Id
        });
      }
    });

    // console.log(records);

    if (records.length > 0) {
      console.log(records);

      upsert({ records: records })
        .then((results) => {
          this.queryDocuments();
        })
        .catch((error) => {
          console.log(error);
          console.log("--error--");
        });
    }
  }

  openFile(event) {
    const title = event.target.getAttribute("title");

    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "filePreview"
      },
      state: {
        recordIds: title
      }
    });
  }

  closeModal() {
    // this.documents = [];
    this.template.querySelector("c-modal").closeModal();
  }
}
import { LightningElement, api } from "lwc";
import upsert from "@salesforce/apex/lightning_Controller.upsertRecords";
import query from "@salesforce/apex/lightning_Util.query";
import { NavigationMixin } from "lightning/navigation";
export default class ChecklistDocuments extends NavigationMixin(
  LightningElement
) {
  itemId;
  documents = [];
  @api openModal(itemId) {
    this.itemId = itemId;
    this.queryDocuments();

    this.template.querySelector("c-modal").openModal();
  }

  columns = [
    {
      label: "Name",
      fieldName: "File_Name__c",
      type: "button",
      typeAttributes: {
        name: "view",
        title: "View Document",
        label: { fieldName: "File_Name__c" },
        variant: "base"
      },
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Status",
      fieldName: "Status__c",
      type: "texticon",
      wrapText: true,
      hideDefaultActions: true,
      typeAttributes: {
        iconName: { fieldName: "statusIcon" },
        variant: { fieldName: "statusVariant" }
      },
      cellAttributes: {
        class: { fieldName: "statusClass" }
      }
    },
    {
      label: "Added On",
      fieldName: "Added_On__c",
      type: "date",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Reviewed By",
      fieldName: "reviewedBy",
      type: "text",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Reviewed On",
      fieldName: "Reviewed_On__c",
      type: "date",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Approved By",
      fieldName: "approvedBy",
      type: "text",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Approved On",
      fieldName: "Approved_On__c",
      type: "date",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Expiration Date",
      fieldName: "Expiration_Date__c",
      type: "date-local",
      wrapText: true,
      hideDefaultActions: true
    }
    // {
    //   type: "action",
    //   typeAttributes: {
    //     rowActions: [
    //       { label: "View", name: "view" },
    //       { label: "Delete", name: "delete" }
    //     ]
    //   }
    // }
  ];

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
      "SELECT Id, File_Name__c, Approved_By__c, Expiration_Date__c, Approved_On__c, Approved_By__r.Name, Added_On__c, Status__c, Reviewed_By__c, Attachment_Id__c, Reviewed_By__r.Name, Reviewed_On__c FROM Deal_Document__c";
    queryString += ` WHERE Checklist_Item__c = '${this.itemId}'`;
    queryString += ` ORDER BY CreatedDate DESC `;

    query({ queryString })
      .then((documents) => {
        console.log(documents);

        documents.forEach((document) => {
          document.reviewedBy = "";
          document.approvedBy = "";
          // document.reviewedOn = null;

          // document.reviewedByLabel = "test";

          // if (document.Status__c === "Reviewed") {
          //   document.reviewedOn = document.Reviewed_On__c;
          if (document.Reviewed_By__c) {
            document.reviewedBy = document.Reviewed_By__r.Name;
          }
          // }

          // if (document.Status__c === "Approved") {
          // document.reviewedOn = document.Approved_On__c;
          if (document.Approved_By__c) {
            document.approvedBy = document.Approved_By__r.Name;
          }
          // }

          document.statusClass = "";
          console.log(document.Status__c);
          console.log(document.Status__c === "Pending");
          if (document.Status__c === "Pending") {
            document.Status__c = "Not Reviewed";
          }

          if (document.Status__c === "Not Reviewed") {
            document.statusClass = "slds-text-title_bold";
            document.statusIcon = `utility:clock`;
            document.statusVariant = "warning";
          } else if (document.Status__c === "Approved") {
            document.statusIcon = `utility:success`;
            document.statusVariant = "success";
          } else if (document.Status__c === "Reviewed") {
            document.statusIcon = "utility:clock";
            document.statusVariant = "warning";
          } else if (document.Status__c === "Rejected") {
            document.statusIcon = `utility:error`;
            document.statusVariant = "error";
          }
        });

        this.documents = documents;
      })
      .catch((error) => {
        console.log(error);
        console.log("--error--");
      });
  }

  handleMassAction(event) {
    // const rows = this.template
    //   .querySelector("c-custom-data-table")
    //   .getSelectedRows();

    const rows = this.template
      .querySelector(`c-custom-data-table`)
      .getSelectedRows();

    console.log(rows);

    if (rows.length > 0) {
      const action = event.detail.value;

      if (
        action === "Approved" ||
        action === "Rejected" ||
        action === "Reviewed" ||
        action === "Not Reviewed"
      ) {
        const docs = [];
        rows.forEach((row) => {
          const doc = {
            sobjectType: "Deal_Document__c",
            Status__c: action,
            Id: row.Id
          };

          if (action == "Reviewed" || action == "Rejected") {
            doc.Reviewed__c = true;
          }

          docs.push(doc);
        });

        console.log(docs);

        upsert({ records: docs })
          .then((results) => {
            // console.log(results);
            this.queryDocuments();
          })
          .catch((error) => {
            console.log(error);
          });
      } else if (action === "archive") {
        const docs = [];
        rows.forEach((row) => {
          const doc = {
            sobjectType: "Deal_Document__c",
            Status__c: "Archived",
            Id: row.Id,
            Section__c: "Archived",
            Type__c: "Archived"
          };

          docs.push(doc);
        });

        upsert({ records: docs })
          .then((results) => {
            // console.log(results);
            this.queryDocuments();
          })
          .catch((error) => {
            console.log(error);
          });
      } else if (action === "delete") {
        const items = [];
        rows.forEach((item) => {
          items.push({
            sobjectType: "Checklist_Item__c",
            Id: item.Id
          });
        });

        deleteItems({ items })
          .then(() => {
            this.init();
          })
          .catch((error) => {
            console.log(error);
          });
      }
    }
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    if (actionName == "view") {
      this[NavigationMixin.Navigate]({
        type: "standard__namedPage",
        attributes: {
          pageName: "filePreview"
        },
        state: {
          recordIds: row.Attachment_Id__c
        }
      });
    }
  }

  // approveDocuments() {
  //   //const indexMap = {};

  //   const hasChecked = false;

  //   const records = [];
  //   this.documents.forEach((document, index) => {
  //     if (document.checked) {
  //       records.push({
  //         sobjectType: "Deal_Document__c",
  //         Reviewed__c: true,
  //         Status__c: "Approved",
  //         Id: document.Id
  //       });
  //     }
  //   });

  //   if (records.length > 0) {
  //     console.log(records);

  //     upsert({ records: records })
  //       .then((results) => {
  //         this.queryDocuments();
  //       })
  //       .catch((error) => {
  //         console.log(error);
  //         console.log("--error--");
  //       });
  //   }
  // }

  // rejectDocuments() {
  //   //const indexMap = {};

  //   const hasChecked = false;

  //   const records = [];
  //   this.documents.forEach((document, index) => {
  //     if (document.checked) {
  //       records.push({
  //         sobjectType: "Deal_Document__c",
  //         Reviewed__c: true,
  //         Status__c: "Rejected",
  //         Id: document.Id
  //       });
  //     }
  //   });

  //   // console.log(records);

  //   if (records.length > 0) {
  //     console.log(records);

  //     upsert({ records: records })
  //       .then((results) => {
  //         this.queryDocuments();
  //       })
  //       .catch((error) => {
  //         console.log(error);
  //         console.log("--error--");
  //       });
  //   }
  // }

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
    this.documents = [];
    this.template.querySelector("c-modal").closeModal();
  }
}
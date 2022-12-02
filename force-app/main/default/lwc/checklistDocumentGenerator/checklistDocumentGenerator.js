import { LightningElement, api } from "lwc";
import getChecklistContacts from "@salesforce/apex/ChecklistController.getChecklistContacts";
import getContactDocuments from "@salesforce/apex/ChecklistController.getContactDocuments";
import generatePDF from "@salesforce/apex/ChecklistController.generatePDF";
import saveIds from "@salesforce/apex/ChecklistController.saveIds";
export default class ChecklistDocumentGenerator extends LightningElement {
  isLoaded = false;
  dealId;
  options = [];

  items = [];
  // dealItems = [];
  // contactItems = [];
  // sectionId;

  sectionIds = [];

  columns = [
    {
      label: "Name",
      fieldName: "Name",
      type: "text",
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
      label: "Related To",
      fieldName: "relatedTo",
      type: "texticon",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Comments",
      type: "button",
      typeAttributes: {
        name: "comments",
        title: "Open Comments",
        label: { fieldName: "commentsLabel" },
        variant: "base"
      },
      wrapText: true,
      hideDefaultActions: true
    }
    // {
    //   label: "Comment",
    //   fieldName: "comment",
    //   type: "text",
    //   wrapText: true,
    //   hideDefaultActions: true
    // }
  ];

  @api openModal(dealId) {
    this.dealId = dealId;

    this.queryOptions();

    this.template.querySelector("c-modal").openModal();
  }

  queryOptions() {
    getChecklistContacts({ dealId: this.dealId })
      .then((results) => {
        console.log(results);
        this.options = JSON.parse(results);
        this.isLoaded = true;
      })
      .catch((error) => {
        console.log("pdf error");
        console.log(error);
      });
  }

  handleContactSelect(event) {
    // console.log(event.target.value);
    console.log(event.detail);
    this.sectionIds = event.detail;
    if (this.sectionIds.length > 0) {
      getContactDocuments({
        sectionIds: this.sectionIds,
        dealId: this.dealId
      })
        .then((data) => {
          const itemMap = JSON.parse(data);
          console.log(itemMap);
          // this.dealItems = itemMap.Deal;
          // this.contactItems = itemMap.Contact;

          // this.dealItems &&
          //   this.dealItems.forEach((item) => {
          //     item.commentsLabel = `Comments (${
          //       item.Comments__r ? item.Comments__r.totalSize : 0
          //     })`;

          //     item.statusIcon = `utility:clock`;
          //     item.statusVariant = "warning";
          //     // item.iconSrc = `${icons}/pending-clock.svg#icon`;
          //     if (item.Status__c === "Pending") {
          //       item.Status__c = "Not Started";
          //     }
          //     item.statusClass = "";
          //     if (item.Status__c === "Not Started") {
          //       item.statusClass = "slds-text-title_bold";
          //       item.statusIcon = "utility:error";
          //       item.statusVariant = "error";
          //     }

          //     if (item.Status__c === "Completed") {
          //       item.statusIcon = "utility:success";
          //       item.iconSrc = "";
          //       item.statusVariant = "success";
          //     }
          //   });

          // this.contactItems &&
          //   this.contactItems.forEach((item) => {
          //     item.commentsLabel = `Comments (${
          //       item.Comments__r ? item.Comments__r.totalSize : 0
          //     })`;
          //     item.statusIcon = `utility:clock`;
          //     item.statusVariant = "warning";
          //     // item.iconSrc = `${icons}/pending-clock.svg#icon`;
          //     if (item.Status__c === "Pending") {
          //       item.Status__c = "Not Started";
          //     }
          //     item.statusClass = "";
          //     if (item.Status__c === "Not Started") {
          //       item.statusClass = "slds-text-title_bold";
          //       item.statusIcon = "utility:error";
          //       item.statusVariant = "error";
          //     }

          //     if (item.Status__c === "Completed") {
          //       item.statusIcon = "utility:success";
          //       item.iconSrc = "";
          //       item.statusVariant = "success";
          //     }
          //   });

          // console.log(this.dealItems);
          // console.log(this.contactItems);

          const items = [];
          for (const [key, value] of Object.entries(itemMap)) {
            console.log(`${key}: ${value}`);

            value.forEach((val) => {
              if (val.Checklist_Section__r.Deal_Contact__c) {
                val.relatedTo =
                  val.Checklist_Section__r.Deal_Contact__r.Contact__r.Name;
              } else {
                val.relatedTo = "Loan"; //val.Checklist_Section__r.Deal__r.Name;
              }
            });

            items.push({
              name: key,
              items: value
            });
          }

          console.log(items);

          this.items = items;
        })
        .catch((error) => {
          console.log(error);
        });
    } else {
      this.items = [];
    }
  }

  get showTabs() {
    // return (
    //   (this.dealItems && this.dealItems.length > 0) ||
    //   (this.contactItems && this.contactItems.length > 0)
    // );

    return this.items.length > 0;
  }

  get showDealTab() {
    return this.dealItems && this.dealItems.length > 0;
  }

  get showContactTab() {
    return this.contactItems && this.contactItems.length > 0;
  }

  closeModal() {
    this.template.querySelector("c-modal").closeModal();
  }

  generatePDF() {
    //console.log("generate");
    const ids = [];
    this.template.querySelectorAll("c-custom-data-table") &&
      this.template.querySelectorAll("c-custom-data-table").forEach((table) => {
        table.getSelectedRows().forEach((item) => {
          ids.push(item.Id);
        });
      });

    console.log(ids);
    console.log(this.sectionId);

    if (ids.length > 0) {
      saveIds({ sectionId: this.sectionId, ids: JSON.stringify(ids) })
        .then((data) => {
          generatePDF({ sectionId: this.sectionId })
            .then((response) => {
              console.log(response);

              let element = document.createElement("a");
              element.setAttribute(
                "href",
                "data:application/pdf;base64," + response
              );
              element.setAttribute("download", "checklist.pdf");

              element.style.display = "none";
              document.body.appendChild(element);

              element.click();

              document.body.removeChild(element);
            })
            .catch((error) => {
              console.log(error);
            });
        })
        .catch((error) => {
          console.log(error);
        });
    }
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    console.log(actionName);
    if (actionName == "comments") {
      this.template
        .querySelector("c-checklist-comments")
        .openModal(row.Id, row.name);
      this.template.querySelector("c-modal").closeModal();
    }
  }

  reopen(event) {
    this.template.querySelector("c-modal").openModal();
  }
}
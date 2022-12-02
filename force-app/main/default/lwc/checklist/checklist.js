import { LightningElement, api, wire } from "lwc";
import init from "@salesforce/apex/ChecklistController.init";
import handleUpload from "@salesforce/apex/ChecklistController.handleUpload";
// import deleteItem from "@salesforce/apex/ChecklistController.deleteItem";
// import approveItems from "@salesforce/apex/ChecklistController.approveItems";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import deleteItems from "@salesforce/apex/ChecklistController.deleteItems";
import upsertItems from "@salesforce/apex/ChecklistController.upsertItems";
import updateChecklist from "@salesforce/apex/ChecklistController.updateChecklist";
import getMilestoneList from "@salesforce/apex/ChecklistController.getMilestoneList";

import { getRecord, getRecordNotifyChange } from "lightning/uiRecordApi";

// import icons from "@salesforce/resourceUrl/icons";

// import icons from "@salesforce/resourceUrl/pendingclock";

const FIELDS = ["Opportunity.Id"];
export default class Checklist extends LightningElement {
  @api recordId = "0068K000002NCXIQA4";
  @api objectApiName;

  draftValues = [];
  documentColumns = [
    {
      label: "Name",
      fieldName: "name",
      type: "text",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Status",
      fieldName: "status",
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
      label: "Documents",
      type: "button",
      typeAttributes: {
        name: "documents",
        title: "Open Documents",
        label: { fieldName: "documentsLabel" },
        variant: "base",
        class: { fieldName: "documentsClass" },
        iconName: { fieldName: "documentButton" },
        iconPosition: "right"
      },
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Responsible Party",
      fieldName: "responsibleParty",
      type: "text",
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
    },
    {
      label: "Upload",
      fieldName: "files",
      type: "fileupload",
      hideLabel: true,
      typeAttributes: {
        recordId: { fieldName: "id" },
        label: { fieldName: "id" },
        hideLabel: true //pass Id of current record
      },
      wrapText: true,
      hideDefaultActions: true
    },
    {
      type: "action",
      typeAttributes: {
        rowActions: [
          { label: "Edit", name: "edit" },
          { label: "Delete", name: "delete" }
        ]
      }
    }
  ];

  taskColumns = [
    {
      label: "Name",
      fieldName: "name",
      type: "text",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Status",
      fieldName: "status",
      type: "texticon",
      wrapText: true,
      hideDefaultActions: true,
      typeAttributes: {
        iconName: { fieldName: "statusIcon" },
        variant: { fieldName: "statusVariant" }
      }
    },
    {
      label: "Responsible Party",
      fieldName: "responsibleParty",
      type: "text",
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
    },
    {
      type: "action",
      typeAttributes: {
        rowActions: [
          { label: "Edit", name: "edit" },
          { label: "Delete", name: "delete" }
        ]
      }
    }
  ];

  lenderDocumentColumns = [
    {
      label: "Name",
      fieldName: "name",
      type: "text",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Status",
      fieldName: "status",
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
      label: "Documents",
      type: "button",
      typeAttributes: {
        name: "documents",
        title: "Open Documents",
        label: { fieldName: "documentsLabel" },
        variant: "base",
        class: { fieldName: "documentsClass" },
        iconName: { fieldName: "documentButton" },
        iconPosition: "right"
      },
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
    },
    {
      label: "Upload",
      fieldName: "files",
      type: "fileupload",
      hideLabel: true,
      typeAttributes: {
        recordId: { fieldName: "id" },
        label: { fieldName: "id" },
        hideLabel: true //pass Id of current record
      },
      wrapText: true,
      hideDefaultActions: true
    },
    {
      type: "action",
      typeAttributes: {
        rowActions: [{ label: "Edit", name: "edit" }]
      }
    }
  ];

  lenderTaskColumns = [
    {
      label: "Name",
      fieldName: "name",
      type: "text",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Status",
      fieldName: "status",
      type: "texticon",
      wrapText: true,
      hideDefaultActions: true,
      typeAttributes: {
        iconName: { fieldName: "statusIcon" },
        variant: { fieldName: "statusVariant" }
      }
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
    },
    {
      type: "action",
      typeAttributes: {
        rowActions: [{ label: "Edit", name: "edit" }]
      }
    }
  ];

  // milestones = [];
  currentMilestone;
  // selectedMilestone;
  checklist;

  activeSection = ["uploads"];

  milestones = [];

  connectedCallback() {
    this.getMilestones();
    this.init();
  }

  get docColumns() {
    return this.objectApiName == "Opportunity"
      ? this.documentColumns
      : this.lenderDocumentColumns;
  }

  get tColumns() {
    return this.objectApiName == "Opportunity"
      ? this.taskColumns
      : this.lenderTaskColumns;
  }

  getMilestones() {
    getMilestoneList({ recordId: this.recordId })
      .then((milestones) => {
        console.log("--milestones--");
        console.log(milestones);
        this.milestones = milestones;
      })
      .catch((error) => {
        console.log(error);
      });
  }

  init() {
    //console.log("fire this");
    init({ recordId: this.recordId })
      .then((results) => {
        const checklist = JSON.parse(results);

        console.log("--checklist--");
        console.log(checklist);
        checklist.milestones.forEach((milestone) => {
          milestone.sections.forEach((section) => {
            section.uploadItems.forEach((item) => {
              item.commentsLabel = `Comments (${item.numberOfComments})`;
              item.documentsLabel = `Documents (${item.numberOfDocuments})`;

              item.statusIcon = `utility:clock`;
              item.statusVariant = "warning";
              // item.iconSrc = `${icons}/pending-clock.svg#icon`;
              if (item.documents.length > 0) {
                item.documentsClass = "";
              } else {
                item.documentsClass = "slds-hidden";
              }

              if (item.hasExpiredDocuments) {
                item.documentButton = "utility:priority";
              }

              if (item.status === "Pending") {
                item.status = "Not Started";
              }
              item.statusClass = "";
              if (item.status === "Not Started") {
                item.statusClass = "slds-text-title_bold";
                item.statusIcon = "utility:error";
                item.statusVariant = "error";
              }

              if (item.status === "Completed") {
                item.statusIcon = "utility:success";
                item.iconSrc = "";
                item.statusVariant = "success";
              }
            });

            section.taskItems.forEach((item) => {
              item.commentsLabel = `Comments (${item.numberOfComments})`;
              item.statusIcon = `utility:clock`;
              item.statusVariant = "warning";
              // item.statusIcon = `/${icons}/pending-clock.svg#icon`;
              item.iconSrc = "";
              if (item.status === "Pending") {
                item.status = "Not Started";
                item.statusIcon = "action:close";
              }
              item.statusClass = "";
              if (item.status === "Not Started") {
                item.statusClass = "slds-text-title_bold";
                item.statusIcon = "utility:error";
                item.statusVariant = "error";
              }
              if (item.status === "Completed") {
                item.iconSrc = "";
                item.statusVariant = "success";
              }
            });
          });

          // uploadItems.forEach((item) => {
          //   if (item.documents.length > 0) {
          //     item.documentsClass = "";
          //   } else {
          //     item.documentsClass = "slds-hide";
          //   }
          // });
        });
        if (!checklist.currentMilestone) {
          checklist.currentMilestone = "Kick-Off";
        }
        //console.log(checklist.currentMilestone);

        if (!this.currentMilestone) {
          this.currentMilestone = checklist.currentMilestone; //checklist.milestones[0].name;
        }

        // this.selectedMilestone
        // console.log(this.currentMilestone);
        this.checklist = checklist;
      })
      .catch((error) => {
        console.log("error");
      });
  }

  compileSectionTypes() {
    const types = [];
    // if (this.checklist) {
    const sectionTypes = {};
    const currentMilestone = this.currentMilestone;
    let index;

    this.checklist.milestones.forEach((milestone, milestoneIndex) => {
      if (milestone.name === currentMilestone) {
        index = milestoneIndex;
      }
    });

    const milestone = this.checklist.milestones[index];
    // console.log(sections);

    if (milestone) {
      milestone.sections.forEach((section, sectionIndex) => {
        if (!sectionTypes[section.sectionType]) {
          sectionTypes[section.sectionType] = [];
        }
        sectionTypes[section.sectionType].push(section);
      });

      // console.log(sectionTypes);

      for (const [key, value] of Object.entries(sectionTypes)) {
        const type = { name: key, sections: value };
        types.push(type);
      }
    }

    // this.checklist.milestones[index];
    // }

    console.log(types);

    return types;
  }

  get sectionTypes() {
    return this.compileSectionTypes();
  }

  // get milestones() {
  //   const milestones = [];

  //   // this.checklist.milestones.forEach
  //   // console.log(this.checklist.milestones);
  //   this.checklist.milestones.forEach((milestone) => {
  //     milestones.push(milestone.name);
  //   });
  //   // console.log(milestones);
  //   return milestones;
  // }

  handleMilestoneClick(event) {
    const milestone = event.target.getAttribute("data-milestone");

    console.log(milestone);

    this.currentMilestone = milestone;
  }

  get showDelete() {
    return this.objectApiName == "Opportunity" ? true : false;
  }

  handleMassUploadAction(event) {
    // const rows = this.template
    //   .querySelector("c-custom-data-table")
    //   .getSelectedRows();

    const sectionId = event.target.getAttribute("data-id");
    const type = event.target.getAttribute("data-type");
    const rows = this.template
      .querySelector(
        `c-custom-data-table[data-id="${sectionId}"][data-type="${type}"]`
      )
      .getSelectedRows();

    console.log(rows);

    if (rows.length > 0) {
      const action = event.detail.value;

      if (
        action === "Completed" ||
        action === "Not Started" ||
        action === "Rejected" ||
        action === "In Progress (Open)"
      ) {
        const items = [];
        rows.forEach((item) => {
          items.push({
            sobjectType: "Checklist_Item__c",
            Status__c: action,
            Id: item.id
          });
        });

        console.log(items);

        upsertItems({ items })
          .then((results) => {
            console.log(results);
            this.init();
          })
          .catch((error) => {
            console.log(error);
          });
      } else if (action === "delete") {
        const items = [];
        rows.forEach((item) => {
          items.push({
            sobjectType: "Checklist_Item__c",
            Id: item.id
          });
        });

        console.log(items);

        deleteItems({ items })
          .then(() => {
            this.init();
          })
          .catch((error) => {
            console.log(error);
          });
      } else if (action === "massDeleteProperty") {
        console.log(rows);
        // console.log(this.compileSectionTypes());

        const docTypes = new Set();

        rows.forEach((row) => {
          docTypes.add(row.documentType);
        });

        const items = [];
        const sectionTypes = this.compileSectionTypes();
        sectionTypes.forEach((section) => {
          if (section.name == "Property") {
            console.log(section.sections);
            section.sections.forEach((propertySection) => {
              propertySection.uploadItems.forEach((item) => {
                if (docTypes.has(item.documentType)) {
                  items.push({ sobjectType: "Checklist_Item__c", Id: item.id });
                }
              });
            });
          }
        });

        deleteItems({ items })
          .then(() => {
            this.init();
          })
          .catch((error) => {
            console.log(error);
          });

        // console.log(items);
      }
    }
  }

  approveAll(event) {
    const sectionId = event.target.getAttribute("data-id");
    const type = event.target.getAttribute("data-type");

    const itemIds = [];
    this.template
      .querySelectorAll(
        `[data-item="item"][data-id="${sectionId}"][data-type="${type}"]`
      )
      .forEach((input) => {
        if (input.checked) {
          itemIds.push(input.getAttribute("data-itemid"));
        }
      });

    console.log(itemIds);

    if (itemIds.length > 0) {
      approveItems({ itemIds })
        .then(() => {
          this.init();
        })
        .catch((error) => {
          console.log(error);
        });
    }
  }

  selectAll(event) {
    console.log(event);
    // console.log(event.target.getAttribute)
    const sectionId = event.target.getAttribute("data-id");
    const type = event.target.getAttribute("data-type");
    const checked = event.target.checked;
    console.log(sectionId);
    console.log(type);

    console.log(checked);

    console.log(
      this.template.querySelectorAll(
        `[data-item="item"][data-id="${sectionId}"][data-type="${type}"]`
      )
    );

    this.template
      .querySelectorAll(
        `[data-item="item"][data-id="${sectionId}"][data-type="${type}"]`
      )
      .forEach((input) => {
        input.checked = checked;
      });
  }

  handleUploadFinished(event) {
    console.log("upload finished");
    //console.log(event.target.getAttribute("data-id"));
    const itemId = event.detail.recordId;
    // console.log(event.detail.files);
    const contentVersionIds = [];
    event.detail.files.forEach((file) => {
      contentVersionIds.push(file.contentVersionId);
    });

    //console.log(itemId);
    //console.log()
    handleUpload({ itemId, contentVersionIds })
      .then((result) => {
        console.log("upload finished");
        const evt = new ShowToastEvent({
          title: "Success",
          message: "Files uploaded",
          variant: "success"
        });
        this.dispatchEvent(evt);
        this.init();
      })
      .catch((error) => {
        console.log(error);
        console.log("--error--");
      });
  }

  openDocumentModal(event) {
    const itemId = event.target.getAttribute("data-id");
    console.log(itemId);

    this.template.querySelector("c-checklist-documents").openModal(itemId);
  }

  menuItemSelect(event) {
    // console.log(event);

    const itemId = event.target.getAttribute("data-id");
    console.log(itemId);
    console.log(event.detail.value);

    const value = event.detail.value;

    if (value === "edit") {
      //
      this.template.querySelector("c-checklist-item-edit").open(itemId);
    } else if (value === "delete") {
      deleteItem({ itemId })
        .then(() => {
          this.init();
        })
        .catch((error) => {
          console.log("delete error");
          console.log(error);
        });
    }
  }

  newItem(event) {
    const sectionId = event.target.getAttribute("data-id");
    const itemType = event.target.getAttribute("data-type");
    const isProperty = event.target.getAttribute("data-isproperty");
    const sectionIds = [];
    if (isProperty === "true") {
      console.log("isProperty");
      const sectionTypes = this.compileSectionTypes();
      console.log(sectionTypes);
      sectionTypes.forEach((section) => {
        if (section.name == "Property") {
          // console.log(section.sections);
          section.sections.forEach((propertySection) => {
            sectionIds.push(propertySection.id);
            // console.log(propertySection);
            // propertySection.uploadItems.forEach((item) => {
            //   sectionIds.push(item.id);
            // });
          });
        }
      });
    }
    // console.log()
    this.template
      .querySelector("c-checklist-item-new")
      .open(sectionId, itemType, sectionIds);
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    console.log(actionName);
    if (actionName == "edit") {
      //this.template.querySelector("c-portfolio-doc-edit-modal").open(row.Id);
      this.template.querySelector("c-checklist-item-edit").open(row.id);
    } else if (actionName == "comments") {
      this.template
        .querySelector("c-checklist-comments")
        .openModal(row.id, row.name);
    } else if (actionName == "documents") {
      this.template.querySelector("c-checklist-documents").openModal(row.id);
    } else if (actionName == "delete") {
      const item = { sobjectType: "Checklist_Item__c", Id: row.id };

      deleteItems({ items: [item] })
        .then(() => {
          this.init();
        })
        .catch((error) => {
          console.log("delete error");
          console.log(error);
        });
    }
  }

  handleSave(event) {
    console.log(event.detail.draftValues);

    const rows = event.detail.draftValues;

    const items = [];
    rows.forEach((row) => {
      const item = { Id: row.id, sobjectType: "Checklist_Item__c" };
      console.log(row);
      if (row.hasOwnProperty("comments")) {
        item.Comments__c = row.comments;
      }

      if (row.hasOwnProperty("externalComments")) {
        item.External_Comments__c = row.externalComments;
      }

      items.push(item);
    });

    console.log(items);
    upsertItems({ items })
      .then((results) => {
        // event.detail.draftValues = [];
        this.draftValues = [];
        const evt = new ShowToastEvent({
          title: "Success",
          message: "Records updated",
          variant: "success"
        });
        this.dispatchEvent(evt);
        this.init();
      })
      .catch((error) => {
        console.log(error);
      });
  }

  updateStage(event) {
    const checklist = {
      sobjectType: "Checklist__c",
      Milestone__c: this.currentMilestone,
      Id: this.checklist.id
    };

    updateChecklist({ checklist })
      .then((results) => {
        const evt = new ShowToastEvent({
          title: "Success",
          message: "Checklist updated",
          variant: "success"
        });
        this.dispatchEvent(evt);
        this.init();
      })
      .catch((error) => {
        console.log(error);
      });
  }

  openPDF() {
    this.template
      .querySelector("c-checklist-document-generator")
      .openModal(this.recordId);
  }
}
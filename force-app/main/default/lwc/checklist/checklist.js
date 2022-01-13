import { LightningElement, api } from "lwc";
import init from "@salesforce/apex/ChecklistController.init";
import handleUpload from "@salesforce/apex/ChecklistController.handleUpload";
import deleteItem from "@salesforce/apex/ChecklistController.deleteItem";

export default class Checklist extends LightningElement {
  @api recordId = "0065b00000sY3YgAAK";
  @api objectApiName;

  // milestones = [];
  currentMilestone;
  // selectedMilestone;
  checklist;

  activeSection = ["uploads"];

  connectedCallback() {
    this.init();
  }

  init() {
    console.log("fire this");
    init({ recordId: this.recordId })
      .then((results) => {
        const checklist = JSON.parse(results);

        console.log(checklist);
        this.currentMilestone = checklist.milestones[0].name;
        // this.selectedMilestone
        // console.log(this.currentMilestone);
        this.checklist = checklist;
      })
      .catch((error) => {
        console.log("error");
      });
  }

  get sectionTypes() {
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
    milestone.sections.forEach((section, sectionIndex) => {
      if (!sectionTypes[section.sectionType]) {
        sectionTypes[section.sectionType] = [];
      }
      sectionTypes[section.sectionType].push(section);
    });

    console.log(sectionTypes);

    for (const [key, value] of Object.entries(sectionTypes)) {
      const type = { name: key, sections: value };

      types.push(type);
    }
    // this.checklist.milestones[index];
    // }

    return types;
  }

  get milestones() {
    const milestones = [];

    // this.checklist.milestones.forEach
    // console.log(this.checklist.milestones);
    this.checklist.milestones.forEach((milestone) => {
      milestones.push(milestone.name);
    });
    // console.log(milestones);
    return milestones;
  }

  handleMilestoneClick(event) {
    const milestone = event.target.getAttribute("data-milestone");

    console.log(milestone);

    this.currentMilestone = milestone;
  }

  handleUploadFinished(event) {
    console.log("upload finished");
    console.log(event.target.getAttribute("data-id"));
    const itemId = event.target.getAttribute("data-id");
    // const uploadedFiles = event.detail.files;
    console.log(event.detail.files);
    const contentVersionIds = [];
    event.detail.files.forEach((file) => {
      contentVersionIds.push(file.contentVersionId);
    });

    handleUpload({ itemId, contentVersionIds })
      .then((result) => {
        init({ recordId: this.recordId })
          .then((results) => {
            const checklist = JSON.parse(results);

            this.currentMilestone = checklist.milestones[0].name;
            // this.selectedMilestone
            // console.log(this.currentMilestone);
            this.checklist = checklist;
          })
          .catch((error) => {
            console.log("error");
          });
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
    console.log(sectionId);

    this.template.querySelector("c-checklist-item-new").open(sectionId);
  }
}
import { LightningElement, api } from "lwc";

import getComments from "@salesforce/apex/ChecklistController.getComments";
import upsert from "@salesforce/apex/lightning_Util.upsertRecords";

export default class ChecklistComments extends LightningElement {
  itemId;
  comments = [];
  subject;

  @api pdfGeneration = false;

  @api openModal(itemId, subject) {
    this.itemId = itemId;
    this.subject = subject;
    console.log(this.subject);
    this.queryComments();
    this.template.querySelector("c-modal").openModal();
  }

  queryComments() {
    getComments({ itemId: this.itemId })
      .then((comments) => {
        this.comments = comments;
      })
      .catch((error) => {
        console.log("--comments error--");
        console.log(error);
      });
  }

  closeModal() {
    this.comments = [];
    if (this.pdfGeneration) {
      const selectEvent = new CustomEvent("close", {});
      this.dispatchEvent(selectEvent);
    }
    this.template.querySelector("c-modal").closeModal();
  }

  createComment() {
    console.log("create comment");
    const body = this.template.querySelector("lightning-textarea").value;

    console.log(body);

    if (body) {
      const comments = this.comments;
      let lastCommentId = null;

      if (comments.length > 0) {
        lastCommentId = comments[comments.length - 1].id;
      }

      const comment = {
        sobjectType: "Comment__c",
        Comment__c: lastCommentId,
        Checklist_Item__c: this.itemId,
        Body__c: body,
        Unread__c: true,
        Subject__c: this.subject
      };

      upsert({ records: [comment] }).then((result) => {
        this.template.querySelector("lightning-textarea").value = "";
        this.dispatchEvent(new CustomEvent("comment"));
        this.queryComments();
      });
    }
  }
}
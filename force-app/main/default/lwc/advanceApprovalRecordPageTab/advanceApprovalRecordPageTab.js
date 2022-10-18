import { api, LightningElement, wire } from "lwc";
import ADVANCE_APPROVAL from "@salesforce/schema/Advance__c.Batch_Approval__c";
import SUBMITTED_BY from "@salesforce/schema/Advance__c.Batch_Approval__r.Submitted_By__c";
import APPROVAL_STATUS from "@salesforce/schema/Advance__c.Batch_Approval__r.Approval_Status__c";

import { getRecordNotifyChange, getRecord } from "lightning/uiRecordApi";
import Id from "@salesforce/user/Id";
import query from "@salesforce/apex/lightning_Util.query";
import upsertRecord from "@salesforce/apex/lightning_Controller.upsertRecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class AdvanceApprovalRecordPageTab extends LightningElement {
  @api recordId;
  userId = Id;
  approvers = [];
  isSaving = false;
  submitterId;
  approvalStatus;
  approvalId;
  approvalAction;
  newStatus;
  disableSave = false;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [ADVANCE_APPROVAL, SUBMITTED_BY, APPROVAL_STATUS]
  })
  advanceRecord({ error, data }) {
    if (error) {
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading approval record",
          message,
          variant: "error"
        })
      );
    } else if (data) {
      this.approvalId = data.fields.Batch_Approval__c.value;
      this.submitterId =
        data.fields.Batch_Approval__r.value.fields.Submitted_By__c.value;
      this.approvalStatus =
        data.fields.Batch_Approval__r.value.fields.Approval_Status__c.value;
      this.retrieveApprovers();
    }
  }

  get isUserSubmitter() {
    return this.userId == this.submitterId;
  }

  get isRecalledRejected() {
    return (
      this.approvalStatus == "Recalled" || this.approvalStatus == "Rejected"
    );
  }

  get currApproverRec() {
    return this.approvers.find(
      (a) => a.Approver__c == this.userId && a.Status__c == "Pending"
    );
  }

  get showApproverForm() {
    return this.currApproverRec && this.approvalAction;
  }

  // renderedCallback() {
  //   if (this.approvalId && this.approvers.length == 0) {
  //     this.retrieveApprovers();
  //   }
  // }

  handleClick(evt) {
    const label = evt.target.label;

    if (label === "Recall") {
      this.isSaving = true;
      this.handleRecall();
    } else if (label === "Approve") {
      this.approvalAction = "Approve Advance";
      this.newStatus = "Approved";
      this.openModal();
    } else if (label === "Reject") {
      this.approvalAction = "Reject Advance";
      this.newStatus = "Rejected";
      this.openModal();
    }
  }

  async handleRecall() {
    try {
      const record = {
        sObjectType: "Batch_Approval__c",
        Id: this.approvalId,
        Is_Recalled__c: true
      };

      await upsertRecord({ record });
      this.isSaving = false;
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "This approval has been successfully recalled.",
          variant: "success"
        })
      );

      const recIds = [
        { recordId: this.recordId },
        { recordId: this.approvalId }
      ];

      this.approvers.forEach(a => {
        recIds.push({ recordId: a.Id });
      })
      getRecordNotifyChange(recIds);
    } catch (err) {
      this.isSaving = false;
    }
  }

  async retrieveApprovers() {
    if (!this.approvalId) {
      return;
    }
    let queryString = `SELECT Id, Status__c, Approver__c,Batch_Approval__r.Approval_Status__c FROM Batch_Approver__c WHERE Batch_Approval__c='${this.approvalId}'`;

    const res = await query({ queryString });
    console.log(res);
    this.approvers = res;
  }

  closeModal() {
    this.approvalAction = null;
    this.newStatus = null;
    this.template.querySelector("c-modal").closeModal();
  }

  openModal() {
    this.template.querySelector("c-modal").openModal();
  }

  handleSave(evt) {
    this.disableSave = true;
    this.isSaving = true;
    this.template.querySelector("lightning-record-edit-form").submit();
  }

  handleSuccess(evt) {
    getRecordNotifyChange([
      { recordId: this.recordId },
      { recordId: this.approvalId }
    ]);
    this.disableSave = false;
    this.isSaving = false;
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message: "This approval has been successfully " + this.newStatus,
        variant: "success"
      })
    );
    this.closeModal();
  }
}
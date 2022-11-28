import { api, LightningElement } from 'lwc';
import Id from '@salesforce/user/Id';
import query from '@salesforce/apex/lightning_Util.query';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class BatchApprovalPanel extends LightningElement {
  @api recordId;
  userId = Id;
  batchApproverId;
  batchReadOnlyIds = [];
  approvalStatus;

  connectedCallback() {
    if(this.userId) {
      this.queryBatchApprover();
    }
  }

  handleClick(evt) {
    this.approvalStatus = evt.target.value;
    this.template.querySelector('[data-name="submitButton"]').click();
  }

  handleSubmit(evt) {
    evt.preventDefault();
    const fields = evt.detail.fields;
    fields.Status__c = this.approvalStatus;
    this.template.querySelector('lightning-record-edit-form').submit(fields);
  }

  async handleSuccess() {
    this.batchApproverId = null;
    await this.queryBatchApprover();
    const event = new ShowToastEvent({
      title: "Success",
      message: "This record has been successfully updated.",
      variant: "success"
    });
    this.dispatchEvent(event);
  }

  async queryBatchApprover() {
    let queryString = `SELECT Id, Status__c, Approver__c,Batch_Approval__r.Approval_Status__c FROM Batch_Approver__c WHERE Batch_Approval__c='${this.recordId}'`;
    const res = await query({ queryString });

    if(res.length > 0) {
      this.batchReadOnlyIds = res.map(v => v.Id);
      const approver = res.find(v => v.Approver__c === this.userId && v.Status__c === "Pending" && v.Batch_Approval__r.Approval_Status__c != "Recalled");
      if(approver) {
        this.batchApproverId = approver.Id;
      }
    }
  }
}
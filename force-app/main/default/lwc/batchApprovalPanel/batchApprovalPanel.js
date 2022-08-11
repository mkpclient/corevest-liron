import { api, LightningElement } from 'lwc';
import Id from '@salesforce/user/Id';
import query from '@salesforce/apex/lightning_Util.query';

export default class BatchApprovalPanel extends LightningElement {
  @api recordId;
  userId = Id;
  batchApproverId;
  batchReadOnlyIds = [];

  connectedCallback() {
    if(this.userId) {
      this.queryBatchApprover();
    }
  }

  async queryBatchApprover() {
    let queryString = `SELECT Id, Status__c, Approver__c,Batch_Approval__r.Approval_Status__c FROM Batch_Approver__c WHERE Batch_Approval__c='${this.recordId}'`;
    const res = await query({ queryString });

    if(res.length > 0) {
      this.batchReadOnlyIds = res.map(v => v.Id);
      const approver = res.find(v => v.Approver__c === this.userId && v.Status__c === "Pending");
      if(approver) {
        this.batchApproverId = approver.Id;
      }
    }
  }
}
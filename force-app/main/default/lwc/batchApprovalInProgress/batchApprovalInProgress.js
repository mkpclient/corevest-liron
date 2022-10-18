import { LightningElement } from "lwc";
import Id from "@salesforce/user/Id";
import query from "@salesforce/apex/lightning_Util.query";

export default class BatchApprovalInProgress extends LightningElement {
  tabUrl = "/lightning/n/Advance_Approval_Batches";
  approvalDataBatch = [];
  allApprovalDataBatch = [];
  approvalDataIc = [];
  allApprovalDataIc = [];

  userId = Id;
  filterStatusBatch = "All";
  filterStatusIc = "All";

  connectedCallback() {
    this.queryApprovalData();
  }

  async queryApprovalData() {
    const queryString = "SELECT Id, Approver__c, Approver__r.Name, Status__c, Batch_Approval__c, Batch_Approval__r.Name, Batch_Approval__r.Advance__c, Batch_Approval__r.CreatedDate, Batch_Approval__r.Week_Of__c, Batch_Approval__r.No_of_Advances__c, Batch_Approval__r.Total_Funding__c, Batch_Approval__r.Approval_Type__c FROM Batch_Approver__c WHERE Batch_Approval__r.Approval_Status__c NOT IN ('Recalled','Rejected','Approved')";

    const res = await query({ queryString });

    const localData = [];
    
    res.forEach(d => {
      let today = new Date();
      let submittedDate = new Date(d.Batch_Approval__r.CreatedDate);
      let diff = today - submittedDate;

      let hours = Math.floor(diff / 3.6e6);
      let minutes = Math.floor((diff / 3.6e6) / 6e4);
      let days = Math.floor((((diff / 1000) / 60) / 60) / 24);
      
      let timeSinceString = `${days + (!days || days > 1 ? " days" : " day")} ${hours + (!hours || hours > 1 ? " hours" : " hour")} ${minutes + (!minutes || minutes > 1 ? " minutes" : " minute")}`;
      localData.push({
        id:d.Id,
        subStatus: d.Status__c,
        approvalName: `${d.Batch_Approval__r.Name} (${d.Approver__r.Name})`,
        dateSubmitted: d.Batch_Approval__r.CreatedDate,
        timeSinceSub: timeSinceString,
        approverName: d.Approver__r.Name,
        approvalUrl: "/" + d.Batch_Approval__c,
        advanceUrl: "/" + d.Batch_Approval__r.Advance__c,
        approverId: d.Approver__c,
        noAdvances: d.Batch_Approval__r.No_of_Advances__c,
        totalFunding: d.Batch_Approval__r.Total_Funding__c,
        weekOf: d.Batch_Approval__r.Week_Of__c,
        appType: d.Batch_Approval__r.Approval_Type__c
      });
    });

    this.approvalDataBatch = localData.filter(d => d.appType == "Advance Batch Approval");
    this.allApprovalDataBatch = localData.filter(d => d.appType == "Advance Batch Approval");
    this.approvalDataIc = localData.filter(d => d.appType == "Advance IC Approval");
    this.allApprovalDataIc = localData.filter(d => d.appType == "Advance IC Approval");

  }

  handleSelectBatch(event) {
    const val = event.detail.value;
    if(val === "All") {
      this.approvalDataBatch = this.allApprovalDataBatch;
    } else {
      this.approvalDataBatch = this.allApprovalDataBatch.filter(a => a.approverId == this.userId);
    }
    this.filterStatusBatch = val;
  }

  handleSelectIc(event) {
    const val = event.detail.value;
    if(val === "All") {
      this.approvalDataIc = this.allApprovalDataIc;
    } else {
      this.approvalDataIc = this.allApprovalDataIc.filter(a => a.approverId == this.userId);
    }
    this.filterStatusIc = val;
  }

  get batchHeader() {
    return `Advance Batch Approvals in Progress (${this.filterStatusBatch})`;
  }

  get icHeader() {
    return `Advance IC Approvals in Progress (${this.filterStatusIc})`;

  }
}
import getApprovalHistories from "@salesforce/apex/IcReviewsLwcController.getApprovalHistories";
import { LightningElement, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import USER_FULLNAME from "@salesforce/schema/User.Name";

export default class IcReviewsHomePageLwc extends LightningElement {
  tabUrl = "/lightning/n/IC_Reviews_in_Progress";
  approvalData;
  allApprovalData;
  filterStatus = "All";
  userFullName;

  @wire(getApprovalHistories, {})
  returnedData({ error, data }) {
    if (data) {
      this.approvalData = data;
      this.allApprovalData = data;
    } else {
      console.error(error);
    }
  }

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [USER_FULLNAME]
  })
  wireUser({ error, data }) {
    if(data) {
      this.userFullName = data.fields.Name.value;
    } else {
      console.error(error);
    }
  }


  handleSelect(event) {
    const val = event.detail.value;
    if(val === "All") {
      this.approvalData = this.allApprovalData;
    } else {
      this.approvalData = this.allApprovalData.filter(a => a.approverName == this.userFullName);
    }
    this.filterStatus = val;
  }

  get componentHeader() {
    return `IC Approvals in Progress (${this.filterStatus})`;
  }
}
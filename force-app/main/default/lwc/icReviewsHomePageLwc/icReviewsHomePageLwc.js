import getApprovalHistories from '@salesforce/apex/IcReviewsLwcController.getApprovalHistories';
import { LightningElement, wire } from 'lwc';

export default class IcReviewsHomePageLwc extends LightningElement {
  tabUrl = '/lightning/n/IC_Reviews_in_Progress';
  approvalData;

  @wire(getApprovalHistories, {})
  returnedData({ error, data }) {
    if(data) {
      this.approvalData = data;
    } else {
      console.error(error);
    }
  }
}
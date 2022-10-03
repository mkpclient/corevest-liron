import { api, LightningElement, wire } from 'lwc';
import ADVANCE_APPROVAL from "@salesforce/schema/Advance__c.Batch_Approval__c";
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';

export default class AdvanceApprovalRecordPageTab extends LightningElement {
  @api recordId;
  userId = Id;
  
  @wire(getRecord, { recordId: "$recordId", fields: [ADVANCE_APPROVAL]})
  advanceRecord;

  get approvalId() {
    return getFieldValue(this.advanceRecord.data, ADVANCE_APPROVAL);
  }
}
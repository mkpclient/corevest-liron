import { api, LightningElement, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import upsertRecord from "@salesforce/apex/lightning_Controller.upsertRecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getFieldValue, getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

import ADVANCE_APPROVAL from "@salesforce/schema/Advance__c.Batch_Approval__c";
import APPROVAL_STATUS from "@salesforce/schema/Advance__c.Batch_Approval__r.Approval_Status__c";

export default class NewAdvanceApproval extends LightningElement {
  @api recordId;
  isLoading = false;
  @wire(getRecord, { recordId: "$recordId", fields: [ADVANCE_APPROVAL, APPROVAL_STATUS] })
  advanceRecord;

  get approvalId() {
    return getFieldValue(this.advanceRecord.data, ADVANCE_APPROVAL);
  }

  get approvalStatus() {
    return getFieldValue(this.advanceRecord.data, APPROVAL_STATUS);
  }

  get hasApproval() {
    return this.approvalId && !["Recalled", "Rejected"].includes(this.approvalStatus);
  }

  handleClick(evt) {
    const label = evt.target.label;
    if (label == "Cancel") {
      this.dispatchEvent(new CloseActionScreenEvent());
    } else if (label == "Save") {
      this.isLoading = true;
      this.template.querySelector(`[data-name="submit"]`).click();
    }
  }

  handleError(evt) {
    this.isLoading = false;
  }

  async handleSuccess(evt) {
    const recId = evt.detail.id;

    const record = {
      Id: this.recordId,
      Batch_Approval__c: recId
    };
    await upsertRecord({ record });
    const batch = {
      Id: recId,
      AttachmentPosted__c: true,
      sobjectType: "Batch_Approval__c"
    }

    await upsertRecord({ record: batch });

    getRecordNotifyChange([{recordId: this.recordId}, {recordId: recId}]);

    this.dispatchEvent(new CloseActionScreenEvent());
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message: "This advance has been submitted for approval.",
        variant: "success"
      })
    );
  }
}

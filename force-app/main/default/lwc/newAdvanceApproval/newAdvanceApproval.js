import { api, LightningElement, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import upsertRecord from "@salesforce/apex/lightning_Controller.upsertRecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
  getFieldValue,
  getRecord,
  getRecordNotifyChange
} from "lightning/uiRecordApi";

import ADVANCE_APPROVAL from "@salesforce/schema/Advance__c.Batch_Approval__c";
import APPROVAL_STATUS from "@salesforce/schema/Advance__c.Batch_Approval__r.Approval_Status__c";
import query from "@salesforce/apex/lightning_Util.query";

export default class NewAdvanceApproval extends LightningElement {
  @api recordId;
  isLoading = true;
  hasFundingApprovalPackage = false;
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [ADVANCE_APPROVAL, APPROVAL_STATUS]
  })
  advanceRecord;

  get approvalId() {
    return getFieldValue(this.advanceRecord.data, ADVANCE_APPROVAL);
  }

  get approvalStatus() {
    return getFieldValue(this.advanceRecord.data, APPROVAL_STATUS);
  }

  get hasApproval() {
    return (
      this.approvalId && !["Recalled", "Rejected"].includes(this.approvalStatus)
    );
  }

  renderedCallback() {
    if(this.recordId && this.isLoading && !this.hasFundingApprovalPackage) {
      this.checkIfFileExists();
    }
  }

  async checkIfFileExists() {
    let queryString = `SELECT Id, ContentVersion_Id__c FROM Deal_Document__c WHERE Document_Type__c='Funding Approval Package' AND Advance__c='${this.recordId}' AND Is_Deleted__c = FALSE AND ContentVersion_Id__c != null Order By CreatedDate Desc`;
    console.log(queryString);
    const dealDocs = await query({ queryString });

    if (dealDocs.length > 0) {
      const cvIds = [];

      dealDocs.forEach((d) => {
        if (d.ContentVersion_Id__c && d.ContentVersion_Id__c.length > 0) {
          cvIds.push(d.ContentVersion_Id__c);
        }
      });

      if (cvIds.length > 0) {
        queryString = `SELECT Id FROM ContentVersion WHERE Id IN ('${cvIds.join(
          "','"
        )}')`;

        console.log(queryString);

        const cvs = await query({ queryString });

        this.hasFundingApprovalPackage = cvs.length > 0;
      }
    }

    this.isLoading = false;
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
    };

    await upsertRecord({ record: batch });

    getRecordNotifyChange([{ recordId: this.recordId }, { recordId: recId }]);

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
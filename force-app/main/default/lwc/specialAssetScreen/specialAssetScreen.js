import { LightningElement, api, track, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import PROPERTY_NAME from "@salesforce/schema/Property__c.Name";
import SPEC_ASSET from "@salesforce/schema/Property__c.Special_Asset__c";
import SA_CREATED_DATE from "@salesforce/schema/Property__c.Special_Asset__r.CreatedDate";
import REFERRED_TO_ATTY_DATE from "@salesforce/schema/Property__c.Foreclosure__r.Referred_to_Attorney_Date__c";
import TRUSTEE_ASSIGNED_DATE from "@salesforce/schema/Property__c.Foreclosure__r.Trustee_Assign_Date__c";
import FC_TYPE from "@salesforce/schema/Property__c.Foreclosure__r.Foreclosure_Type__c";
import CONVERTED_TO_REO_DATE from "@salesforce/schema/Property__c.Foreclosure__r.REO_Date__c";
import DAYS_IN_FC from "@salesforce/schema/Property__c.Foreclosure__r.Days_in_Foreclosure__c";
import REO_SOLD_DATE from "@salesforce/schema/Property__c.REO__r.REO_Sold_Date__c";
import GROSS_SALES_PROC from "@salesforce/schema/Property__c.REO__r.Gross_Sales_Proceeds__c";
import NET_PROCEEDS from "@salesforce/schema/Property__c.REO__r.Net_Proceeds__c";
import DAYS_TO_REO_SOLD from "@salesforce/schema/Property__c.REO__r.Days_to_REO_Sold__c";
// import SEVERITY_FIELD from "@salesforce/schema/Special_Asset__c.Severity_Level__c";
// import FOLLOWUP_FIELD from "@salesforce/schema/Special_Asset__c.Follow_Up_Date__c";
// import RESOLUTION_FIELD from "@salesforce/schema/Special_Asset__c.Resolution_Type__c";
// import LITIGATION_FIELD from "@salesforce/schema/Special_Asset__c.Litigation_Pending__c";
// import ESTIMATEDRECOVERYDATE_FIELD from "@salesforce/schema/Special_Asset__c.Estimated_Recovery_Date__c";
import RESOLVEDDATE_FIELD from "@salesforce/schema/Property__c.Special_Asset__r.Resolved_Date__c";
// import REASON_FIELD from "@salesforce/schema/Special_Asset__c.Special_Asset_Reason__c";
// import SAMANAGER_FIELD from "@salesforce/schema/Special_Asset__c.Special_Asset_Manager__c";
// import STATUS_FIELD from "@salesforce/schema/Special_Asset__c.Status_Comment__c";
// import STRAGTEGY_FIELD from "@salesforce/schema/Special_Asset__c.Strategy__c";
// import MILESTONES_FIELD from "@salesforce/schema/Special_Asset__c.Milestones__c";

export default class SpecialAssetScreen extends LightningElement {
  @api recordId;
  // @track specialAsset = "a2f2C000000TYCKQA4";
  // @track specialAssetFields = [SEVERITY_FIELD, FOLLOWUP_FIELD, RESOLUTION_FIELD, LITIGATION_FIELD, ESTIMATEDRECOVERYDATE_FIELD, RESOLVEDDATE_FIELD,
  //   REASON_FIELD, SAMANAGER_FIELD, STATUS_FIELD, STRAGTEGY_FIELD, MILESTONES_FIELD];

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      PROPERTY_NAME,
      SPEC_ASSET,
      SA_CREATED_DATE,
      REFERRED_TO_ATTY_DATE,
      TRUSTEE_ASSIGNED_DATE,
      FC_TYPE,
      CONVERTED_TO_REO_DATE,
      DAYS_IN_FC,
      REO_SOLD_DATE,
      GROSS_SALES_PROC,
      NET_PROCEEDS,
      DAYS_TO_REO_SOLD,
      RESOLVEDDATE_FIELD
    ]
  })
  property;

  get specialAssetId() {
    return getFieldValue(this.property.data, SPEC_ASSET);
  }

  get propName() {
    return getFieldValue(this.property.data, PROPERTY_NAME);
  }

  get netProceeds() {
    return getFieldValue(this.property.data, NET_PROCEEDS);
  }

  get daysToReoSold() {
    return getFieldValue(this.property.data, DAYS_TO_REO_SOLD);
  }

  get grossSalesProc() {
    return getFieldValue(this.property.data, GROSS_SALES_PROC);
  }

  get reoSoldDate() {
    return getFieldValue(this.property.data, REO_SOLD_DATE);
  }

  get daysInFc() {
    return getFieldValue(this.property.data, DAYS_IN_FC);
  }

  get convertedToReoDate() {
    return getFieldValue(this.property.data, CONVERTED_TO_REO_DATE);
  }

  get createdDate() {
    return getFieldValue(this.property.data, SA_CREATED_DATE);
  }

  get referredToAttyDate() {
    return getFieldValue(this.property.data, REFERRED_TO_ATTY_DATE);
  }

  get trusteeAssignedDate() {
    return getFieldValue(this.property.data, TRUSTEE_ASSIGNED_DATE);
  }

  get fcType() {
    return getFieldValue(this.property.data, FC_TYPE);
  }

  get inFclValue() {
    return !this.convertedToReoDate && (this.referredToAttyDate || this.trusteeAssignedDate) ? "Yes" : "No";
  }

  get referredForFcDate() {
    return this.referredToAttyDate || this.trusteeAssignedDate || null;
  }


  handleReset(event) {
    const inputFields = this.template.querySelectorAll("lightning-input-field");
    if (inputFields) {
      inputFields.forEach((field) => {
        field.reset();
      });
    }
  }

  fireToast() {
    const event = new ShowToastEvent({
      title: "Success!",
      message: "The Special Asset Details have been successfully updated.",
      variant: "success"
    });
    this.dispatchEvent(event);
  }

  get autoDate() {
    return getFieldValue(this.property.data, RESOLVEDDATE_FIELD) || this.convertedToReoDate || this.reoSoldDate;
  }


  // querySpecialAsset() {
  //   let queryString = `SELECT Id, Name, Accrual_Stop_Date__c, Estimated_Recovery_Date__c, Follow_Up_Date__c, Property__c, Referred_for_FC_Date__c, `;
  //   queryString += `Resolution_Type__c, Resolved_Date__c, Severity_Level__c, `;
  //   queryString += `FROM Special_Asset__c WHERE Property__c = '${this.recordId}' LIMIT 1`;

  //   query({ queryString: queryString })
  //     .then((specialAsset) => {
  //       console.log("--Special Asset--");
  //       console.log(specialAsset);
  //       this.specialAsset = specialAsset;
  //       // this.isLoading = false;
  //     })
  //     .catch((error) => {
  //       console.log(error);
  //     });
  // }
}
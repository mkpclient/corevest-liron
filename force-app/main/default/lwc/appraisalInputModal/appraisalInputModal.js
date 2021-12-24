import { LightningElement, api } from "lwc";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import query from "@salesforce/apex/lightning_Util.query";
import userHasPermission from "@salesforce/apex/lightning_Util.userHasPermission";
import upsert from "@salesforce/apex/lightning_Util.upsertRecords";

export default class AppraisalInputModal extends LightningElement {
  @api dealId;

  property = {};

  dealValidated = false;
  userValidated = false;

  appraisedDate = new Date().toISOString();
  appraisedValue;

  isLoading = false;

  connectedCallback() {
    this.queryDeal();
    this.queryPermissions();
  }

  queryDeal() {
    let queryString = `SELECT Id, LOC_Loan_Type__c FROM Opportunity`;
    queryString += ` WHERE Id = '${this.dealId}'`;

    query({ queryString: queryString }).then((results) => {
      //   this.deal = [];
      console.log(results[0]);
      if (results[0].LOC_Loan_Type__c === "Single Asset (1-4 Unit)") {
        this.dealValidated = true;
      }
    });
  }

  queryPermissions() {
    userHasPermission({ permissionSetName: "Create_In_House_Appraisals" })
      .then((results) => {
        this.userValidated = results;
      })
      .catch((error) => {
        console.log("error");
        console.log(error);
      });
  }

  save() {
    console.log(this.appraisedDate);
    console.log(this.appraisedValue);
    this.isLoading = true;
    if (
      !this.appraisedDate ||
      !this.appraisedValue ||
      this.appraisedValue < 0.0
    ) {
      this.isLoading = false;
      return;
    }

    let appraisal = {
      sobjectType: "Appraisal__c",
      Property__c: this.property.Id,
      Deal__c: this.dealId,
      Appraisal_Effective_Date__c: this.appraisedDate,
      Appraisal_Completion_Date__c: this.appraisedDate,
      Appraised_Value_Amount__c: this.appraisedValue,
      Property_Address__c: this.property.Name,
      City__c: this.property.City__c,
      State__c: this.property.State__c,
      Zip__c: this.property.ZipCode__c,
      Report_Type__c: "Internal In-House Appraisal",
      Valuation_Type__c: "Internal In-House Appraisal",
      Appraisal_Product_Ordered__c: "Internal In-House Appraisal",
      Valuation_Provider__c: "CoreVest Finance",
      Vendor_Ordered_From__c: "CoreVest Finance",
      Status__c: "Complete-Delivered"
    };

    upsert({ records: [appraisal] })
      .then((results) => {
        this.isLoading = false;
        this.template.querySelector('[data-id="inputModal"]').toggleModal();

        const event = new ShowToastEvent({
          title: "Success",
          message: "In-House Appraisal created",
          variant: "success"
        });

        this.dispatchEvent(event);
      })
      .catch((error) => {
        console.log("insert error");
        this.isLoading = false;
        const event = new ShowToastEvent({
          title: "Error",
          message: "In-House Appraisal creation error",
          variant: "error"
        });
        console.log(error);
      });

    // !this.template.querySelector('[name="appraisedDate"]');
  }

  @api
  openModal(propertyId) {
    if (!this.userValidated) {
      const event = new ShowToastEvent({
        title: "Insufficient Privileges",
        message:
          "You do not have permission to create In-House Appraisals.  If you need access, please contact your System Administrator",
        variant: "error",
        duration: 10000
      });

      this.dispatchEvent(event);
      return;
    }

    if (!this.dealValidated) {
      const event = new ShowToastEvent({
        title: "Invalid Deal",
        message: "This Deal is ineligible for an In-House Appraisal.  The Product Type must be 'Single Asset (1-4 Unit)'",
        variant: "error",
        duration: 10000
      });

      this.dispatchEvent(event);
      return;
    }

    let queryString =
      "SELECT Id, Name, RecordType_Name__c, Refinance_Acquisition__c,";
    queryString += ` City__c, State__c, ZipCode__c FROM Property__c WHERE Id = '${propertyId}'`;

    console.log(queryString);

    query({ queryString: queryString }).then((results) => {
      this.property = results[0];
      console.log(this.property);
      if (
        (this.property.Refinance_Acquisition__c != "Acquisition" &&
          this.property.Refinance_Acquisition__c != "Purchase") ||
        this.property.RecordType_Name__c != "Bridge_No_Renovation"
      ) {
        //do toast

        const event = new ShowToastEvent({
          title: "Invalid Property",
          message: "This Property is invalid for an In-House Appraisal.  The Property must be Purchase Loan Purpose and not include Renovation/Construction",
          variant: "error"
        });

        this.dispatchEvent(event);
      } else {
        //open modal

        this.template.querySelector('[data-id="inputModal"]').toggleModal();
      }
    });
  }

  closeModal() {
    this.template.querySelector('[data-id="inputModal"]').toggleModal();
  }

  onchange(event) {
    let field = event.target.getAttribute("data-name");
    let value = event.target.value;

    this[field] = value;
  }
}
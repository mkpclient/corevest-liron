import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import query from "@salesforce/apex/lightning_Util.query";
import { CloseActionScreenEvent } from "lightning/actions";

import convertApplication from "@salesforce/apex/ApplicationHelper.convertApplication";
import { NavigationMixin } from "lightning/navigation";

export default class ConvertApplication extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  retrievedRecordId = false;

  record = {};
  validated = false;

  isSaving = false;

  connectedCallback() {
    console.log("connected callback");
    console.log(this.recordId);
    // const queryString = `SELECT Id, Status__c, Lead__c, Contact__c FROM Application__c WHERE Id = '${this.recordId}'`;
    // console.log(queryString);
    // query({ queryString }).then((results) => {
    //   console.log(results);
    //   this.record = results[0];

    //   this.checkValidations();
    // });
  }

  renderedCallback() {
    if (!this.retrievedRecordId && this.recordId) {
      this.retrievedRecordId = true; // Escape case from recursion
      //console.log("Found recordId: " + this.recordId);

      // Execute some function or backend controller call that needs the recordId
      // console.log("connected callback");
      // console.log(this.recordId);
      const queryString = `SELECT Id, Status__c, Lead__c, Contact__c, Lead__r.ConvertedContactId FROM Application__c WHERE Id = '${this.recordId}'`;
      // console.log(queryString);
      query({ queryString }).then((results) => {
        console.log(results);
        this.record = results[0];

        this.checkValidations();
      });
    }
  }

  checkValidations() {
    let validated = true;
    let message = "";
    if (this.record.Status__c != "Completed") {
      validated = false;
      message = "Only a Completed Application can be converted to a Deal";
    } else if (
      !this.record.Contact__c &&
      !this.record.Lead__r.ConvertedContactId
    ) {
      message =
        "Lead needs to be converted into a Contact before converting to Deal";
      validated = false;
    }

    if (!validated) {
      this.dispatchEvent(new CloseActionScreenEvent());
      const event = new ShowToastEvent({
        title: "Unable to Convert Application",
        message: message
      });
      this.dispatchEvent(event);
    }

    this.validated = validated;
  }

  convert() {
    this.isSaving = true;

    const fields = this.template.querySelectorAll("lightning-input");
    console.log(fields);
    const params = {};

    let validated = true;

    fields.forEach((field) => {
      console.log(field);
      params[field.name] = field.value;

      if (!field.reportValidity()) {
        validated = false;
      }
    });

    console.log(validated);
    params.recordId = this.recordId;
    console.log(params);

    if (validated) {
      // this[NavigationMixin.Navigate]({
      //   type: "standard__recordPage",
      //   attributes: {
      //     recordId: this.recordId,
      //     objectApiName: "Application__c", // objectApiName is optional
      //     actionName: "view"
      //   }
      // });

      convertApplication({ params })
        .then((response) => {
          const oppId = response.oppId;
          this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
              recordId: oppId,
              objectApiName: "Opportunity", // objectApiName is optional
              actionName: "view"
            }
          });
        })
        .catch((error) => {
          console.log(error);
          const event = new ShowToastEvent({
            title: "Unable to Convert Application",
            message: "Apex Error"
          });
          this.dispatchEvent(event);
          this.isSaving = false;
        });
    } else {
      this.isSaving = false;
    }
  }

  get buttonDisabled() {
    return this.isSaving;
  }

  get spinnerClass() {
    return this.isSaving ? "" : "slds-hide";
  }

  cancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
import { LightningElement, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import doQueries from "@salesforce/apex/AdvPrintValidationHelper.doQueries";

export default class AdvPrintValidation extends LightningElement {
  @api recordId;
  isLoaded = false;
  advance;
  propAdvance;
  validateTwoInputs = false;
  approvedRenovationHoldback;
  initialDisbursement;
  userApprovedRenovationHoldback = 0.00;
  userInitialDisbursement = 0.00;
  approvedAdvanceAmount;
  userApprovedAdvanceAmount = 0.00;

  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleChange = (evt) => {
    if (evt.target.name === "renovholdback") {
      this.userApprovedRenovationHoldback = evt.target.value;
    }
    if (evt.target.name === "totaldisbursement") {
      this.userInitialDisbursement = evt.target.value;
    }
    if (evt.target.name === "approvedadvance") {
      this.userApprovedAdvanceAmount = evt.target.value;
    }
  };

  handleSubmit = () => {
    let isValidated = false;

    if (
      this.userApprovedRenovationHoldback !== null &&
      this.approvedRenovationHoldback !== null
    ) {
      isValidated =
        this.userApprovedRenovationHoldback == this.approvedRenovationHoldback;
    }
    if (
      this.validateTwoInputs &&
      this.userInitialDisbursement !== null &&
      this.initialDisbursement !== null
    ) {
      isValidated =
        isValidated && this.userInitialDisbursement == this.initialDisbursement;
    }
    if (
      this.userApprovedAdvanceAmount !== null &&
      this.approvedAdvanceAmount !== null
    ) {
      isValidated =
        isValidated &&
        this.userApprovedAdvanceAmount == this.approvedAdvanceAmount;
    }

    if (isValidated) {
      window.open(`/apex/AdvancePrint?id=${this.recordId}`);
      this.closeAction();
    } else {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Validation Failed",
          message:
            "The data that you have entered do not match the data on the record. Please try again.",
          variant: "error"
        })
      );
    }
  };

  loadData = async () => {
    try {
      const [advObj, propAdvObj] = await doQueries({
        queryStrings: [
          `SELECT Deal__r.RecordType.DeveloperName, Approved_Advance_Amount_Max_Total__c, Holdback_Amount_Total__c, Initial_Disbursement_Total__c, Name, Deal__r.LOC_Loan_Type__c FROM Advance__c WHERE Id='${this.recordId}'`,
          `SELECT Property__r.RecordType.DeveloperName FROM Property_Advance__c WHERE Advance__c='${this.recordId}'`
        ]
      });
      return [advObj[0], propAdvObj, null];
    } catch (error) {
      return [null, null, error];
    }
  };

  validateObjects = () => {
    const objectValidation =
      this.advance.Name == "1" ||
      (this.advance.Deal__r.RecordType.DeveloperName === "LOC_Loan" &&
        this.advance.Deal__r.LOC_Loan_Type__c === "Multifamily" &&
        this.propAdvance.some(
          (propAdv) =>
            propAdv.Property__r.RecordType.DeveloperName ===
              "Bridge_Renovation" ||
            propAdv.Property__r.RecordType.DeveloperName ===
              "Ground_Up_Construction"
        ));
    if (objectValidation) {
      this.initialDisbursement = this.advance.Initial_Disbursement_Total__c;
    }
    this.validateTwoInputs = objectValidation;
  };

  /* processSums = () => {
    let approvedRenovationHoldback = 0;
    let initialDisbursement = 0;
    this.propAdvance.forEach((propAdv) => {
      approvedRenovationHoldback +=
        propAdv.Property__r.Approved_Renovation_Holdback__c;
      if (this.validateTwoInputs) {
        initialDisbursement += propAdv.Property__r.Iniital_Disbursement__c;
      }
    });
    this.approvedRenovationHoldback = approvedRenovationHoldback;
    this.initialDisbursement = initialDisbursement;
  }; */

  async renderedCallback() {
    if (!this.isLoaded && this.recordId) {
      const [advObj, propAdvObj, error] = await this.loadData();
      if (!error) {
        this.approvedAdvanceAmount =
          advObj.Approved_Advance_Amount_Max_Total__c;
        this.approvedRenovationHoldback = advObj.Holdback_Amount_Total__c;
        this.advance = advObj;
        this.propAdvance = propAdvObj;
        this.validateObjects();
        // this.processSums();
      } else {
        console.error(error);
      }
      this.isLoaded = true;
    }
  }
}
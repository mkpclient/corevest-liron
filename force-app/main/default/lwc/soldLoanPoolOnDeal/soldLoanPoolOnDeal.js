import { LightningElement, api, track, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const fields = ["Opportunity.Name", "Opportunity.Sold_Loan_Pool__c"];
export default class SoldLoanPoolOnDeal extends LightningElement {
    @api recordId;
    @track deal;
    // @track specialAsset = "a2f2C000000TYCKQA4";
    @track soldLoanPoolId;
    // @track specialAssetFields = [SEVERITY_FIELD, FOLLOWUP_FIELD, RESOLUTION_FIELD, LITIGATION_FIELD, ESTIMATEDRECOVERYDATE_FIELD, RESOLVEDDATE_FIELD, 
    //   REASON_FIELD, SAMANAGER_FIELD, STATUS_FIELD, STRAGTEGY_FIELD, MILESTONES_FIELD];
  
    @wire(getRecord, { recordId: '$recordId', fields })  
    wiredProperty(value) {
      if (value.data) {
        this.deal = value.data;
        this.soldLoanPoolId = this.deal.fields.Sold_Loan_Pool__c.value;
        // console.log(value);
      } else if (value.error) {
        console.log("ERROR: ", value.error)
      }
    }
  
    handleReset(event) {
      const inputFields = this.template.querySelectorAll(
          'lightning-input-field'
      );
      if (inputFields) {
          inputFields.forEach(field => {
              field.reset();
          });
      }
   }
  
    fireToast() {
      const event = new ShowToastEvent({
        title: "Success!",
        message: "The Special Asset Details have been successfully updated.",
        variant: "success",
      });
      this.dispatchEvent(event);
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
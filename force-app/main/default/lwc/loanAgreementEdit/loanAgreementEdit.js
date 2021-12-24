import { LightningElement, api } from "lwc";
import query from "@salesforce/apex/lightning_Util.query";

export default class LoanAgreementEdit extends LightningElement {
  loanVersion = null;

  @api loanVersionId;

  connectedCallback() {
    this.queryLoanVersion(this.loanVersionId);
  }

  queryLoanVersion(versionId) {
    console.log("--edit query--");

    const fields = [
      "Loan_Fees_JSON__c",
      "Final_Interest_Rate__c",
      "Required_Holdback_Reserve__c",
      "Total_Sources__c",
      "Stub_Interest__c",
      "Total_Lender__c",
      "Proceeds_Paid_To_Escrow__c",
      "Monthly_Tax__c",
      "Total_Reserve_Tax__c",
      "Monthly_Insurance__c",
      "Total_Reserve_Insurance__c",
      "Monthly_Cap_Ex__c",
      "Total_Reserve_Cap_Ex__c",
      "Monthly_Payment__c",
      "Total_Reserve_at_Closing__c",
      "Total_Third_Party__c",
      "Net_Proceeds_to_Borrower__c",
      "Total_Uses__c",
      "Holdback_Reserve__c",
      "Holdback_Reserve_Override__c",
      "Interest_Rate_Type__c",
      "YM_Prepayment_Penalty__c",
      "YM_Prepayment_Penalty_Description__c"
    ];
    let queryString = `SELECT Id, ${fields.join(",")}`;
    queryString += ` FROM Loan_Version__c WHERE Id = '${versionId}'`;
    //console.log(queryString);

    query({ queryString }).then((results) => {
      let loanVersion = results[0];

      this.loanVersion = loanVersion;
    });

    //
  }

  get showDebtDervice() {
    let show = false;

    if (this.loanVersion) {
      show = this.loanVersion.Interest_Rate_Type__c != "Interest Only";
    }

    return show;
  }

  get showYMDescription() {
    let show = false;
    if (this.loanVersion) {
      show = this.loanVersion.YM_Prepayment_Penalty__c === "Other";
    }

    return show;
  }
}
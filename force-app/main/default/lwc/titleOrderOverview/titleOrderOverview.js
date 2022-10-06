import { api, LightningElement } from "lwc";
export default class TitleOrderOverview extends LightningElement {
  @api recordId;
  selectedRequestLocal = "";
  
  get selectedRequest() {
    return this.selectedRequestLocal;
  }

  set selectedRequest(val) {
    this.selectedRequestLocal = val;
  }

  get titleOrderStatus() {
    return "unordered";
  }

  get hasNoRequest() {
    return this.titleOrderStatus == "unordered";
  }

  get nextStep() {
    return this.hasNoRequest ? "open a quote request to get started" : "";
  }

  get requestName() {
    return this.selectedRequest ? this.selectedRequest : "";
  }

  handleClick(evt) {
    const req = evt.target.value || evt.detail.value;
    this.selectedRequest = req;
    console.log(this.selectedRequest);
    this.template.querySelector("c-modal").openModal();
  }

  closeModal(event) {
    this.template.querySelector("c-modal").closeModal();
    this.selectedRequest = "";
  }

  get excelConfig() {
    return this.selectedRequest === "Quote Request" && this.dataTapeConfig;
  }

  get excelFileName() {
    return this.selectedRequest === "Quote Request" && "datatape.xlsx";
  }

  get excelQueryString() {
    return this.selectedRequest === "Quote Request" && this.dataTapeQueryString;
  }

  get dataTapeConfig() {
    return {
      Asset_ID__c: "Asset ID",
      Property_Name__c: "Property Name (Parent Property)",
      APN__c: "APN",
      Property_Type__c: "Property Type",
      Name: "Address",
      City__c: "City",
      State__c: "State",
      ZipCode__c: "ZIP",
      County__c: "County",
      Number_of_Units__c: "# of Units",
      Number_of_Beds__c: "BD",
      Number_of_Bath__c: "BA",
      Square_Feet__c: "SF",
      No_of_Stories__c: "# of Stories",
      Year_Built__c: "Year Built",
      Air_Conditioning__c: "A/C",
      Pool__c: "Pool",
      Section_8__c: "Section 8",
      Condition__c: "Condition",
      Zoning_Compliance__c: "Legally Conforming",
      Acquisition_Date__c: "Acquisition Date",
      Acquisition_Price__c: "Acquisition Price",
      Acquisition_Type__c: "Acquisition Type",
      Transaction_Costs__c: "Transaction Costs",
      Rehab_Costs__c: "Rehab Costs",
      Rehab_Completion_Date__c: "Rehab Completion Date",
      Total_Basis__c: "Total Basis",
      Borrower_Opinion_of_Current_Value__c:
        "Borrower Opinion of Current Market Value",
      Calc_AveValue__c: "Red Bell Calc AveValue",
      Appraisal_Form__c: "Appraisal Form",
      BPO_Appraisal_Date__c: "Effective Date",
      Appraised_Value_Amount__c: "Appraisal Value",
      Currently_Leased__c: "Currently Leased? (Y/N)",
      Lease_Ready__c: "Lease Ready",
      Lease_Start_Date__c: "Lease Start Date",
      Lease_End_Date__c: "Lease End Date",
      Lease_Term__c: "Lease Term",
      Monthly_Rent__c: "Monthly Rent",
      Estimated_Rent__c: "Monthly Estimated Rent",
      Security_Deposit__c: "Security Deposit",
      Other_Income__c: "Other Income",
      Annual_HOA_Fee__c: "HOA",
      Special_Assesments_CFD_Mello_Roos_etc__c: "Special Assessments",
      Annual_Taxes__c: "Taxes",
      Annual_Insurance__c: "Insurance",
      Annual_Managment_Fee__c: "Property Management",
      Maintenance_Repairs__c: "Maintenance/ Repairs",
      Owner_Paid_Utilities__c: "Owner Paid Utilities",
      Annual_Landscaping_Expense__c: "Landscaping Expense",
      Other_Expenses__c: "Other Expenses",
      Lease_Up_Marketing__c: "Lease Up/Marketing",
      Vacancy_Repairs__c: "Vacancy Repairs/Maintenance",
      Credit_Loss__c: "Credit Loss",
      Annual_Total_Expenses__c: "Total Expenses",
      Cap_Ex_Reserves__c: "CapEx Reserves",
      Other_Reserves__c: "Other Reserves",
      Annual_NOI__c: "NOI",
      Property_Manager__c: "Assigned PM Company (By property)",
      Interior_Access_POC__c: "Interior Access POC",
      Interior_Access_POC_Phone__c: "Interior Access POC Phone",
      Interior_Access_POC_Email__c: "Interior Access POC Email",
      Existing_Debt__c: "Existing Debt",
      Asset_Maturity_Date_Override__c: "Date of Maturity",
      Current_Interest_Rate__c: "Interest Rate",
      Are_Payments_Current__c: "Are payments current",
      Refinance_Acquisition__c: "Refinance / Acquisition",
      ALA__c: "ALA",
      Appraisal_Replacement_Cost_Value__c: "Appraisal Replacement Cost Value"
    };
  }

  get dataTapeQueryString() {
    return `SELECT Id,${Object.keys(this.dataTapeConfig).join(",")} FROM Property__c WHERE Deal__c = '${this.recordId}' AND Is_Sub_Unit__c = FALSE`;
  }
}

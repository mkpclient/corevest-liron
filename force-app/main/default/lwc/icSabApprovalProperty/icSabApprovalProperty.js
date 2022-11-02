import query from '@salesforce/apex/lightning_Util.query';
import { api, LightningElement } from 'lwc';

const LOAN_DETAILS_FIELDS = [
  "Deal__r.LOC_Programs__c",
  "Acquisition_Price__c",
  "Rehab_Costs__c",
  "Total_Basis__c",
  "Initial_Disbursement__c",
  "Prop_Total_Holdback__c",
  "Max_Total_Loan_Amount__c",
  "Deal__r.LTC__c",
  "Deal__r.Calculated_Origination_Fee__c",
  "Deal__r.Broker_Fees__c",
  "Deal__r.LOC_Commitment__c",
  "Deal__r.LOC_Loan_Type__c",
  "Deal__r.Product_Sub_Type__c",
  "Deal__r.Project_Strategy__c"
];

const VALUATION_FIELDS_PROP = [
  "BPO_Appraisal_Date__c",
  "Appraised_Value_Amount__c",
  "Actual_LTV__c",
  "BPO_Appraisal_Value__c",
  "Calculated_Initial_LTV__c",
  "After_Repair_Value__c"
];

const VALUATION_FIELDS_APP = [
  "Status__c",
  "Comments_to_Vendor__c",
  "Appraiser_as_Rehab_LTV__c",
  "Internal_as_Rehab_Value__c",
  "Internal_as_Rehab_LTV__c",
  "Post_Close_Appraisal__c"
];

const BORROWER_PROFILE_FIELDS = [
  "Liquidity__c",
  "Deal__r.Contact__r.Track_RecordExperience_SBE__c",
  "Deal__r.Borrower_Entity__r.Length_of_Time_in_Real_Estate__c",
  "Deal__r.Borrower_Entity__r.X36mo_Experience_Verified__c"
];

const BORROWER_STRUCTURE_FIELDS = [
  "Deal__r.Borrower_Entity__r.Name",
  "Deal__r.Borrower_Entity__c",
  "Percentage_Owned__c"
];

export default class IcSabApprovalProperty extends LightningElement {
  @api recordId;
  @api headerName;
  @api recordApiName
  @api header;
  @api guarantors;
  sectionVisible = false;
  propertyFields = [];

  get headerTitle() {
    return  `${this.header}${this.headerName ? ` for ${this.headerName}` : ''}`;
  }
  
  async connectedCallback() {
    if(this.header === "Loan Details") {
      await this.queryLoanDetails();
    }
    if(this.header === "Valuation") {
      await this.queryValuation();
    }
    if(this.header === "Borrower Profile") {
      await this.queryBorrowerProfile();
    }
    if(this.header === "Borrower Structure") {
      await this.queryBorrowerStructure();
    }
  }
  showSection() {
    this.sectionVisible = !this.sectionVisible;
  }
  async queryLoanDetails() {
    const queryString = `SELECT ${LOAN_DETAILS_FIELDS.join(",")} FROM Property__c WHERE Id = '${this.recordId}'`;
      const res = await query({ queryString });
      const fields = [
        {
          label: "Product Type",
          value: res[0].Deal__r.LOC_Loan_Type__c,
          type: "text",
          isParentField: true,
          isPillContainer: false,
          isNumber: false
        },
        {
          label: "Origination Fee $",
          type: "number",
          formatter: "currency",
          step: "0.01",
          value: res[0].Deal__r.Calculated_Origination_Fee__c,
          isParentField: true,
          isPillContainer: false,
          isNumber: true
        },
        {
          label: "Product Sub-Type",
          value: res[0].Deal__r.Product_Sub_Type__c,
          type: "text",
          isParentField: true,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Acquisition_Price__c",
          variant: "label-hidden",
          customLabel: "Total Purchase Price",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          label: "Project Strategy",
          value: res[0].Deal__r.Project_Strategy__c,
          type: "text",
          isParentField: true,
          isPillContainer: false,
          isNumber: false
        },
        {
          label: "Broker Fee $",
          type: "number",
          formatter: "currency",
          step: "0.01",
          value: (res[0].Deal__r.Broker_Fees__c / 100) * res[0].Deal__r.LOC_Commitment__c,
          isParentField: true,
          isPillContainer: false,
          isNumber: true
        },
        {
          fieldName: "Rehab_Budget__c",
          variant: "label-hidden",
          customLabel: "Rehab Amount",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Assignment_Fee__c",
          variant: "label-hidden",
          customLabel: "Assignment Fee",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Total_Cost_Basis__c",
          variant: "label-hidden",
          customLabel: "Total Cost",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Assign_Fee_to_Purchase_Ratio__c",
          variant: "label-hidden",
          customLabel: "Assign Fee to Purchase Price Ratio",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Initial_Disbursement__c",
          variant: "label-hidden",
          customLabel: "Initial Loan Amount",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Appraised_Value_Amount__c",
          variant: "label-hidden",
          customLabel: "Current Appraised As-Is Value",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        // {
        //   fieldName: "Interest_Holdback_Amount__c",
        //   variant: "label-hidden",
        //   customLabel: "Interest Holdback Amount",      
        //   isParentField: false,
        //   isPillContainer: false,
        //   isNumber: false
        // },
        {
          fieldName: "After_Repair_Value__c",
          variant: "label-hidden",
          customLabel: "Current Appraised After Repair Value",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Prop_Total_Holdback__c",
          variant: "label-hidden",
          customLabel: "Holdback Amount",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Calculated_Initial_LTV__c",
          variant: "label-hidden",
          customLabel: "Calculated Initial LTV %",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Perc_of_Rehab_Budget__c",
          variant: "label-hidden",
          customLabel: "Holdback to Rehab Ratio",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Calculated_ARV_LTV__c",
          variant: "label-hidden",
          customLabel: "Calculated ARV LTV %",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Max_Total_Loan_Amount__c",
          variant: "label-hidden",
          customLabel: "Total Loan Amount",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          isEmpty: true
        },
        {
          label: "LTC",
          type: "number",
          formatter: "percent",
          step: "0.01",
          value: res[0].Deal__r.LTC__c / 100,
          isParentField: true,
          isPillContainer: false,
          isNumber: true
        },
      ];
      this.propertyFields = fields.map((f, idx) => ({...f, key: idx}));
  }
  async queryValuation() {
    const queryString = `SELECT ${VALUATION_FIELDS_PROP.join(",")}, (SELECT Id, ${VALUATION_FIELDS_APP.join(",")} FROM Appraisals__r Order By CreatedDate DESC LIMIT 1) FROM Property__c WHERE Id = '${this.recordId}'`;
      const res = await query({ queryString });
      const fields = [
        {
          label: "Post-Close Appraisal?",
          value: res[0].hasOwnProperty("Appraisals__r") && res[0].Appraisals__r.length > 0 ? res[0].Appraisals__r[0].Post_Close_Appraisal__c : "" ,
          type: "text",
          isParentField: true,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "After_Repair_Value__c",
          variant: "label-hidden",
          customLabel: "Appraiser As Rehab Value",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          label: "Appraisal Stage",
          type: "text",
          value: res[0].hasOwnProperty("Appraisals__r") && res[0].Appraisals__r.length > 0 ? res[0].Appraisals__r[0].Status__c : "" ,
          isParentField: true,
          isPillContainer: false,
          isNumber: false
        },
        {
          label: "Appraiser As Rehab LTV",
          value: res[0].hasOwnProperty("Appraisals__r") && res[0].Appraisals__r.length > 0 ? res[0].Appraisals__r[0].Appraiser_as_Rehab_LTV__c / 100 : "0",
          type: "number",
          formatter: "percent",
          step: "0.01",
          isParentField: true,
          isPillContainer: false,
          isNumber: true
        },
        {
          fieldName: "BPO_Appraisal_Date__c",
          variant: "label-hidden",
          customLabel: "Appraisal Date",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          label: "Internal As Rehab Value",
          value: res[0].hasOwnProperty("Appraisals__r") && res[0].Appraisals__r.length > 0 ? res[0].Appraisals__r[0].Internal_as_Rehab_Value__c : "0",
          type: "number",
          formatter: "currency",
          step: "0.01",          
          isParentField: true,
          isPillContainer: false,
          isNumber: true
        },
        {
          fieldName: "Appraised_Value_Amount__c",
          variant: "label-hidden",
          customLabel: "Appraiser As-Is Value",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          label: "Internal As Rehab LTV",
          value: res[0].hasOwnProperty("Appraisals__r") && res[0].Appraisals__r.length > 0 ? res[0].Appraisals__r[0].Internal_as_Rehab_LTV__c / 100 : "0",
          type: "number",
          formatter: "percent",
          step: "0.01",
          isParentField: true,
          isPillContainer: false,
          isNumber: true
        },
        {
          fieldName: "Actual_LTV__c",
          variant: "label-hidden",
          customLabel: "Appraiser As-Is LTV",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          isEmpty: true
        },
        {
          fieldName: "BPO_Appraisal_Value__c",
          variant: "label-hidden",
          customLabel: "Internal As-Is Value",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          isEmpty: true
        },
        {
          fieldName: "Calculated_Initial_LTV__c",
          variant: "label-hidden",
          customLabel: "Internal As-Is LTV",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          isEmpty: true
        },
        {
          label: "Appraisal Comments",
          type: "text",
          value: res[0].hasOwnProperty("Appraisals__r") && res[0].Appraisals__r.length > 0 ? res[0].Appraisals__r[0].Comments_to_Vendor__c : "" ,
          isParentField: true,
          isPillContainer: false,
          isNumber: false
        },
      ];
      this.propertyFields = fields.map((f, idx) => ({...f, key: idx}));
  }
  async queryBorrowerProfile() {
    const queryString = `SELECT Id, ${BORROWER_PROFILE_FIELDS.join(",")} FROM Deal_Contact__c WHERE Id = '${this.recordId}'`;
      const res = await query({ queryString });
      const fields = [
        {
          label: "Guarantor Names",
          value: this.guarantors,
          isParentField: false,
          isPillContainer: true,
          isNumber: false
        },
        {
          fieldName: "Cash_Reserve__c",
          variant: "standard",
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          label: "Length of Time in Real Estate",
          value: res[0].Deal__r.Borrower_Entity__r.Length_of_Time_in_Real_Estate__c,
          type: "text",
          isParentField: true,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Cash_Reserve_Pct__c",
          variant: "standard",
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          label: "36mo Experience Verified",
          value: res[0].Deal__r.Borrower_Entity__r.X36mo_Experience_Verified__c,
          type: "text",
          isParentField: true,
          isPillContainer: false,
          isNumber: false
        },        
        {
          fieldName: "Monthly_Interest_Payment__c",
          variant: "standard",
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          label: "Track Record",
          type: "text",
          value: res[0].Deal__r.hasOwnProperty("Contact__r") ? res[0].Deal__r.Contact__r.Track_RecordExperience_SBE__c : "" ,
          isParentField: true,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "No_of_Months_Liquidity__c",
          variant: "standard",
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          isEmpty: true
        },
        {
          fieldName: "Cash_Reserve_Requirement__c",
          variant: "standard",
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
      ];
      this.propertyFields = fields.map((f, idx) => ({...f, key: idx}));
  }
  async queryBorrowerStructure() {
    const queryString = `SELECT Id, ${BORROWER_STRUCTURE_FIELDS.join(",")} FROM Deal_Contact__c WHERE Id = '${this.recordId}'`;
      const res = await query({ queryString });
      const fields = [
        {
          fieldLabel: "Borrower Name",
          label: res[0].Deal__r.Borrower_Entity__r.Name,
          value: '/' + res[0].Deal__r.Borrower_Entity__c,
          isParentField: true,
          isPillContainer: false,
          isUrl: true
        },
        {
          fieldName: "Regulatory_Recognition__c",
          variant: "standard",
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Required_Signer__c",
          variant: "standard",
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Formation_Documents__c",
          variant: "standard",
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          label: "Guarantor(s)",
          value: this.guarantors,
          isParentField: false,
          isPillContainer: true,
          isNumber: false
        },
        {
          fieldName: "Functional_Documents__c",
          variant: "standard",
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        {
          fieldName: "Percentage_Owned__c",
          variant: "label-hidden",
          customLabel: "Ownership",      
          isParentField: false,
          isPillContainer: false,
          isNumber: false
        },
        
      ];
      this.propertyFields = fields.map((f, idx) => ({...f, key: idx}));
  }
}
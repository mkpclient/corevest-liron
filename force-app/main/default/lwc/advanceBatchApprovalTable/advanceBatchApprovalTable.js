import query from "@salesforce/apex/lightning_Util.query";
import { LightningElement } from "lwc";

const DEAL_REC_TYPES = [
  "LOC_Loan",
  "Single_Asset_Bridge_Loan",
  "Table_Funded_CRE_Loan_Active",
  "Table_Funded_CRE_Loan",
  "Acquired_Bridge_Loan",
  "Acquired_Bridge_Loan_Active"
];

const PROP_STATUSES = ["Due Diligence", "Pending", "Closing"];

const DEAL_STAGES = [
  "Loan Processing",
  "Processing Hold",
  "Underwriting",
  "UW Hold",
  "Approved by Committee",
  "Closed Won"
];

const PROP_ADV_FIELDS = [
  "Property__c",
  "Advance__c"
]

const ADV_FIELDS = [
  "Name",
  "Target_Advance_Date__c",
  "Advance_Group_Name__c",
  "Batch_Approval__r.CreatedDate",
  "Batch_Approval__c",
  "Batch_Approval__r.Approval_Status__c",
  "Batch_Approval__r.Approved_Rejected_Date__c",
  "Batch_Approval__r.Initial_Comments__c",
  "Batch_Approval__r.Approval_Comments__c",
  "Batch_Approval__r.Name",
  "Deal__c",
  "Deal__r.Account.Name",
  "Deal__r.Name",
  "Deal__r.Index__c",
  "Deal__r.Index_Margin__c",
  "Deal__r.Deal_Loan_Number__c",
  "Deal__r.StageName",
  "Deal__r.LOC_Loan_Type__c",
  "Deal__r.CloseDate",
  "Deal__r.Project_Strategy__c",
  "Deal__r.Warehouse_Line__c",
  "Deal__r.Loan_Size__c",
  "Deal__r.Owner.Full_Name__c",
  "Deal__r.LOC_Commitment__c",
  "Deal__r.Underwriter__c",
  "Deal__r.Underwriter__r.Name",
  "Deal__r.Closer__c",
  "Deal__r.Closer__r.Name"
];

const PROP_FIELDS = [
  "Name",
  "Property_Type__c",
  "Status__c",
  "City__c",
  "State__c",
  "Refinance_Acquisition__c",
  "Acquisition_Price__c",
  "Funding_Probability__c",
  "Projected_Initial_Disbursement__c",
  "Initial_Disbursement__c",
  "Requested_Funding_Date__c",
  "Underwriter__c",
  "Underwriter__r.Name",
  "Closer__c",
  "Closer__r.Name",
  
];

const PROP_WHERE_CLAUSE = `Property__r.Status__c IN ('${PROP_STATUSES.join(",")}')
AND (Property__r.Requested_Funding_Date__c = NEXT_N_DAYS:60
  OR Property__r.Requested_Funding_Date__c < TODAY)
`;

const ADV_WHERE_CLAUSE = `Deal__r.Account.Name != 'Inhouse Test Account'
AND Deal__r.RecordType.DeveloperName IN ('${DEAL_REC_TYPES.join("','")}')
AND Deal__r.StageName IN ('${DEAL_STAGES.join("','")}')
AND (Target_Advance_Date__c = NEXT_N_DAYS:60
OR Target_Advance_Date__c < TODAY)
AND ((Loan_Type__c = 'Credit Line' AND Approved_Advance_Amount_Max_Total__c < 1000000) 
OR (RecordType.DeveloperName = 'Construction_Advance'))
ORDER BY
Target_Advance_Date__c ASC NULLS LAST,
Advance_Group_Name__c ASC NULLS LAST,
Name ASC`;
export default class AdvanceBatchApprovalTable extends LightningElement {
  connectedCallback() {
    this.queryAdvances();
  }
  
  async queryAdvances() {
    const queryString = `SELECT Id, ${ADV_FIELDS.join(",")}, (
      SELECT Id, ${PROP_ADV_FIELDS.join(",")}, Property__r.${PROP_FIELDS.join(",Property__r.")}
      FROM Property_Advances__r WHERE ${PROP_WHERE_CLAUSE} ORDER BY Property__r.Requested_Funding_Date__c ASC NULLS LAST
    ) FROM Advance__c WHERE Id IN (SELECT Advance__c FROM Property_Advance__c WHERE ${PROP_WHERE_CLAUSE}) AND ${ADV_WHERE_CLAUSE}`;
    const res = await query({ queryString });
    
    
    console.log(res);
  }
}

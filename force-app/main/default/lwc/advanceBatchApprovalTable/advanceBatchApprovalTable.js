import query from "@salesforce/apex/lightning_Util.query";
import { LightningElement } from "lwc";

const COLS = [
  {
    label: "Approval Status",
    fieldName: "approvalStatus",
    type: "url",
    typeAttributes: { label: { fieldName: "approvalStatus" } }
  },
  {
    label: "Approval Request Date",
    fieldName: "approvalReqDate",
    type: "date"
  },
  {
    label: "Approved/Rejected Date",
    fieldName: "approvedRejectedDate",
    type: "date"
  },
  {
    label: "Initial Submission Comments",
    fieldName: "initialComments"
  },
  {
    label: "Approval Comments",
    fieldName: "approvalComments",
    typeAttributes: {
      tooltip: {
        fieldName: "approvalComments"
      }
    }
  },
  {
    label: "Requested Funding Date",
    fieldName: "reqFundingDate",
    type: "date"
  },
  {
    label: "Advance Group or Property Name (if single asset)",
    fieldName: "advUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "advGroupOrPropName" } }
  },
  {
    label: "Property Status",
    fieldName: "propStatus"
  },
  {
    label: "Property Cities",
    fieldName: "propCity"
  },
  {
    label: "Property State(s)",
    fieldName: "propStates"
  },
  {
    label: "Loan Commitment",
    fieldName: "loanCommitment",
    type: "currency"
  },
  {
    label: "Acquisition or Refinance",
    fieldName: "refAcq"
  },
  {
    label: "Acquisition Price",
    fieldName: "acqPrice",
    type: "currency"
  }

];

const ADV_FIELDS_MAP = {
  Batch_Approval__c: {
    label: "Batch URL",
    key: "batchUrl"
  },
  Batch_Approval__r: {
    Approval_Status__c: {
      label: "Approval Status",
      key: "approvalStatus"
    },
    CreatedDate: {
      label: "Approval Request Date",
      key: "approvalReqDate"
    },
    Approved_Rejected_Date__c: {
      label: "Approved/Rejected Date",
      key: "approvedRejectedDate"
    },
    Initial_Comments__c: {
      label: "Initial Submission Comments",
      key: "initialComments"
    },
    Approval_Comments__c: {
      label: "Approval Comments",
      key: "approvalComments"
    }
  },
  Target_Advance_Date__c: {
    label: "Requested Funding Date",
    key: "reqFundingDate"
  },
  Advance_Group_Name__c: {
    label: "Advance Group or Property Name (if single asset)",
    key: "advGroupOrPropName"
  },
  Deal__r: {
    LOC_Commitment__c: {
      label: "Loan Commitment",
      key: "loanCommitment"
    }
  },
  Purchase_Price_Total__c: {
    label: "Acquisition Price",
    key: "acqPrice"
  }
};

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

const PROP_ADV_FIELDS = ["Property__c", "Advance__c"];

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
  "Closer__r.Name"
];

const PROP_WHERE_CLAUSE = `Property__r.Status__c IN ('${PROP_STATUSES.join(
  ","
)}')
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

  tableData = [];
  allData = [];

  /**
   * @name csvFieldMap 
   * @type {Object}
   * @description key value pair of table keys and actual header for generation of the CSV file
   */
  csvFieldMap = {};
  columns = COLS;


  connectedCallback() {
    this.queryAdvances();
  }

  async queryAdvances() {
    const queryString = `SELECT Id, ${ADV_FIELDS.join(",")}, (
      SELECT Id, ${PROP_ADV_FIELDS.join(",")}, Property__r.${PROP_FIELDS.join(
      ",Property__r."
    )}
      FROM Property_Advances__r WHERE ${PROP_WHERE_CLAUSE} ORDER BY Property__r.Requested_Funding_Date__c ASC NULLS LAST
    ) FROM Advance__c WHERE Id IN (SELECT Advance__c FROM Property_Advance__c WHERE ${PROP_WHERE_CLAUSE}) AND ${ADV_WHERE_CLAUSE}`;
    const res = await query({ queryString });

    this.allData = res;

    const tableDataLocal = [];
    const csvMapLocal = {};
    res.forEach((v) => {
      let currData = { ...v };
      currData["advUrl"] = "/" + v.Id;
      if (v.Batch_Approval__c) {
        currData["batchUrl"] = "/" + v.Batch_Approval__c;
      }
      for (const k in ADV_FIELDS_MAP) {
        if (v[k]) {
          let curr = v[k];
          if (k.includes("__r")) {
            for (const childKey in ADV_FIELDS_MAP[k]) {
              if (curr[childKey]) {
                currData[ADV_FIELDS_MAP[k][childKey].key] = curr[childKey];
                csvMapLocal[ADV_FIELDS_MAP[k][childKey].key] =
                  ADV_FIELDS_MAP[k][childKey].label;
              }
            }
          } else {
            currData[ADV_FIELDS_MAP[k].key] = curr;
            csvMapLocal[ADV_FIELDS_MAP[k].key] = ADV_FIELDS_MAP[k].label;
          }
        }
      }


      // these columns need to be agregated from the children property through property_advance__c
      if (v.Property_Advances__r != null && v.Property_Advances__r.length > 0) {
        let currCity = null;
        let propStates = [];
        let propStatus = null;
        let acq = 0;
        let ref = 0;
        v.Property_Advances__r.forEach((pa) => {
          // if all cities are the same, keep value with that cityy. Otherwise, write "Multiple"
          if (pa.Property__r && pa.Property__r.City__c) {
            if (!currCity) {
              currCity = pa.Property__r.City__c;
            } else if (currCity != pa.Property__r.City__c) {
              currCity = "Multiple";
            }
          }

          // compile list of all unique States, if any

          if (pa.Property__r && pa.Property__r.State__c) {
            if (!propStates.includes(pa.Property__r.State__c)) {
              propStates.push(pa.Property__r.State__c);
            }
          }

          // if statuses are all the same, keep value to that status. Otherwise, "Various"

          if(pa.Property__r && pa.Property__r.Status__c) {
            if(!propStatus) {
              propStatus = pa.Property__r.Status__c;
            } else if (propStatus != pa.Property__r.Status__c) {
              propStatus = "Various";
            }
          }

          // count how many refinance and acquisition properties are in this advance

          if (pa.Property__r && pa.Property__r.Refinance_Acquisition__c) {
            if (pa.Property__r.Refinance_Acquisition__c == "Refinance") {
              ref++;
            } else if (
              pa.Property__r.Refinance_Acquisition__c == "Acquisition"
            ) {
              acq++;
            }
          }

          // if there is no advance group name, use property name

          if (
            !currData["advGroupOrPropName"] &&
            pa.Property__r &&
            pa.Property__r.Name
          ) {
            currData["advGroupOrPropName"] = pa.Property__r.Name;
          }
        });

        currData["propCity"] = currCity;
        currData["propStates"] = propStates.join(", ");
        currData["propStatus"] = propStatus;
        currData["refAcq"] = `Refinance (${ref}) / Acquisition (${acq})`;
        csvMapLocal["propCity"] = "Property Cities";
        csvMapLocal["propStates"] = "Property State(s)";
        csvMapLocal["refAcq"] = "Acquisition or Refinance";
        csvMapLocal["propStatus"] = "Property Status";
      }

      tableDataLocal.push(currData);
    });
    this.tableData = tableDataLocal;
    this.csvFieldMap = csvMapLocal;
    console.log(tableDataLocal);
  }
}

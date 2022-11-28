import { api, LightningElement } from 'lwc';
import query from "@salesforce/apex/lightning_Util.query";

const COLS = [
  {
    label: "Requested Funding Date",
    fieldName: "reqFundingDate",
    type: "date",
    sortable: true
  },
  {
    label: "Advance Group or Property Name (if single asset)",
    fieldName: "advUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "advGroupOrPropName" } },
    sortable: true
  },
  {
    label: "Property Status",
    fieldName: "propStatus",
    sortable: true
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
    type: "currency",
    sortable: true
  },
  {
    label: "Acquisition or Refinance",
    fieldName: "refAcq",
    wrapText: true
  },
  {
    label: "Acquisition Price",
    fieldName: "acqPrice",
    type: "currency",
    sortable: true
  }
];

const ADV_FIELDS_MAP = {
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

const PROP_STATUSES = ["Due Diligence", "Pending", "Closing"];

const PROP_ADV_FIELDS = ["Property__c", "Advance__c"];

const ADV_FIELDS = [
  "Name",
  "Target_Advance_Date__c",
  "Advance_Group_Name__c",
  "Purchase_Price_Total__c",
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
  "','"
)}')
AND (Property__r.Requested_Funding_Date__c = NEXT_N_DAYS:10
  OR Property__r.Requested_Funding_Date__c < TODAY)
`;

export default class BatchApprovalRelatedAdvance extends LightningElement {
  @api recordId;
  tableData = [];
  allData = [];
  columns = COLS;
  defaultSortDirection = "asc";
  sortDirection = "asc";
  sortedBy = "";

  connectedCallback() {
    this.queryAdvances();
  }

  sortBy(field, reverse, primer) {
    const key = primer
      ? function (x) {
          return primer(x[field]);
        }
      : function (x) {
          return x[field];
        };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }

  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.tableData];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.tableData = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  async queryAdvances() {
    const queryString = `SELECT Id, ${ADV_FIELDS.join(",")}, (
      SELECT Id, ${PROP_ADV_FIELDS.join(",")}, Property__r.${PROP_FIELDS.join(
      ",Property__r."
    )}
      FROM Property_Advances__r WHERE ${PROP_WHERE_CLAUSE} ORDER BY Property__r.Requested_Funding_Date__c ASC NULLS LAST
    ) FROM Advance__c WHERE Id IN (SELECT Advance__c FROM Approval_History__c WHERE Batch_Approval__c = '${this.recordId}')`;
        // QUERYING FROM APPROVAL HISTORY TO GET RECORDS EVEN WHEN THE ADVANCE GETS RE-PARANTED

    const res = await query({ queryString });

    this.allData = res;

    const tableDataLocal = [];
    res.forEach((v) => {
      let currData = { ...v };
      currData["advUrl"] = "/" + v.Id;
      
      for (const k in ADV_FIELDS_MAP) {
        if (v[k]) {
          let curr = v[k];
          if (k.includes("__r")) {
            for (const childKey in ADV_FIELDS_MAP[k]) {
              if (curr[childKey]) {
                currData[ADV_FIELDS_MAP[k][childKey].key] = curr[childKey];
              }
            }
          } else {
            currData[ADV_FIELDS_MAP[k].key] = curr;
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

          if (pa.Property__r && pa.Property__r.Status__c) {
            if (!propStatus) {
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
      }

      tableDataLocal.push(currData);
    });
    this.tableData = tableDataLocal;
  }
}
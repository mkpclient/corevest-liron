import query from "@salesforce/apex/lightning_Util.query";
import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import upsertRecords from "@salesforce/apex/lightning_Util.upsertRecords";
import saveAttachment from "@salesforce/apex/lightning_Controller.saveAttachment";

const COLS = [
  {
    label: "Approval Batch",
    fieldName: "batchUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "approvalBatch" }, target: "_blank"  },
    sortable: true
  },
  {
    label: "Approval Status",
    fieldName: "approvalStatus",
    type: "text",
    sortable: true
  },
  {
    label: "Approval Request Date",
    fieldName: "approvalReqDate",
    type: "date",
    sortable: true
  },
  {
    label: "Approved/Rejected Date",
    fieldName: "approvedRejectedDate",
    type: "date",
    sortable: true
  },
  {
    label: "Initial Submission Comments",
    fieldName: "initialComments"
  },
  {
    label: "Approval Comments",
    fieldName: "approvalComments",
    type: "text",
    wrapText: true
  },
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
    typeAttributes: { label: { fieldName: "advGroupOrPropName" },target: "_blank"  },
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
  Batch_Approval__r: {
    Name: {
      label: "Approval Batch",
      key: "approvalBatch"
    },
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
  'LOC_Loan',
  'Single_Asset_Bridge_Loan',
  'Table_Funded_CRE_Loan_Active',
  'Table_Funded_CRE_Loan',
  'Acquired_Bridge_Loan',
  'Acquired_Bridge_Loan_Active'
];

const PROP_STATUSES = ['Due Diligence', 'Pending', 'Closing'];

const DEAL_STAGES = [
  'Loan Processing',
  'Processing Hold',
  'Underwriting',
  'UW Hold',
  'Approved by Committee',
  'Closed Won'
];

const PROP_ADV_FIELDS = ["Property__c", "Advance__c"];

const ADV_FIELDS = [
  "Name",
  "Target_Advance_Date__c",
  "Advance_Group_Name__c",
  "Purchase_Price_Total__c",
  "Batch_Approval__r.CreatedDate",
  "Batch_Approval__c",
  "Batch_Approval__r.Approval_Status__c",
  "Batch_Approval__r.Approved_Rejected_Date__c",
  "Batch_Approval__r.Initial_Comments__c",
  "Batch_Approval__r.Approval_Comments__c",
  "Batch_Approval__r.Name",
  "Batch_Approval__r.Id",
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
//Deal__r.Account.Name != 'Inhouse Test Account'
const ADV_WHERE_CLAUSE = `(Deal__r.RecordType.DeveloperName IN ('${DEAL_REC_TYPES.join(
  "','"
)}')
AND Deal__r.StageName IN ('${DEAL_STAGES.join("','")}')
AND (Target_Advance_Date__c = NEXT_N_DAYS:10
OR Target_Advance_Date__c < TODAY)
AND ((Loan_Type__c = 'Credit Line' AND Approved_Advance_Amount_Max_Total__c < 1000000) 
OR (RecordType.DeveloperName = 'Construction_Advance'))))`;
export default class AdvanceBatchApprovalTable extends LightningElement {
  tableData = [];
  allData = [];
  selectedAdvanceIds = [];
  toastParams = {
    title: "",
    message: "",
    variant: ""
  };
  additionalWhereClause = "";
  disableSave = false;
  /**
   * @name csvFieldMap
   * @type {Object}
   * @description key value pair of table keys and actual header for generation of the CSV file
   */
  csvFieldMap = {};
  columns = COLS;
  defaultSortDirection = "asc";
  sortDirection = "asc";
  sortedBy = "approvalBatch";
  isLoading = false;

  get hasData() {
    return this.tableData.length > 0;
  }

  get advFullWhereClause() {
    const onlyBatches =
      this.additionalWhereClause ===
      "Batch_Approval__r.Approval_Status__c IN ('Submitted','Pending')";
    const orderClause =
      " ORDER BY Target_Advance_Date__c ASC NULLS LAST, Advance_Group_Name__c ASC NULLS LAST, Name ASC";

    return (
      (onlyBatches
        ? this.additionalWhereClause
        : this.additionalWhereClause + ADV_WHERE_CLAUSE) + orderClause
    );
  }
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

  closeModal() {
    this.template.querySelector("c-modal").closeModal();
  }

  openModal() {
    this.template.querySelector("c-modal").openModal();
  }

  handleSubmit(evt) {
    if (this.selectedAdvanceIds.length > 0) {
      this.openModal();
    } else {
      this.toastParams = {
        title: "Error",
        message: "Please select at least one Advance first.",
        variant: "error"
      };
      this.showToast();
    }
  }

  handleSave(evt) {
    this.disableSave = true;
    this.template.querySelector("lightning-record-edit-form").submit();
  }

  handleError(error) {
    let errMessage = 'An unexpected error has occured.';
    if(error.hasOwnProperty("body") && Array.isArray(error.body)) {
      errMessage = error.body.map(e => e.message).join("; ");
    } else if(error.hasOwnProperty("body") && error.body.hasOwnProperty("message") && typeof error.body.message === 'string') {
      errMessage = error.body.message;
    }

    this.toastParams = {
      title: "Error",
      message: errMessage,
      variant: "error"
    }

    this.showToast();
  }

  async handleSuccess(evt) {
    const batchId = evt.detail.id;
    const advances = this.selectedAdvanceIds.map((a) => ({
      Id: a,
      Batch_Approval__c: batchId,
      sobjectType: "Advance__c"
    }));
    try {
      await upsertRecords({ records: advances });
    } catch(err) {
      this.handleError(err);
      return;
    }

    try {
      await this.generateCsv(batchId);
    } catch(err) {
      this.handleError(err);
      return;
    }
    
    this.toastParams = {
      title: "Success",
      message: "Your approval has been submitted for review.",
      variant: "success"
    };
    this.showToast();
    this.closeModal();
    this.disableSave = false;
  }

  showToast() {
    const event = new ShowToastEvent(this.toastParams);
    this.dispatchEvent(event);
  }

  handleRowSelection(evt) {
    const selectedRows = evt.detail.selectedRows;
    this.selectedAdvanceIds = selectedRows.map((v) => v.Id);
  }

  handleTabChange(evt) {
    this.additionalWhereClause = evt.target.value;
    this.tableData = [];
    this.selectedAdvanceIds = [];
    this.queryAdvances();
  }

  async queryAdvances() {
    this.isLoading = true;
    const queryString = `SELECT Id, ${ADV_FIELDS.join(",")}, (
      SELECT Id, ${PROP_ADV_FIELDS.join(",")}, Property__r.${PROP_FIELDS.join(
      ",Property__r."
    )}
      FROM Property_Advances__r WHERE ${PROP_WHERE_CLAUSE} ORDER BY Property__r.Requested_Funding_Date__c ASC NULLS LAST
    ) FROM Advance__c WHERE Id IN (SELECT Advance__c FROM Property_Advance__c WHERE ${PROP_WHERE_CLAUSE}) AND ${
      this.advFullWhereClause
    }`;

    console.log(queryString);

    const res = await query({ queryString });

    this.allData = res;

    const tableDataLocal = [];
    const csvMapLocal = {};
    res.forEach((v) => {
      let currData = { ...v };
      currData["advUrl"] = "/" + v.Id;
      if (v.Batch_Approval__c) {
        currData["batchUrl"] = "/" + v.Batch_Approval__r.Id;
      } else {
        currData["batchUrl"] = "";
        currData["approvalBatch"] = "";
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
        csvMapLocal["propCity"] = "Property Cities";
        csvMapLocal["propStates"] = "Property State(s)";
        csvMapLocal["refAcq"] = "Acquisition or Refinance";
        csvMapLocal["propStatus"] = "Property Status";
      }

      tableDataLocal.push(currData);
    });
    this.tableData = tableDataLocal;
    this.csvFieldMap = csvMapLocal;
    this.isLoading = false;
  }

  async generateCsv(batchId) {
    const prevWhereClause = this.additionalWhereClause;
    this.additionalWhereClause = ` ((Id IN ('${this.selectedAdvanceIds.join(
      "','"
    )}')) AND `;
    await this.queryAdvances();

    const keyArray = [];
    const headerArray = [];

    let csvString = "";
    let rowEnd = "\n";

    // pulling from COLS so it's in proper order.
    COLS.forEach((c) => {
      let { type, label, fieldName } = c;
      if (type === "url") {
        fieldName = c.typeAttributes.label.fieldName;
      }
      keyArray.push(fieldName);
      headerArray.push(label);
    });

    csvString += headerArray.join(",");
    csvString += rowEnd;

    for (const data of this.tableData) {
      let currArray = [];
      for (const key of keyArray) {
        if (data.hasOwnProperty(key)) {
          if (key.toLowerCase().includes("date")) {
            currArray.push(
              new Date(data[key]).getMonth() +
                "/" +
                new Date(data[key]).getDate() +
                "/" +
                new Date(data[key]).getFullYear()
            );
          } else {
            currArray.push(data[key]);
          }
        } else {
          currArray.push("");
        }
      }

      csvString += currArray.join(",");
      csvString += rowEnd;
    }

    await saveAttachment({
      parentId: batchId,
      fileName: "advancesCSV.csv",
      base64Data: btoa(csvString),
      contentType: "text/csv"
    });

    const batch = {
      Id: batchId,
      AttachmentPosted__c: true,
      sobjectType: "Batch_Approval__c"
    }

    await upsertRecords({ records: [ batch ]});

    this.tableData = [];
    this.selectedAdvanceIds = [];
    this.additionalWhereClause = prevWhereClause;
    await this.queryAdvances();
  }
}
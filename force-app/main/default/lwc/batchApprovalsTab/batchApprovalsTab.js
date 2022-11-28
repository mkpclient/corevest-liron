import { LightningElement } from "lwc";
import Id from "@salesforce/user/Id";
import query from "@salesforce/apex/lightning_Util.query";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import upsertRecords from "@salesforce/apex/lightning_Util.upsertRecords";

const BATCH_FIELDS = [
  "Name",
  "Approval_Status__c",
  "Submitted_By__c",
  "Submitted_By__r.Name",
  "Week_Of__c",
  "No_of_Advances__c",
  "Total_Funding__c"
];

const APPROVER_FIELDS = [
  "Id",
  "Batch_Approval__c",
  "Approver_Name__c",
  "Status__c",
  "CreatedDate",
  "Comments__c",
  "Approver__c"
];

const COLS = [
  {
    label: "Approval Batch",
    fieldName: "batchUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "Name", target: "_blank" } },
    sortable: true
  },
  {
    label: "Batch Approval Status",
    fieldName: "Approval_Status__c",
    type: "text",
    sortable: true
  },
  {
    label: "Approver Name",
    fieldName: "Approver_Name__c",
    type: "text",
    sortable: true
  },
  {
    label: "Status",
    fieldName: "Status__c",
    type: "text",
    sortable: true
  },
  {
    label: "Approval Request Date",
    fieldName: "CreatedDate",
    type: "date",
    sortable: true
  },
  {
    label: "Submitted By",
    fieldName: "submittedBy",
    type: "text",
    sortable: true
  },
  {
    label: "Approval for the Week of",
    fieldName: "Week_Of__c",
    type: "date",
    sortable: true
  },
  {
    label: "Time Since Submission",
    fieldName: "timeSince",
    type: "text",
    sortable: true
  },
  {
    label: "Number of Advances",
    fieldName: "No_of_Advances__c",
    type: "number",
    sortable: true
  },
  {
    label: "Total Fundings",
    fieldName: "Total_Funding__c",
    type: "currency",
    sortable: true
  },
  {
    label: "Comments",
    fieldName: "Comments__c",
    type: "text",
    sortable: false
  }
];

/**
 * @typedef TableObject
 * @type {Object}
 * @property {string} Id
 * @property {string} batchUrl
 * @property {string} Name
 * @property {string} Approval_Status__c
 * @property {string} Approver_Name__c
 * @property {string} CreatedDate
 * @property {string} Week_Of__c
 * @property {string} Status__c
 * @property {string} timeSince
 * @property {number} No_of_Advances__c
 * @property {number} Total_Funding__c
 * @property {string} Comments__c
 * @property {string} submittedBy
 * @property {string} Approver__c
 */
export default class BatchApprovalsTab extends LightningElement {
  /**
   * @type {TableObject[]}
   */
  allData = [];
  /**
   * @type {TableObject[]}
   */
  userData = [];
  userId = Id;
  isLoading = false;
  columns = COLS;
  selectedBatchIds = [];
  sortData = {
    allData: {
      defaultSortDirection: "asc",
      sortDirection: "asc",
      sortedBy: "id"
    },
    userData: {
      defaultSortDirection: "asc",
      sortDirection: "asc",
      sortedBy: "id"
    }
  };

  toastParams = {
    title: "",
    message: "",
    variant: ""
  };

  disableSave = false;
  approveStatus;

  get hasAllData() {
    return this.allData.length > 0;
  }

  get hasUserData() {
    return this.userData.length > 0;
  }

  connectedCallback() {
    this.queryData();
  }

  handleClick(evt) {
    const status = evt.target.value;
    if(this.selectedBatchIds.length === 0) {
      this.toastParams = {
        title: "Error",
        message: "Please select valid approval batches first.",
        variant: "error"
      };
      this.showToast();
      return;
    }
    this.approveStatus = status;
    this.openModal();
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

  async handleSave() {
    const isValid = this.template.querySelector("lightning-textarea").reportValidity();
    if(!isValid) {
      return;
    }

    this.disableSave = true;
    const approverRecords = [];
    const comments = this.template.querySelector("lightning-textarea").value;
    this.selectedBatchIds.forEach(id => {
      approverRecords.push({
        Id: id,
        Status__c: this.approveStatus,
        Comments__c: comments,
        sobjectType: "Batch_Approver__c"
      });
    });

    this.selectedBatchIds =[];
    try {
      const res = await upsertRecords({ records: approverRecords });
    } catch (err) {
      this.handleError(err);
      this.disableSave = false;
      this.approveStatus = null;
      return;
    }
    
    try {
      await this.queryData();
    } catch (err) {
      this.handleError(err);
      this.disableSave = false;
      this.approveStatus = null;
      return;
    }
    
    
    this.toastParams = {
      title: "Success",
      message: "These batches have been successfully " + this.approveStatus,
      variant: "success"
    }
    this.showToast();
    this.closeModal();
    this.disableSave = false;
    this.approveStatus = null;
    
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
    const defaultSortDirection = "asc";
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const tableName = event.target.dataset.name;
    const cloneData =
      tableName === "allData" ? [...this.allData] : [...this.userData];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    if (tableName === "allData") {
      this.allData = cloneData;
    } else {
      this.userData = cloneData;
    }
    this.sortData[tableName] = {
      defaultSortDirection,
      sortDirection,
      sortedBy
    };
  }

  async queryData() {
    this.isLoading = true;
    let queryString = "SELECT ";
    queryString += APPROVER_FIELDS.join(",");
    queryString +=
      ", Batch_Approval__r." + BATCH_FIELDS.join(", Batch_Approval__r.");
    queryString +=
      " FROM Batch_Approver__c WHERE Batch_Approval__r.Approval_Status__c NOT IN ('Approved', 'Rejected') AND Batch_Approval__r.Approval_Type__c = 'Advance Batch Approval'";

    const res = await query({ queryString });

    /**
     * @type {TableObject[]}
     */
    const parsedData = [];

    for (const data of res) {
      const {
        Id,
        Status__c,
        Batch_Approval__c,
        CreatedDate,
        Approver_Name__c,
        Comments__c,
        Approver__c
      } = data;
      const {
        Name,
        Submitted_By__r,
        Approval_Status__c,
        Week_Of__c,
        No_of_Advances__c,
        Total_Funding__c
      } = data.Batch_Approval__r;

      const submittedBy = Submitted_By__r.Name;

      const today = new Date();
      const created = new Date(CreatedDate);
      const diff = today - created;
      let hours = Math.floor(diff / 3.6e6);
      let minutes = Math.floor((diff / 3.6e6) / 6e4);
      let days = Math.floor((((diff / 1000) / 60) / 60) / 24);
      
      let timeSince = `${days + (!days || days > 1 ? " days" : " day")} ${hours + (!hours || hours > 1 ? " hours" : " hour")} ${minutes + (!minutes || minutes > 1 ? " minutes" : " minute")}`;
      let batchUrl = "/" + Batch_Approval__c;
      /**
       * @type {TableObject}
       */
      let tableData = {
        Id,
        Status__c,
        Name,
        CreatedDate,
        Approver_Name__c,
        Comments__c,
        submittedBy,
        Approval_Status__c,
        Week_Of__c,
        Total_Funding__c,
        No_of_Advances__c,
        timeSince,
        batchUrl,
        Approver__c
      };

      parsedData.push(tableData);
    }

    this.allData = parsedData;
    this.userData = parsedData.filter(d => d.Approver__c === this.userId);
    this.isLoading = false;
  }

  closeModal() {
    this.template.querySelector("c-modal").closeModal();
  }

  openModal() {
    this.template.querySelector("c-modal").openModal();
  }

  showToast() {
    const event = new ShowToastEvent(this.toastParams);
    this.dispatchEvent(event);
  }

  handleRowSelection(evt) {
    /**
     * @type {TableObject[]}
     */
    const selectedRows = evt.detail.selectedRows;
    console.log(selectedRows);
    const validRows = selectedRows.filter(s => s.Status__c !== "Approved" && s.Status__c !== "Rejected");
    if(selectedRows.length !== validRows.length && selectedRows.length > 1) {
      this.toastParams = {
        title: "Your selection has been modified",
        message: "All non-pending batches have been unselected.",
        variant: "warning"
      }
      this.showToast();
    } else if (validRows.length === 0 && selectedRows.length > 0) {
      this.toastParams = {
        title: "Invalid Batch",
        message: "You have either already approved or rejected this batch.",
        variant: "error"
      }
      this.showToast();
    }
    this.selectedBatchIds = validRows.map((v) => v.Id);
    
  }
}
import getApprovalHistories from "@salesforce/apex/IcReviewsLwcController.getApprovalHistories";
import { LightningElement, wire } from "lwc";
import USER_ID from "@salesforce/user/Id";
import USER_FULLNAME from "@salesforce/schema/User.Name";
import { getRecord } from "lightning/uiRecordApi";

export default class IcReviewsInProgressLwc extends LightningElement {
  columns = [
    {
      label: "Opportunity",
      fieldName: "opportunityUrl",
      type: "url",
      typeAttributes: {
        label: { fieldName: "opportunityName" },
        target: "_blank"
      },
      sortable: true
    },
    {
      label: "Approver",
      fieldName: "approverName",
      sortable: true
    },
    {
      label: "Originator",
      fieldName: "originator",
      sortable: true
    },
    {
      label: "Loan Amount",
      fieldName: "loanAmount",
      type: "currency",
      sortable: true
    },
    {
      label: "Loan Type",
      fieldName: "loanType",
      sortable: true
    },
    {
      label: "Product Type",
      fieldName: "productType",
      sortable: true
    },
    {
      label: "Stage Time of Submission",
      fieldName: "stageTimeOfSub",
      sortable: true
    },
    {
      label: "Date Submitted",
      fieldName: "dateSubmitted",
      type: "date",
      sortable: true
    },
    {
      label: "Time Since Submitted",
      fieldName: "timeSinceSub"
    },
    {
      label: "Submission Status",
      fieldName: "subStatus"
    },
    {
      label: "Link to Approval",
      fieldName: "approvalUrl",
      type: "url",
      typeAttributes: {
        label: { fieldName: "approvalType" },
        target: "_blank"
      },
      sortable: true
    }
  ];

  sortBy;
  sortDirection;

  tableData = [];
  allTableData = [];

  userFullName;
  filterStatus = "All";

  @wire(getApprovalHistories, {})
  wiredData({ error, data }) {
    if (data) {
      this.tableData = data;
      this.allTableData = data;
    } else {
      console.error(error);
    }
  }

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [USER_FULLNAME]
  })
  wireUser({ error, data }) {
    if(data) {
      this.userFullName = data.fields.Name.value;
    } else {
      console.error(error);
    }
  }

  connectedCallback() {
    console.log(this.tableData);
  }

  handleSort(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
  }

  sortData(fieldname, direction) {
    let parseData = [...this.tableData];
    // Return the value stored in the field
    let keyValue = (a) => {
      return a[fieldname];
    };
    // cheking reverse direction
    let isReverse = direction === "asc" ? 1 : -1;
    // sorting data
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ""; // handling null values
      y = keyValue(y) ? keyValue(y) : "";
      // sorting values based on direction
      return isReverse * ((x > y) - (y > x));
    });
    this.tableData = parseData;
  }

  handleSelect(event) {
    const val = event.detail.value;
    if(val === "All") {
      this.tableData = this.allTableData;
    } else {
      this.tableData = this.allTableData.filter(a => a.approverName == this.userFullName);
    }
    this.filterStatus = val;
  }

  get componentHeader() {
    return `IC Approvals in Progress (${this.filterStatus})`;
  }
}
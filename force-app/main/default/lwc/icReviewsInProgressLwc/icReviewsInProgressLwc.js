import getApprovalHistories from "@salesforce/apex/IcReviewsLwcController.getApprovalHistories";
import { LightningElement, wire } from "lwc";

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

  tableData = [];

  @wire(getApprovalHistories, {})
  wiredData( { error, data }) {
    if(data) {
      this.tableData = data;
    } else {
      console.error(error);
    }
  }; 

  connectedCallback(){
    console.log(this.tableData);
  }
}
import retrieveData from "@salesforce/apex/TitleOrderHelper.retrieveData";
import { api, LightningElement } from "lwc";

const TITLE_MENU_ITEMS = [
  {
    label: "Quote Request",
    value: "quoteRequest"
  },
  {
    label: "Quote Accepted",
    value: "quoteAccepted"
  },
  {
    label: "Cancel Request",
    value: "cancelRequest"
  },
  {
    label: "Order Inquiry",
    value: "orderInquiry"
  },
  {
    label: "Loan Portfolio Change Request",
    value: "loanPortfolioChangeRequest"
  },
  {
    label: "Order Change Request",
    value: "orderChangeRequest"
  },
  {
    label: "Document Submission",
    value: "documentSubmission"
  }
];

const HEADERS = [
  "Address",
  "City",
  "Property Type",
  "# of Units",
  "Status",
  "Title Vendor",
  "Order Date",
  "Title Completed",
  "Original Title Cleared",
  "All Cleared to Close",
  "Comments"
];
export default class TitleOrder extends LightningElement {
  titleMenuItems = TITLE_MENU_ITEMS;
  tableHeaders = HEADERS;
  isLoading = false;
  @api recordId;
  tableData = [];

  connectedCallback() {
    if (this.recordId) {
      this.isLoading = true;
      this.handleRetrieveData();
    }
  }

  async handleRetrieveData() {
    const res = await retrieveData({ dealId: this.recordId });
    this.tableData = JSON.parse(res);
    console.log(this.tableData);
    this.isLoading = false;
  }

  selectAll(event) {
    const checked = event.target.checked;

    this.template
      .querySelectorAll('[data-name="propertyCheckbox"]')
      .forEach((checkbox) => {
        checkbox.checked = checked;
      });
  }
}

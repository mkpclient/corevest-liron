import retrieveData from "@salesforce/apex/TitleOrder_LightningHelper.retrieveData";
import { api, LightningElement, track } from "lwc";

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
  requestType;
  @track propIds = [];
  isModalOpened = false;

  connectedCallback() {
    if (this.recordId) {
      this.isLoading = true;
      this.handleRetrieveData();
    }
  }

  handleSelect(event) {
    const val = event.detail.value;
    this.requestType = val;
    const propIds = [];
    this.template
    .querySelectorAll('[data-name="propertyCheckbox"]')
    .forEach((checkbox) => {
      if(checkbox.checked) {
        propIds.push(checkbox.dataset.id);
      }
    });
    if(propIds.length > 0) {
      this.propIds = propIds; 
      this.isModalOpened = true;
      this.openModal();
    } else {
      return;
    }
  }

  handleCloseModal() {
    this.isModalOpened = false;
    this.propIds = [];
    this.requestType = null;
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

  openModal() {
    this.template.querySelector("c-title-order-modal").openModal(this.propIds);
  }
}

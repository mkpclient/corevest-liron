import deleteRecords from "@salesforce/apex/lightning_Util.deleteRecords";
import saveGeneratedFile from "@salesforce/apex/TitleOrder_LightningHelper.saveGeneratedFile";
import { api, LightningElement } from "lwc";
import sendRequest from "@salesforce/apex/TitleOrder_LightningHelper.sendRequest";
import LightningAlert from "lightning/alert";
import LightningConfirm from "lightning/confirm";
import retrieveSchemas from "@salesforce/apex/TitleOrder_LightningHelper.retrieveSchemas";
import cancelRequest from "@salesforce/apex/TitleOrder_LightningHelper.cancelRequest";

const QuoteRequest = [
  {
    type: "text",
    disabled: true,
    label: "Source Party ID",
    value: "COREVEST-SFR",
    dataName: "sourcePartyId",
    size: 6
  },
  {
    type: "text",
    disabled: true,
    label: "Destination Party ID",
    value: "COREVEST-QUOTE",
    dataName: "destinationPartyId",
    size: 6
  },
  {
    isDealField: true,
    disabled: true,
    fieldName: "Deal_Loan_Number__c",
    dataName: "dealLoanNumber",
    size: 6
  },
  {
    isDealField: true,
    disabled: true,
    fieldName: "Current_Loan_Amount__c",
    dataName: "currentLoanAmount",
    size: 6
  },
  {
    isDealField: true,
    disabled: true,
    fieldName: "Name",
    dataName: "dealName",
    size: 6
  },
  {
    isComments: true,
    label: "Comments",
    disabled: false,
    dataName: "comments",
    size: 12,
    value: null,
    required: true
  }
];

const OrderInquiry = [
  {
    isPropertySelection: true,
    size: 12,
    dataName: "propertySel",
    value: "",
    disabled: false
  },
  {
    type: "text",
    disabled: true,
    label: "Bulk Project Order Num",
    value: "",
    dataName: "Bulk_Project_Order_Num__c",
    size: 6
  },
  {
    isDealField: true,
    disabled: true,
    fieldName: "Deal_Loan_Number__c",
    dataName: "dealLoanNumber",
    size: 6
  },
  {
    type: "text",
    disabled: true,
    label: "Asset ID",
    value: "",
    dataName: "Asset_ID__c",
    size: 6
  },
  {
    type: "text",
    disabled: true,
    label: "Order Number",
    value: "",
    dataName: "Order_Number__c",
    size: 6
  },
  {
    isCombobox: true,
    disabled: false,
    label: "Inquiry Type",
    value: "",
    dataName: "inquiryType",
    size: 6,
    required: true,
    options: []
  },
  {
    isComments: true,
    label: "Comments",
    disabled: false,
    dataName: "comments",
    size: 12,
    value: null,
    required: true
  }
];

const OrderChangeRequest = [
  {
    isPropertySelection: true,
    size: 12,
    dataName: "propertySel",
    value: "",
    disabled: false
  },
  {
    type: "text",
    disabled: true,
    label: "Bulk Project Order Num",
    value: "",
    dataName: "Bulk_Project_Order_Num__c",
    size: 6
  },
  {
    isDealField: true,
    disabled: true,
    fieldName: "Deal_Loan_Number__c",
    dataName: "dealLoanNumber",
    size: 6
  },
  {
    type: "text",
    disabled: true,
    label: "Asset ID",
    value: "",
    dataName: "Asset_ID__c",
    size: 6
  },
  {
    type: "text",
    disabled: true,
    label: "Address",
    value: "",
    dataName: "Property__r.Name",
    size: 6
  },
  {
    type: "text",
    disabled: true,
    label: "City",
    value: "",
    dataName: "Property__r.City__c",
    size: 6
  },
  {
    type: "text",
    disabled: true,
    label: "State",
    value: "",
    dataName: "Property__r.State__c",
    size: 6
  },
  {
    type: "text",
    disabled: true,
    label: "County",
    value: "",
    dataName: "Property__r.County__c",
    size: 6
  },
  {
    type: "text",
    disabled: true,
    label: "Zip Code",
    value: "",
    dataName: "Property__r.ZipCode__c",
    size: 6
  },
  {
    type: "text",
    disabled: true,
    label: "Property APN",
    value: "",
    dataName: "Property__r.APN__c",
    size: 6
  },
  {
    type: "number",
    disabled: true,
    label: "Allocated Loan Amount",
    value: "",
    dataName: "Property__r.ALA__c",
    size: 6,
    formatter: "currency",
    step: "0.01"
  },
];

const FORM_CONFIGS = { QuoteRequest, OrderChangeRequest, OrderInquiry };

const acceptedFormatMap = {
  "Quote Request": [".xlsx"],
  "Order Inquiry": [".xlsx"]
};

const nextSteps = {
  Unordered: "Open a Quote Request to get started",
  Cancelled: "Open a Quote Request to get started",
  "Quote Requested":
    "No action is needed. Please wait for a response from service link.",
  "Quote Request Received":
    "Your quote has been received by servicelink. No action is currently required, but you can submit additional documents, cancel the request, or make an order inquiry.",
  "Cancel Requested": "A cancel request is currently being processed. Please wait for confirmation from ServiceLink before submitting a new Quote Request.",
  "Order Change Requested": "There is an active order change request for this loan awaiting confirmation from the vendor.",
  "Order Change Confirmed": "A recent order change request has been accepted by the vendor."
};
export default class TitleOrderOverview extends LightningElement {
  @api recordId;
  @api titleOrderParams = {};
  @api titleOrders = [];
  selectedTitleOrder = {};
  selectedToId;
  comboboxSchemas = {};

  selectedRequestLocal = "";
  currStepLocal = 1;
  formValues = {};
  docAttributes;
  isLoading = false;
  contentDocumentIdsForDeletion = [];
  titleOrderStatusLocal = "Unordered";

  get disallowAttachments() {
    return (
      (this.selectedRequest !== "Quote Request" && this.selectedRequest !== "Order Inquiry")||
      (this.selectedRequest == "Order Inquiry" &&
        this.formValues.inquiryType &&
        this.formValues.inquiryType !== "REVISEDQUO")
    );
  }

  get titleOrderSelections() {
    return this.titleOrders.map((to) => ({
      label: to.Property__r.Name + ", " + to.Property__r.State__c,
      value: to.Id
    }));
  }

  get downloadLink() {
    return this.docAttributes &&  this.docAttributes.contentDocumentId && (
      "/sfc/servlet.shepherd/document/download/" +
      this.docAttributes.contentDocumentId +
      "?operationContext=S1"
    );
  }

  get currStep() {
    return this.currStepLocal.toString();
  }

  get isFormStep() {
    return this.currStepLocal !== 2;
  }

  get formConfigs() {
    return FORM_CONFIGS;
  }

  get disableQuoteRequest() {
    return this.titleOrderStatus !== "Unordered";
  }

  get selectedRequest() {
    return this.selectedRequestLocal;
  }

  get showNext() {
    return this.currStepLocal < 3;
  }

  get showPrev() {
    return this.currStepLocal > 1;
  }

  get showSave() {
    return this.currStepLocal === 3;
  }

  set selectedRequest(val) {
    this.selectedRequestLocal = val;
  }

  get isPreviewStep() {
    return this.currStepLocal === 3;
  }

  get isDocStep() {
    return this.currStepLocal === 2;
  }

  get disableNext() {
    return this.isDocStep && !this.docAttributes && !this.disallowAttachments;
  }

  get currForm() {
    return (
      this.selectedRequest &&
      this.formConfigs[this.selectedRequest.replaceAll(" ", "")].map((c, i) => {
        let { dataName, value, disabled } = c;
        let options = [];
        if (this.formValues.hasOwnProperty(dataName)) {
          value = this.formValues[dataName];
        }
        if (this.selectedTitleOrder.hasOwnProperty(dataName)) {
          value = this.selectedTitleOrder[dataName];
        }
        if (this.comboboxSchemas.hasOwnProperty(dataName)) {
          options = this.comboboxSchemas[dataName];
        }
        disabled = disabled || this.isPreviewStep;
        return { ...c, key: i, value, disabled, options };
      })
    );
  }

  get titleOrderStatus() {
    return this.titleOrderParams.status;
  }

  get hasNoRequest() {
    return (
      this.titleOrderStatus == "Unordered" ||
      this.titleOrderStatus == "Cancelled" ||
      this.titleOrderStatus == "Cancel Requested" ||
      !this.titleOrderParams.hasBulkProjectId
    );
  }

  get nextStep() {
    return nextSteps[this.titleOrderStatus];
  }

  get requestName() {
    return this.selectedRequest ? this.selectedRequest : "";
  }

  async connectedCallback() {
    const schemas = await retrieveSchemas();
    const tempData = {};
    for (const key in schemas) {
      const vals = schemas[key];
      tempData[key] = vals.map((v) => ({
        label: v,
        value: v
      }));
    }

    this.comboboxSchemas = tempData;
  }

  disconnectedCallback() {
    if (this.contentDocumentIdsForDeletion.length > 0) {
      const records = this.contentDocumentIdsForDeletion.map((c) => ({
        Id: c
      }));

      deleteRecords({ records });
    }
  }

  handlePropertySelection(evt) {
    const { value } = evt.detail;

    this.selectedToId = value;

    this.selectedTitleOrder = this.flattenObj(this.titleOrders.find((to) => to.Id === value));
  }

  handleChange(evt) {
    const { value } = evt.detail;
    const { name } = evt.target.dataset;
    console.log(name, value);
    this.formValues[name] = value;
  }

  handleClick(evt) {
    const req = evt.target.value || evt.detail.value;

    if (req === "Cancel Request") {
      this.handleCancel();
    } else {
      this.selectedRequest = req;
      console.log(this.selectedRequest);
      this.template.querySelector("c-modal").openModal();
    }
  }

  async handleCancel() {
    const result = await LightningConfirm.open({
      message: "Would you like to cancel this request? This is an irreversible request.",
      label: "Request Cancelation",
      theme: "warning"
    });

    if(result){
      this.isLoading = true;
      const titleOrderIds = this.titleOrders.map(to => to.Id);
      try {
        await cancelRequest({ titleOrderIds });
        await LightningAlert.open({
          message: "Your cancel request has been successfully submitted.",
          theme: "success",
          label: "Success"
        });
        this.dispatchEvent(new CustomEvent("requestsubmission"));
        this.isLoading = false;
      } catch(err){
        console.error(err);
      }    
    }
  }

  handleModalClick(evt) {
    const { label } = evt.target;
    if (label == "Close") {
      this.closeModal();
    } else if (label == "Next") {
      const allValid = [
        ...this.template.querySelectorAll(`[data-type="requestForm"]`)
      ].reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && (inputCmp.value || !inputCmp.required);
      }, true);

      if (!allValid) {
        return;
      }

      this.currStepLocal = this.currStepLocal + 1;
    } else if (label == "Previous") {
      this.currStepLocal = this.currStepLocal - 1;
    } else if (label == "Submit") {
      this.isLoading = true;
      this.handleSubmit();
    } else if (label == "Generate Document") {
      this.isLoading = true;
      this.template.querySelector("c-excel-generator").generateExcel();
    }
  }

  async handleSubmit() {
    //String requestType, Id dealId, Id cdId, String comments
    const requestType = this.selectedRequest.replaceAll(" ", "");
    const dealId = this.recordId;
    const cdId = this.docAttributes && this.docAttributes.contentDocumentId || null;
    const comments = this.formValues.hasOwnProperty("comments")
      ? this.formValues.comments
      : "";
    const inquiryType = this.formValues.hasOwnProperty("inquiryType")
      ? this.formValues.inquiryType
      : "";
    const to = this.selectedToId 
      ? this.titleOrders.find(t => t.Id === this.selectedToId)
      : null;
    
    const res = await sendRequest({
      requestType,
      dealId,
      cdId,
      comments,
      to,
      inquiryType
    });

    const resObj = JSON.parse(res);
    const isSuccess = resObj.result !== "FAIL";

    await LightningAlert.open({
      message: isSuccess ? resObj.message : resObj.errorMessage,
      theme: isSuccess ? "success" : "error", // a red theme intended for error states
      label: isSuccess ? "Success!" : "Error!" // this is the header text
    });

    if (isSuccess) {
      this.dispatchEvent(new CustomEvent("requestsubmission"));
      this.closeModal(true);
    } else {
      this.isLoading = false;
    }
  }

  async handleDocumentGeneration(evt) {
    const { fileName, base64Data } = evt.detail;

    const contentDocumentId = await saveGeneratedFile({
      fileName,
      base64Data,
      parentId: this.recordId
    });
    console.log(contentDocumentId);
    if (this.docAttributes) {
      this.contentDocumentIdsForDeletion = [
        ...this.contentDocumentIdsForDeletion,
        this.docAttributes.contentDocumentId
      ];
    }
    this.docAttributes = { fileName, base64Data, contentDocumentId };
    this.isLoading = false;
  }

  closeModal(isSubmissionSuccess = false) {
    this.template.querySelector("c-modal").closeModal();
    this.selectedRequest = "";
    this.currStepLocal = 1;
    if (this.docAttributes && !isSubmissionSuccess) {
      this.contentDocumentIdsForDeletion = [
        ...this.contentDocumentIdsForDeletion,
        this.docAttributes.contentDocumentId
      ];
    }
    this.docAttributes = null;
    this.formValues = {};
    this.isLoading = false;
  }

  handleUploadFinished(evt) {
    const { name, documentId } = evt.detail.files[0];
    if (this.docAttributes) {
      this.contentDocumentIdsForDeletion = [
        ...this.contentDocumentIdsForDeletion,
        this.docAttributes.contentDocumentId
      ];
    }

    this.docAttributes = {
      fileName: name,
      contentDocumentId: documentId
    };
  }

  get excelConfig() {
    return (
      this.selectedRequest &&
      this.excelConfigs.hasOwnProperty(this.selectedRequest) &&
      this.excelConfigs[this.selectedRequest]
    );
  }

  get excelFileName() {
    return (
      this.selectedRequest &&
      this.excelFileNames.hasOwnProperty(this.selectedRequest) &&
      this.excelFileNames[this.selectedRequest]
    );
  }

  get excelQueryString() {
    return (
      this.selectedRequest &&
      this.excelQueries.hasOwnProperty(this.selectedRequest) &&
      this.excelQueries[this.selectedRequest]
    );
  }

  get dataTapeConfig() {
    return {
      Asset_ID__c: "Asset ID",
      Property_Name__c: "Property Name (Parent Property)",
      APN__c: "APN",
      Property_Type__c: "Property Type",
      Name: "Address",
      City__c: "City",
      State__c: "State",
      ZipCode__c: "ZIP",
      County__c: "County",
      Number_of_Units__c: "# of Units",
      Number_of_Beds__c: "BD",
      Number_of_Bath__c: "BA",
      Square_Feet__c: "SF",
      No_of_Stories__c: "# of Stories",
      Year_Built__c: "Year Built",
      Air_Conditioning__c: "A/C",
      Pool__c: "Pool",
      Section_8__c: "Section 8",
      Condition__c: "Condition",
      Zoning_Compliance__c: "Legally Conforming",
      Acquisition_Date__c: "Acquisition Date",
      Acquisition_Price__c: "Acquisition Price",
      Acquisition_Type__c: "Acquisition Type",
      Transaction_Costs__c: "Transaction Costs",
      Rehab_Costs__c: "Rehab Costs",
      Rehab_Completion_Date__c: "Rehab Completion Date",
      Total_Basis__c: "Total Basis",
      Borrower_Opinion_of_Current_Value__c:
        "Borrower Opinion of Current Market Value",
      Calc_AveValue__c: "Red Bell Calc AveValue",
      Appraisal_Form__c: "Appraisal Form",
      BPO_Appraisal_Date__c: "Effective Date",
      Appraised_Value_Amount__c: "Appraisal Value",
      Currently_Leased__c: "Currently Leased? (Y/N)",
      Lease_Ready__c: "Lease Ready",
      Lease_Start_Date__c: "Lease Start Date",
      Lease_End_Date__c: "Lease End Date",
      Lease_Term__c: "Lease Term",
      Monthly_Rent__c: "Monthly Rent",
      Estimated_Rent__c: "Monthly Estimated Rent",
      Security_Deposit__c: "Security Deposit",
      Other_Income__c: "Other Income",
      Annual_HOA_Fee__c: "HOA",
      Special_Assesments_CFD_Mello_Roos_etc__c: "Special Assessments",
      Annual_Taxes__c: "Taxes",
      Annual_Insurance__c: "Insurance",
      Annual_Managment_Fee__c: "Property Management",
      Maintenance_Repairs__c: "Maintenance/ Repairs",
      Owner_Paid_Utilities__c: "Owner Paid Utilities",
      Annual_Landscaping_Expense__c: "Landscaping Expense",
      Other_Expenses__c: "Other Expenses",
      Lease_Up_Marketing__c: "Lease Up/Marketing",
      Vacancy_Repairs__c: "Vacancy Repairs/Maintenance",
      Credit_Loss__c: "Credit Loss",
      Annual_Total_Expenses__c: "Total Expenses",
      Cap_Ex_Reserves__c: "CapEx Reserves",
      Other_Reserves__c: "Other Reserves",
      Annual_NOI__c: "NOI",
      Property_Manager__c: "Assigned PM Company (By property)",
      Interior_Access_POC__c: "Interior Access POC",
      Interior_Access_POC_Phone__c: "Interior Access POC Phone",
      Interior_Access_POC_Email__c: "Interior Access POC Email",
      Existing_Debt__c: "Existing Debt",
      Asset_Maturity_Date_Override__c: "Date of Maturity",
      Current_Interest_Rate__c: "Interest Rate",
      Are_Payments_Current__c: "Are payments current",
      Refinance_Acquisition__c: "Refinance / Acquisition",
      ALA__c: "ALA",
      Appraisal_Replacement_Cost_Value__c: "Appraisal Replacement Cost Value"
    };
  }

  get excelConfigs() {
    return {
      "Quote Request": this.dataTapeConfig,
      "Order Inquiry": this.dataTapeConfig
    };
  }

  get excelFileNames() {
    return {
      "Quote Request": "datatape.xlsx",
      "Order Inquiry": "reviseddatatape.xlsx"
    };
  }

  get excelQueries() {
    return {
      "Quote Request": this.dataTapeQueryString,
      "Order Inquiry": this.dataTapeQueryString
    };
  }

  get acceptedFormats() {
    return !this.disallowAttachments &&
      this.selectedRequest &&
      acceptedFormatMap.hasOwnProperty(this.selectedRequest)
      ? acceptedFormatMap[this.selectedRequest]
      : [];
  }

  get dataTapeQueryString() {
    return `SELECT Id,${Object.keys(this.dataTapeConfig).join(
      ","
    )} FROM Property__c WHERE Deal__c = '${
      this.recordId
    }' AND Is_Sub_Unit__c = FALSE`;
  }

  flattenObj(ob) {
    // The object which contains the
    // final result
    let result = {};

    // loop through the object "ob"
    for (const i in ob) {
      // We check the type of the i using
      // typeof() function and recursively
      // call the function again
      if (typeof ob[i] === "object" && !Array.isArray(ob[i])) {
        const temp = this.flattenObj(ob[i]);
        for (const j in temp) {
          // Store temp in result
          result[i + "." + j] = temp[j];
        }
      }

      // Else store ob[i] in result directly
      else {
        result[i] = ob[i];
      }
    }
    return result;
  }
}

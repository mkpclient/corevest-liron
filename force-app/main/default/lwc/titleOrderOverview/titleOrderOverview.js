import deleteRecords from "@salesforce/apex/lightning_Util.deleteRecords";
import saveGeneratedFile from "@salesforce/apex/TitleOrder_LightningHelper.saveGeneratedFile";
import { api, LightningElement } from "lwc";
import sendRequest from "@salesforce/apex/TitleOrder_LightningHelper.sendRequest";
import LightningAlert from "lightning/alert";
import LightningConfirm from "lightning/confirm";
import retrieveSchemas from "@salesforce/apex/TitleOrder_LightningHelper.retrieveSchemas";
import cancelRequest from "@salesforce/apex/TitleOrder_LightningHelper.cancelRequest";
import queryTitleOrder from "@salesforce/apex/TitleOrder_LightningHelper.queryTitleOrder";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import SLDATAMAP from "@salesforce/resourceUrl/serviceLinkDataMapping";
import SLCONFIGS from "@salesforce/resourceUrl/serviceLinkConfigs";
import upsertRecord from "@salesforce/apex/lightning_Controller.upsertRecord";

const nextSteps = {
  Unordered: "Open a Quote Request to get started",
  Cancelled: "Open a Quote Request to get started",
  "Quote Requested":
    "No action is needed. Please wait for a response from service link.",
  "Quote Request Received":
    "Your quote has been received by servicelink. No action is currently required, but you can submit additional documents, cancel the request, or make an order inquiry.",
  "Cancel Requested":
    "A cancel request is currently being processed. Please wait for confirmation from ServiceLink before submitting a new Quote Request.",
  "Order Change Requested":
    "There is an active order change request for this loan awaiting confirmation from the vendor.",
  "Order Change Confirmed":
    "A recent order change request has been accepted by the vendor."
};
export default class TitleOrderOverview extends LightningElement {
  @api recordId;
  @api vendorType;

  titleOrder;
  selectedPropertyTitle = {};
  selectedPtId;
  comboboxSchemas = {};
  formConfigs = {};
  selectedRequestLocal = "";
  currStepLocal = 1;
  formValues = {};
  docAttributes;
  isLoading = true;
  contentDocumentIdsForDeletion = [];
  fileConfigs = {};
  dataTapeConfig = {};
  inquiryType;
  propTitleSelections = [];

  get showQuoteAccepted() {
    return (
      this.titleOrder && this.titleOrder.Status__c == "Quote Response Received"
    );
  }

  get showOrderInquiry() {
    return (
      this.titleOrder &&
      ![
        "Quote Requested",
        "Quote Received Success",
        "Quote Received Failed",
        "Cancelled",
        "Cancel Requested",
        "Cancel Request Failed"
      ].includes(this.titleOrder.Status__c)
    );
  }

  get disallowAttachments() {
    return (
      (this.selectedRequest !== "QuoteRequest" &&
        this.selectedRequest !== "OrderInquiry" && this.selectedRequest !== "QuoteAccepted") ||
      (this.selectedRequest == "OrderInquiry" &&
        this.inquiryType !== "REVISEDQUO")
    );
  }

  get downloadLink() {
    return (
      this.docAttributes &&
      this.docAttributes.contentDocumentId &&
      "/sfc/servlet.shepherd/document/download/" +
        this.docAttributes.contentDocumentId +
        "?operationContext=S1"
    );
  }

  get selectedRequest() {
    return this.selectedRequestLocal;
  }
  set selectedRequest(val) {
    this.selectedRequestLocal = val;
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

        if (this.titleOrder.hasOwnProperty(dataName)) {
          value = this.titleOrder[dataName];
        }
        if (this.comboboxSchemas.hasOwnProperty(dataName)) {
          options = this.comboboxSchemas[dataName];
        }
        disabled = disabled || this.isPreviewStep;
        return { ...c, key: i, value, disabled, options };
      })
    );
  }

  async connectedCallback() {
    const response = await fetch(SLDATAMAP);
    const tempData = await response.json();

    const configsRes = await fetch(SLCONFIGS);
    const configData = await configsRes.json();

    this.formConfigs = configData.formConfigs;
    this.fileConfigs = configData.fileConfigs;
    this.dataTapeConfig = configData.dataTapeRows;

    const res = await queryTitleOrder({
      dealId: this.recordId,
      vendorType: this.vendorType
    });
    console.log("Query title order result: ");
    console.log(res);
    if (res) {
      console.log(res);
      this.titleOrder = res;
      if(res.Property_Titles__r) {
        this.propTitleSelections = res.Property_Titles__r.map(pt => ({
          label: pt.Property__r.Name,
          value: pt.Property__c
        }))
      }
    }
    this.isLoading = false;

    // const schemas = await retrieveSchemas();
    // const tempData = {};
    // for (const key in schemas) {
    //   const vals = schemas[key];
    //   tempData[key] = vals.map((v) => ({
    //     label: v,
    //     value: v
    //   }));
    // }

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

    this.selectedPtId = value;

    this.selectedPropertyTitle = this.flattenObj(
      this.titleOrder.Property_Titles__r.find((to) => to.Id === value)
    );
  }

  handleChange(evt) {
    const { value } = evt.detail;
    const { name } = evt.target.dataset;
    console.log(name, value);
    this.formValues[name] = value;
    if(name === "inquiryType") {
      this.inquiryType = value;
    }
  }

  handleClick(evt) {
    const req = evt.target.title;

    if (req === "CancelRequest") {
      this.handleCancel();
    } else {
      this.selectedRequest = req;
      console.log(this.selectedRequest);
      this.template.querySelector("c-modal").openModal();
    }
  }

  async handleCancel() {
    const result = await LightningConfirm.open({
      message:
        "Would you like to cancel this request? This is an irreversible request.",
      label: "Request Cancelation",
      theme: "warning"
    });

    if (result) {
      this.isLoading = true;
      try {
        await cancelRequest({ titleOrderId: this.titleOrder.Id });
        await LightningAlert.open({
          message: "Your cancel request has been successfully submitted.",
          theme: "success",
          label: "Success"
        });
        this.dispatchEvent(new CustomEvent("requestsubmission"));
        this.isLoading = false;
      } catch (err) {
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
    const allValid = [
      ...this.template.querySelectorAll(`[data-type="requestForm"]`)
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && (inputCmp.value || !inputCmp.required);
    }, true);

    if (!allValid) {
      return;
    }

    const requestType = this.selectedRequest.replaceAll(" ", "");
    const dealId = this.recordId;
    const cdId =
      (this.docAttributes && this.docAttributes.contentDocumentId) || null;

    if (this.acceptedFormats.length > 0 && !cdId) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Document Missing",
          message:
            "Please attach or generate (if enabled) a document before proceding.",
          variant: "error"
        })
      );
      return;
    }
    const comments = this.formValues.hasOwnProperty("comments")
      ? this.formValues.comments
      : "";
    const inquiryType = this.formValues.hasOwnProperty("inquiryType")
      ? this.formValues.inquiryType
      : "";
    const to = this.titleOrder;

    if(requestType == "QuoteAccepted" && this.formValues.hasOwnProperty("Anticipated_Close_Date__c")) {
      await upsertRecord({ record: {
        sobjectType: "Title_Order__c",
        Id: to.Id,
        Anticipated_Close_Date__c: this.formValues.Anticipated_Close_Date__c
      }});
    }

    let propIds = [];
    let propTitleIds = [];

    const res = await sendRequest({
      requestType,
      dealId,
      cdId,
      comments,
      to,
      inquiryType,
      propIds,
      propTitleIds
    });
    console.log(res);
    const resObj = JSON.parse(res);
    const isSuccess = resObj.result !== "FAIL";

    await LightningAlert.open({
      message: isSuccess ? resObj.message : resObj.errorMessage,
      theme: isSuccess ? "success" : "error", // a red theme intended for error states
      label: isSuccess ? "Success!" : "Error!" // this is the header text
    });

    if (isSuccess) {
      this.dispatchEvent(new CustomEvent("requestsubmission"));
      this.connectedCallback();
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
      this.fileConfigs.hasOwnProperty(this.selectedRequest) &&
      this.fileConfigs[this.selectedRequest].hasOwnProperty("fileName") &&
      this.fileConfigs[this.selectedRequest].fileName
    );
  }

  get excelQueryString() {
    return (
      this.selectedRequest &&
      this.excelQueries.hasOwnProperty(this.selectedRequest) &&
      this.excelQueries[this.selectedRequest]
    );
  }

  get excelConfigs() {
    return {
      QuoteRequest: this.dataTapeConfig,
      OrderInquiry: this.dataTapeConfig,
      QuoteAccepted: this.dataTapeConfig
    };
  }

  get excelQueries() {
    return {
      QuoteRequest: this.dataTapeQueryString,
      OrderInquiry: this.dataTapeQueryString,
      QuoteAccepted: this.dataTapeQueryString
    };
  }

  get acceptedFormats() {
    return !this.disallowAttachments &&
      this.selectedRequest &&
      this.fileConfigs.hasOwnProperty(this.selectedRequest) &&
      this.fileConfigs[this.selectedRequest].hasOwnProperty("acceptedFormats")
      ? this.fileConfigs[this.selectedRequest].acceptedFormats
      : [];
  }

  get dataTapeQueryString() {
    return `SELECT Id,${Object.keys(this.dataTapeConfig).join(
      ","
    )} FROM Property__c WHERE Deal__c = '${
      this.recordId
    }' AND Is_Sub_Unit__c = FALSE AND Status__c != 'Inactive' AND Status__c != 'Cancelled'`;
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
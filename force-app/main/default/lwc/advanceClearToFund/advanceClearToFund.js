import { LightningElement, api, track } from "lwc";
import init from "@salesforce/apex/AdvanceClearToFundController.init";
import { NavigationMixin } from "lightning/navigation";
import {
  createMessageContext,
  releaseMessageContext,
  APPLICATION_SCOPE,
  subscribe,
  unsubscribe
} from "lightning/messageService";
import POVMC from "@salesforce/messageChannel/documentChannel__c";

export default class AdvanceClearToFund extends NavigationMixin(
  LightningElement
) {
  @api recordId;

  availableFieldNames = {
    advance: {
      approval: "Closing_Funds_Checklist__c",
      comments: "Closing_Funds_Checklist_Comments__c"
    },
    manager: {
      approval: "Manager_Approved__c",
      comments: "Manager_Approval_Comments__c"
    },
    evidenceOfInsurance: {
      approval: "Evidence_of_Insurance_Approved__c",
      comments: "Evidence_of_Insurance_Approval_Comments__c"
    },
    floodCertificate: {
      approval: "Flood_Certificate_Approved__c",
      comments: "Flood_Certificate_Approval_Comments__c"
    }
  };

  selectedFieldNames;
  selectedDocumentInfoId = "";
  fundCheckList;
  advanceId = "";

  connectedCallback() {
    console.log(this.recordId);
    init({ advanceId: this.recordId })
      .then((response) => {
        console.log(JSON.parse(response));
        this.fundCheckList = JSON.parse(response);
        this.handleSubscribe();
      })
      .catch((err) => {
        err.body.pageErrors.forEach((error) => {
          console.error(error.statusCode + ": " + error.message);
        });
      });
  }

  handleGoToUser(event) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: event.target.value,
        objectApiName: "User",
        actionName: "view"
      }
    });
  }

  @track subscription = null;

  context = createMessageContext();

  handleSubscribe() {
    if (this.subscription) {
      return;
    }
    this.context = createMessageContext();
    this.subscription = subscribe(
      this.context,
      POVMC,
      (message) => {
        this.handleMessage(message);
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  handleMessage(event) {
    if (event) {
      let message = event.messageBody;
      let source = event.source;
      console.log({
        message: message,
        source: source
      });
      this.connectedCallback();
    }
  }

  handleUnsubscribe() {
    unsubscribe(this.subscription);
    this.subscription = undefined;
    releaseMessageContext(this.context);
  }

  get subscribeStatus() {
    return this.subscription ? "TRUE" : "FALSE";
  }

  disconnectedCallback() {
    this.handleUnsubscribe();
  }

  openFilesModal(event) {
    const title = event.target.getAttribute("title");

    this.template
      .querySelector("c-advance-clear-to-fund-documents")
      .openModal(this.fundCheckList[title].files);

    //   const fileIds = [];
    //   this.fundCheckList[title].files.forEach((file) => {
    //     fileIds.push(file.Attachment_Id__c);
    //   });

    //   console.log(fileIds.join(","));

    //   this[NavigationMixin.Navigate]({
    //     type: "standard__namedPage",
    //     attributes: {
    //       pageName: "filePreview"
    //     },
    //     state: {
    //       recordIds: fileIds.join(",")
    //     }
    //   });
  }

  handleSelect(event) {
    console.log("handle select");
    console.log(event.detail.value);
    console.log(this.fundCheckList);
    console.log(event.detail.value);
    if (event.detail.value.split("_")[0] === "modal") {
      this.advanceId = this.recordId;
      this.selectedFieldNames = Object.assign({}, this.availableFieldNames[event.detail.value.split("_")[1]]);
    } else {
      this.selectedDocumentInfoId =
        this.fundCheckList[event.detail.value].docInfoId;
    }
    console.log(this.advanceId);
    console.log(this.selectedDocumentInfoId);

    this.template.querySelector("c-modal").openModal();
  }

  closeModal(event) {
    this.template.querySelector("c-modal").closeModal();
    this.selectedDocumentInfoId = "";
    this.advanceId = "";
    this.selectedFieldNames = "";
  }

  save(event) {
    const inputs = this.template.querySelectorAll("lightning-input-field");
    // console.log(name)
    const fields = {};
    // fields[field.fieldName] = field.value;
    inputs.forEach((input) => {
      fields[input.fieldName] = input.value;
    });
    console.log(fields);

    this.template.querySelector("lightning-record-edit-form").submit(fields);
  }

  handleSuccess(event) {
    this.selectedDocumentInfoId = "";
    this.advanceId = "";
    this.template.querySelector("c-modal").closeModal();

    this.connectedCallback();
  }
}
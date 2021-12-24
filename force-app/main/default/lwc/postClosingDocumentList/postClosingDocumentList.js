import { LightningElement, api } from "lwc";

import query from "@salesforce/apex/lightning_Util.query";
import upsert from "@salesforce/apex/lightning_Util.upsertRecords";
export default class PostClosingDocumentsList extends LightningElement {
  @api recordId;

  documents;
  loading = false;
  editMode = false;
  isLoading = true;

  params;
  selectedDate;
  selectedIndex;

  recordedDocument = false;
  recorded = false;

  @api clickMe() {
    console.log("clicked");
  }

  connectedCallback() {
    this.queryDocuments();
    // this.queryUser();
  }

  queryDocuments() {
    // let queryString = `SELECT Id, Deal__r.RecordType.Name, Account__c, Contact__c, Vendor_Type__c, Order_Date__c, Completed_Date__c, Account__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__r.Name, Contact__r.Email`;
    // queryString += ` FROM Deal_Contact__c`;
    // queryString += ` WHERE Deal__c ='${this.recordId}'`;
    // queryString += ` AND Deal_Contact_Type__C = 'Vendor'`;

    let queryString = `SELECT Id, Attachment_Id__c, File_Name__c, Reviewed_On__c, Reviewed_By__c, Reviewed_By__r.Name, Reviewed__c,`;
    queryString += ` Recorded_Date__c, Book__c, Page__c, Instrument_Number__c, Recording_Info__c, `;
    queryString +=
      " Post_Closing_Item__r.Recorded_Document__c, Post_Closing_Item__r.Recorded__c ";
    queryString += ` FROM Deal_Document__c`;
    queryString += ` WHERE Post_Closing_Item__c = '${this.recordId}'`;

    console.log(queryString);
    query({ queryString: queryString })
      .then((results) => {
        let v = JSON.parse(JSON.stringify(results));
        let documents = [];
        console.log(v);
        this.recordedDocument = v[0].Post_Closing_Item__r.Recorded_Document__c;
        this.recorded = v[0].Post_Closing_Item__r.Recorded__c;

        v.forEach((document) => {
          document.original = Object.assign({}, document);
          // document.original
          documents.push(document);
        });

        this.documents = documents;
        this.editMode = false;
        this.isLoading = false;
      })
      .catch((error) => {
        console.log(error);
      });
  }

  // queryUser() {
  //   getUser({})
  //     .then((results) => {
  //       console.log(results);
  //       let senderEmails = [{ label: results.Email, value: results.Id }];
  //       this.senderEmails = senderEmails;
  //       //this.user = results;
  //     })
  //     .catch((error) => {
  //       console.log(error);
  //       console.log("user error");
  //     });
  // }

  get showAdditionalFields() {
    return true;
  }

  get documentList() {
    let documents = JSON.parse(JSON.stringify(this.documents));
    //console.log(vendors);
    documents.forEach((document) => {
      let styleClass = {
        Reviewed_By__c: "slds-cell-edit",
        Reviewed_On__c: "slds-cell-edit",
        // Book__c: "slds-cell-edit",
        Recorded_Date__c: "slds-cell-edit",
        // Page__c: "slds-cell-edit",
        // Instrument_Number__c: "slds-cell-edit"
        Recording_Info__c: "slds-cell-edit"
      };
      let urls = {};
      for (let key in document) {
        if (document.original.hasOwnProperty(key)) {
          // changed[key] = vendor.original[key] !== vendor[key];
          styleClass[key] =
            document.original[key] !== document[key]
              ? "slds-is-edited slds-cell-edit"
              : "slds-cell-edit";
        } else if (document[key]) {
          styleClass[key] = "slds-is-edited slds-cell-edit";
        } else {
          styleClass[key] = "slds-cell-edit";
        }

        if (!document.Reviewed_By__r) {
          document.Reviewed_By__r = {};
        }
      }

      document.urls = urls;
      document.styleClass = styleClass;
    });

    console.log("documents= ", documents);
    return documents;
  }

  toggleEdit() {
    this.editMode = !this.editMode;
  }

  get isViewMode() {
    return !this.editMode;
  }

  get isEditMode() {
    return this.editMode;
  }

  cancel() {
    this.toggleEdit();
  }

  save() {
    console.log("save");
    this.isLoading = true;

    let documents = [];
    let recorded = true;
    this.documents.forEach((document) => {
      documents.push({
        sobjectType: "Deal_Document__c",
        Id: document.Id ? document.Id : null,
        // Deal__c: document.Deal__c,
        Recorded_Date__c: document.Recorded_Date__c
          ? document.Recorded_Date__c
          : "",
        // Page__c: document.Page__c ? document.Page__c : "",
        // Book__c: document.Book__c ? document.Book__c : "",
        // Instrument_Number__c: document.Instrument_Number__c
        //   ? document.Instrument_Number__c
        //   : "",
        Recording_Info__c: document.Recording_Info__c
        ? document.Recording_Info__c
        : ""
      });

      if (
        // !document.Page__c ||
        // !document.Recorded_Date__c ||
        // !document.Book__c ||
        // !document.Instrument_Number__c
        !document.Recorded_Date__c ||
        !document.Recording_Info__c
      ) {
        recorded = false;
      }
    });
    console.log(documents);

    let updateDealDocument = false;
    if (this.recordedDocument && this.recorded != recorded) {
      // if()
      updateDealDocument = true;
      documents.push({
        sobjectType: "Post_Closing_Item__c",
        Id: this.recordId,
        Recorded__c: recorded
      });
    }

    upsert({ records: documents })
      .then((result) => {
        this.queryDocuments();
        this.isLoading = false;

        if (updateDealDocument) {
          const initEvent = new CustomEvent("update", {
            detail: {}
          });
          console.log(initEvent);
          this.dispatchEvent(initEvent);
        }
      })
      .catch((error) => {
        console.log(error);
        this.isLoading = false;
      });
  }

  updateValue(event) {
    let fieldName = event.target.getAttribute("data-name");
    let index = event.target.getAttribute("data-index");

    let documents = JSON.parse(JSON.stringify(this.documents));
    documents[index][fieldName] = event.target.value;

    this.documents = documents;
  }

  refresh() {
    this.isLoading = true;

    this.queryDocuments();
    //return refreshApex(this.results);
  }

  checkAll() {
    console.log("checkall");
  }

  closeModal() {
    this.template.querySelector("[data-name='selectedTemplate']").value = "";
    this.template.querySelector("c-modal").toggleModal();
  }

  @api
  review() {
    this.isLoading = true;
    console.log("review");
    let documents = JSON.parse(JSON.stringify(this.documents));
    let toReview = [];
    this.template.querySelectorAll(".checkbox").forEach((checkbox) => {
      let index = checkbox.getAttribute("data-index");
      if (checkbox.checked && !documents[index].Reviewed__c) {
        toReview.push({
          sobjectType: "Deal_Document__c",
          Reviewed__c: true,
          Id: documents[index].Id
        });
      }
      // console.log(checkbox.checked);
    });

    console.log(toReview);

    if (toReview.length > 0) {
      //do save

      upsert({ records: toReview })
        .then((results) => {
          this.isLoading = false;
          this.queryDocuments();
        })
        .catch((error) => {
          this.isLoading = false;
          console.log(error);
        });
    }
  }

  // openModal(event) {
  //   console.log(event.target.getAttribute("data-index"));

  //   this.template.querySelector("c-modal").showSpinner();
  //   this.template.querySelector("c-modal").toggleModal();

  //   let index = event.target.getAttribute("data-index");
  //   //console.log(this.vendors[index]);
  //   // let toAddress = this.template.querySelector(
  //   //   "lightning-input[data-name='toAddress']"
  //   // );
  //   // toAddress.value = this.vendors[index].Contact__r.Email;
  //   // toAddress.title = this.vendors[index].Contact__c;

  //   let params = {
  //     toAddressEmail: this.vendors[index].Contact__r.Email,
  //     recipientId: this.vendors[index].Contact__c,
  //     recordType: this.vendors[index].Deal__r.RecordType.Name
  //   };

  //   this.queryTemplates(event.target.getAttribute("data-index"), params);
  // }
}
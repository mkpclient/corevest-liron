import { LightningElement, wire } from "lwc";

import initScreen from "@salesforce/apex/LoanVersionValidatorController.initScreen";
import query from "@salesforce/apex/lightning_Util.query";
import saveFile from "@salesforce/apex/documentUploader_Controller.saveFile";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { parseExpression } from "c/utils";

import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";

import validator from "@salesforce/messageChannel/LoanVersionValidator__c";

export default class DocumentVersionValidator extends LightningElement {
  subscription = null;
  selectedLoanVersion = {
    Borrower__c: "TEST"
  };
  //loanVersionInput = {};

  recordId = "";
  sobjectType = "";
  //attachmentId = "";
  //docStructureId = "";
  //loanVersionOptions = [];

  recordOptions = [];
  selectedRecordIds = [];

  validationInputs = {};

  sobjectFields = {};
  // selectedLoanVersionId = "";

  recordInputs = {};
  // sobjectFields = {};

  file = {
    attachmentId: "00P2C000006YwwyUAC",
    documentType: "Loan Agreement",
    missingType: false,
    name: "LoanAgreement (6).docx",
    requireValidations: true,
    section: "Loan Document - Principle Loan Documents ",
    size: 155161,
    status: "",
    typeOptions: [""],
    uploaded: false
  };

  isLoading = false;

  @wire(MessageContext)
  messageContext;

  fields = [];
  fieldSections = [];

  constructor() {
    super();
  }
  connectedCallback() {
    //console.log("documentVersionValidator init");

    this.subscribeMessageChannel();
  }

  init = async (docStructureId) => {
    console.log("init");

    const fieldSections = JSON.parse(
      await initScreen({ docStructureId: docStructureId })
    );

    //console.log(fields);

    let sobjectFields = {};
    let recordInputs = {};

    console.log("field sections=>", fieldSections);

    fieldSections.forEach((fieldSection, index) => {
      fieldSection.showHeader = fieldSection.headerLabel ? true : false;
      fieldSection.index = index + "-section";
      fieldSection.fields.forEach((field, findex) => {
        field.formatter = "";
        field.index =
          findex + "-" + fieldSection.headerLabel + "-" + field.fieldName;
        if (field.fieldType === "currency") {
          field.fieldType = "number";
          field.formatter = "currency";
        } else if (field.fieldType === "percent") {
          field.fieldType = "number";
          field.formatter = "percent-fixed";
        }

        const sobjectType = field.sobjectType;
        if (!sobjectFields.hasOwnProperty(sobjectType)) {
          sobjectFields[sobjectType] = [];
          recordInputs[sobjectType] = null;
        }

        if (sobjectFields[sobjectType].indexOf(field.fieldName) === -1) {
          sobjectFields[sobjectType].push(field.fieldName);
        }
      });
    });

    if (
      sobjectFields["Loan_Version__c"] &&
      sobjectFields["Loan_Version__c"].indexOf("Interest_Rate_Type__c") === -1
    ) {
      sobjectFields["Loan_Version__c"].push("Interest_Rate_Type__c");
    }

    if (sobjectFields["Opportunity"]) {
      if (sobjectFields["Opportunity"].indexOf("LOC_Loan_Type__c") === -1) {
        sobjectFields["Opportunity"].push("LOC_Loan_Type__c");
      }

      if (sobjectFields["Opportunity"].indexOf("Product_Sub_Type__c") === -1) {
        sobjectFields["Opportunity"].push("Product_Sub_Type__c");
      }
    }

    //console.log("sobjectFields=> ", sobjectFields);
    this.sobjectFields = sobjectFields;

    //console.log("recordInputs=>", recordInputs);

    // console.log("fields=>", fields);
    // this.fields = []; //fields;
    this.fieldSections = fieldSections;

    this.queryRecords();

    //this.fields
  };

  parseFieldValue(obj, fieldPath) {
    var fields = fieldPath.split(".");

    var value = null;

    if (obj.hasOwnProperty(fields[0])) {
      value = obj[fields[0]];

      if (fields.length > 1) {
        for (var i = 1; i < fields.length; i++) {
          if (value != null && value.hasOwnProperty(fields[i])) {
            value = value[fields[i]];
          } else {
            value = null;
            break;
          }
        }
      }
    }

    return value;
  }

  get fieldValidations() {
    // const fields = JSON.parse(JSON.stringify(this.fields));

    const fieldSections = JSON.parse(JSON.stringify(this.fieldSections));

    fieldSections.forEach((fieldSection, index) => {
      fieldSection.fields.forEach((field, findex) => {
        field.validated = false;

        if (field.checkOnly) {
          //console.log(field.fieldName);
          //console.log(this.selectedLoanVersion);

          const obj = this.recordInputs[field.sobjectType];

          if (obj) {
            field.orignalValue = this.parseFieldValue(obj, field.fieldName);
          }

          // this.recordInputs[field.sobjectType][
          //   field.fieldName
          // ];
        }

        field.validated = this.checkFieldValidation(field);

        //
      });
    });

    // console.log("--fields--");
    // console.log(fields);

    return fieldSections;
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  clearAllData() {
    this.recordOptions = [];
    this.selectedRecordIds = [];
    this.validationInputs = {};
    this.sobjectFields = {};
    this.recordInputs = {};
    this.recordId = "";
    this.sobjectType = "";
  }

  disconnectedCallback() {
    this.clearAllData();
    this.unsubscribeToMessageChannel();
  }

  handleMessage(message) {
    console.log("received message");
    console.log(message);

    this.file = message.file;
    this.recordId = message.recordId;
    this.sobjectType = message.sobjectType;

    //console.log(this.recordId);

    // this.queryLoanVersions();
    this.init(this.file.docStructureId);

    this.template.querySelector("c-modal").toggleModal();
  }

  updateValue(event) {
    // const loanVersion = JSON.parse(JSON.stringify(this.loanVersionInput));
    const validationInputs = JSON.parse(JSON.stringify(this.validationInputs));
    const fieldName = event.target.getAttribute("data-name");
    const sobjectType = event.target.getAttribute("data-sobject");
    if (event.target.type === "checkbox") {
      // console.log(event.target.checked);
      // console.log(event.target.getAttribute("data-name"));
      // loanVersion[event.target.getAttribute("data-name")] =
      //   event.target.checked;

      validationInputs[sobjectType][fieldName] = event.target.checked;
    } else {
      validationInputs[sobjectType][fieldName] = event.target.value;
    }
    // console.log(loanVersion);
    this.validationInputs = validationInputs;
  }

  subscribeMessageChannel() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.messageContext,
      validator,
      (message) => {
        this.handleMessage(message);
      },
      { scope: APPLICATION_SCOPE }
    );
  }

  get subscribeStatus() {
    return this.subscription != null ? "True" : "False";
  }

  checkFieldValidation(field) {
    let validated = false;
    const fieldName = field.fieldName;
    // const recor

    if (!this.recordInputs[field.sobjectType]) {
      return false;
    }

    if (!field.isDisplayed) {
      return true;
    }

    let targetVal = this.recordInputs[field.sobjectType][fieldName];
    let inputVal = this.validationInputs[field.sobjectType][fieldName];

    if (field.checkOnly) {
      validated = inputVal;
    } else {
      if (field.fieldType === "number") {
        targetVal = parseFloat(targetVal);
        inputVal = parseFloat(inputVal);
      }

      if (targetVal === inputVal) {
        validated = true;
      }
    }

    return validated;
  }

  calculateValidated() {
    let validated = true;
    // this.fields.forEach((field) => {
    //   const fieldValidated = this.checkFieldValidation(field);

    //   console.log("field=>", field.fieldName);
    //   console.log("isValidated=>", fieldValidated);
    //   if (!fieldValidated) {
    //     validated = false;
    //     //break;
    //   }
    //});

    console.log(this.fieldSections);
    if (this.fieldSections && this.fieldSections.length > 0) {
      this.fieldSections.forEach((fieldSection) => {
        fieldSection.fields.forEach((field) => {
          const fieldValidated = this.checkFieldValidation(field);

          // console.log("field=>", field.fieldName);
          // console.log("isValidated=>", fieldValidated);
          if (!fieldValidated) {
            validated = false;
            //break;
          }
        });
      });
    } else {
      return false;
    }

    return validated;
  }

  get isValidated() {
    return this.calculateValidated();
  }

  get allowSave() {
    // return this.isLoading;
    const isValidated = this.calculateValidated();
    const isLoading = this.isLoading;

    //console.log("isValidated=", isValidated);

    return !isValidated && !isLoading;
  }

  queryRecords = async () => {
    let sobjectFields = this.sobjectFields;

    let queryString = `SELECT Id, `;
    if (sobjectFields.hasOwnProperty("Opportunity")) {
      queryString += sobjectFields["Opportunity"].join(", ");
    }

    if (sobjectFields.hasOwnProperty("Loan_Version__c")) {
      queryString += `, (SELECT Id, Full_Name__c, ${sobjectFields[
        "Loan_Version__c"
      ].join(
        ","
      )} FROM Loan_Versions__r WHERE RecordType.DeveloperName = 'Loan_Agreement' Order By CreatedDate ASC)`;
      // queryString += `(SELECT Id, Name, Full_Name__c FROM Loan_Versions__r WHERE RecordType.DeveloperName = 'Loan_Agreement')`;
    }

    if (sobjectFields.hasOwnProperty("Advance__c")) {
      queryString += `, (SELECT Id, Name, ${sobjectFields["Advance__c"].join(
        ","
      )} FROM Advances__r)`;
    }

    queryString += ` FROM Opportunity WHERE Id = '${this.recordId}'`;

    //c/vendorEntityListconsole.log(queryString);

    const deal = await query({ queryString });

    console.log("queried deal=>", deal);
    console.log("sobjectFields=>", sobjectFields);
    let recordOptions = [];
    let recordInputs = { Opportunity: deal[0] };
    let validationInputs = { Opportunity: {} };

    // sobjectFields.forEach((field) => {
    //   if (field.contains(".")) {
    //     const vals = field.split(".");
    //     if (deal[0].hasOwnProperty(vals[0])) {
    //       deal[0][vals[0]] = {};
    //     }
    //   }
    // });

    if (
      sobjectFields.hasOwnProperty("Loan_Version__c") &&
      deal[0].hasOwnProperty("Loan_Versions__r") &&
      deal[0].Loan_Versions__r.length > 0
    ) {
      let obj = {
        label: "Select Loan Version",
        key: "Loan_Versions__r",
        sobjectType: "Loan_Version__c",
        options: [{ label: "", value: "" }]
      };

      deal[0].Loan_Versions__r.forEach((loanVersion) => {
        obj.options.push({
          value: loanVersion.Id,
          label: loanVersion.Full_Name__c
        });
      });

      recordOptions.push(obj);

      recordInputs["Loan_Version__c"] = null;
      validationInputs["Loan_Version__c"] = {};
    }

    if (
      sobjectFields.hasOwnProperty("Advance__c") &&
      deal[0].hasOwnProperty("Advances__r") &&
      deal[0].Advances__r.length > 0
    ) {
      let obj = {
        label: "Select Advance",
        key: "Advances__r",
        sobjectType: "Advance__c",
        options: [{ label: "", value: "" }]
      };

      deal[0].Advances__r.forEach((adv) => {
        obj.options.push({
          value: adv.Id,
          label: adv.Full_Name__c
        });
      });

      recordOptions.push(obj);

      recordInputs["Advance__c"] = null;
      validationInputs["Advance"] = {};
    }

    const fieldSections = JSON.parse(JSON.stringify(this.fieldSections));
    fieldSections.forEach((section) => {
      section.fields.forEach((field) => {
        if (field.sobjectType === "Opportunity") {
          // console.log(field.filters);
          //let isDisplayed = true;
          // field.filters.forEach((filter) => {
          //   const record = recordInputs["Opportunity"];
          //   const result = this.parseExpression(record, filter);

          //   if (!result) {
          //     isDisplayed = false;
          //   }
          // });

          field.isDisplayed = field.filter
            ? parseExpression(field.filter, recordInputs["Opportunity"])
            : true;
        }
      });
    });

    // console.log(deal);
    this.fieldSections = fieldSections;
    this.recordOptions = recordOptions;
    this.recordInputs = recordInputs;
    this.validationInputs = validationInputs;
    console.log("--recordOptions--", recordOptions);
    console.log("--fieldsections--", fieldSections);

    // console.log(deal);
  };

  // parseExpression(record, filters) {
  //   const fieldName = filters[0];
  //   const operand = filters[1];
  //   const filterValue = filters[2];
  //   let value = record[fieldName];

  //   let result = false;

  //   // if (fieldType === "number") {
  //   //   value = parseFloat(value);
  //   // }

  //   console.log(`Actual: ${fieldName}=${value}`);
  //   console.log(`Filter: ${fieldName}${operand}${filterValue}`);

  //   switch (operand) {
  //     case "=":
  //       result = value == filterValue;
  //       break;

  //     case "<":
  //       result = value < filterValue;
  //       break;
  //     case "<=":
  //       result = value <= filterValue;
  //       break;
  //     case ">":
  //       result = value > filterValue;
  //       break;
  //     case ">=":
  //       result = value >= filterValue;
  //       break;
  //     default:
  //       result = false;
  //   }

  //   return result;
  // }

  // queryLoanVersions = async () => {
  //   let queryString = `SELECT Id, Name, Full_Name__c FROM Loan_Version__c`;
  //   queryString += ` WHERE Deal__c = '${this.recordId}' AND RecordType.DeveloperName = 'Loan_Agreement'`;
  //   queryString += ` ORDER BY CreatedDate ASC`;

  //   const loanVersions = await query({ queryString });

  //   console.log(loanVersions);

  //   const options = [{ label: "", value: "" }];

  //   loanVersions.forEach((lv) => {
  //     options.push({ label: lv.Full_Name__c, value: lv.Id });
  //   });

  //   // console.log(options);

  //   this.loanVersionOptions = options;
  // };

  selectRecord(event) {
    console.log("select record event");
    console.log(event);

    let recordId = event.target.value;
    let key = event.target.name;
    let sobjectType = event.target.getAttribute("data-id");
    console.log(recordId);
    console.log(key);
    console.log(sobjectType);

    let recordInputs = JSON.parse(JSON.stringify(this.recordInputs));
    if (recordId) {
      recordInputs.Opportunity[key].forEach((record) => {
        if (record.Id === recordId) {
          recordInputs[sobjectType] = record;
        }
      });

      const fieldSections = JSON.parse(JSON.stringify(this.fieldSections));
      fieldSections.forEach((section) => {
        section.fields.forEach((field) => {
          // let isDisplayed = true;
          if (field.sobjectType === sobjectType) {
            // console.log(field.filters);
            let isDisplayed = true;
            // field.filters.forEach((filter) => {
            //   const record = recordInputs[sobjectType];
            //   //const fieldType = field.fieldType;
            //   const result = this.parseExpression(record, filter);

            //   if (!result) {
            //     isDisplayed = false;
            //   }
            // });

            field.isDisplayed = field.filter
              ? parseExpression(field.filter, recordInputs[sobjectType])
              : true;
          }
        });
      });
      console.log("--fieldSections--", fieldSections);
      this.fieldSections = fieldSections;
    } else {
      recordInputs[sobjectType] = null;
    }

    console.log(recordInputs);

    this.recordInputs = recordInputs;
  }

  // selectLoanVersion(event) {
  //   this.selectedLoanVersionId = event.target.value;
  //   this.queryLoanVersion();
  // }

  // queryRecord = async () => {};

  // queryLoanVersion = async () => {
  //   if (!this.selectedLoanVersionId) {
  //     this.selectedLoanVersion = {};
  //     return;
  //   }

  //   const fields = [];

  //   this.fields.forEach((field) => {
  //     fields.push(field.fieldName);
  //   });

  //   let queryString = `SELECT Id, Name, ${fields.join(
  //     ","
  //   )} FROM Loan_Version__c`;
  //   queryString += ` WHERE Id = '${this.selectedLoanVersionId}'`;

  //   const results = await query({ queryString });

  //   this.selectedLoanVersion = results[0];
  //   console.log(this.selectedLoanVersion);
  // };

  get showInputs() {
    let show = true;
    let recordInputs = this.recordInputs;

    if (recordInputs && Object.keys(recordInputs).length > 0) {
      Object.keys(recordInputs).forEach((key) => {
        if (recordInputs[key] === null) {
          show = false;
        }
      });
    } else {
      show = false;
    }

    // if (this.selectedLoanVersion.Id) {
    //   show = true;
    // }

    return show;
  }

  closeModal(event) {
    this.clearAllData();
    this.template.querySelector("c-modal").toggleModal();
  }

  save() {
    this.isLoading = true;
    this.template.querySelector("c-modal").showSpinner();

    saveFile({
      fileJSON: JSON.stringify(this.file),
      recordId: this.recordId,
      sobjectType: this.sobjectType
    })
      .then((results) => {
        const event = new ShowToastEvent({
          title: "Success",
          message: `${this.file.documentType} successfully uploaded`,
          variant: "success"
        });

        this.dispatchEvent(event);
        this.isLoading = false;
        this.template.querySelector("c-modal").hideSpinner();
        this.closeModal();
      })
      .catch((error) => {
        console.log("error");
        console.log(error);
        this.isLoading = false;
        this.template.querySelector("c-modal").showSpinner();
      });
  }

  get modalTitle() {
    return this.file.documentType + " Validation";
  }
}
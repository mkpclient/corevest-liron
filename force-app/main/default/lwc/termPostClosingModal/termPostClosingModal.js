import getLoanVersion from "@salesforce/apex/TermPostClosingEmailController.getLoanVersion";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import { LightningElement, api, wire, track } from "lwc";
import ORIGINATOR_EMAIL from "@salesforce/schema/Opportunity.Owner.Email";
import UNDERWRITER_EMAIL from "@salesforce/schema/Opportunity.Underwriter__r.Email";
import CLOSER_EMAIL from "@salesforce/schema/Opportunity.Closer__r.Email";
import NAME from "@salesforce/schema/Opportunity.Name";
import PRIMARY_CONTACT from "@salesforce/schema/Opportunity.Contact__c";
import RECOURSE from "@salesforce/schema/Loan_Version__c.Recourse__c";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import TAXPAYMENTRECUR from "@salesforce/schema/Loan_Version__c.Tax_Payment_Recurrence__c";
import TAXESPAIDATCLOSE from "@salesforce/schema/Loan_Version__c.Taxes_Paid_at_Closing__c";
import saveLoanVersion from "@salesforce/apex/TermPostClosingEmailController.saveLoanVersion";
import sendEmail from "@salesforce/apex/TermPostClosingEmailController.sendEmail";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import getEmailInfo from "@salesforce/apex/TermPostClosingEmailController.getEmailInfo";
import USER_ID from "@salesforce/user/Id";
import USER_EMAIL from "@salesforce/schema/User.Email";
import LV_OBJECT from "@salesforce/schema/Loan_Version__c";
import { NavigationMixin } from "lightning/navigation";
import saveDocument from "@salesforce/apex/TermPostClosingEmailController.saveDocument";
import query from "@salesforce/apex/lightning_Util.query";
import upsertRecord from "@salesforce/apex/lightning_Controller.upsertRecord";

const fieldMapping = {
  Interest_Rate_Cap_Reserve__c: "Monthly_Interest_Rate_Cap_Constants__c",
  Reserve_Cap_Ex__c: "Monthly_Cap_Ex__c",
  Reserve_Insurance__c: "Monthly_Insurance__c",
  Reserve_Tax__c: "Monthly_Tax__c"
};

const fields = [
  NAME,
  PRIMARY_CONTACT,
  ORIGINATOR_EMAIL,
  UNDERWRITER_EMAIL,
  CLOSER_EMAIL
];
const forTotalFields = [
  "Holdback_Reserve__c",
  "Monthly_Tax__c",
  "Monthly_Cap_Ex__c",
  "Monthly_Insurance__c",
  "Monthly_Interest_Rate_Cap_Constants__c"
];
export default class TermPostClosingModal extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  loanVersion = {};
  disablePDF = false;
  isEmailStage = false;
  monthlyTotal = 0;
  loanVersionLocal = {
    Tax_Payment_Recurrence__c: "",
    First_Tax_Installment_Due__c: "",
    Taxes_Paid_at_Closing__c: "",
    Recourse__c: "",
    Monthly_Payment__c: 0,
    Deal__c: ""
  };
  loanVersionNumeric = {};
  toastParams = {
    title: "",
    message: "",
    variant: "info",
    mode: "dismissible"
  };
  emailInfo = {};
  @track recordTypeId;
  formats = [
    "font",
    "size",
    "bold",
    "italic",
    "underline",
    "strike",
    "list",
    "indent",
    "align",
    "link",
    "image",
    "clean",
    "table",
    "header",
    "color",
    "background",
    "code",
    "code-block",
    "script",
    "blockquote",
    "direction"
  ];

  isCLO = false;
  cloAssetDetails;

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [USER_EMAIL]
  })
  wireUser({ error, data }) {
    if (error) {
      console.error(error);
    } else if (data) {
      this.emailInfo.sender = data.fields.Email.value;
    }
  }

  @wire(getObjectInfo, { objectApiName: LV_OBJECT })
  wiredInfo({ error, data }) {
    if (data) {
      const rtis = data.recordTypeInfos;
      this.recordTypeId = Object.keys(rtis).find(
        (rti) => rtis[rti].name == "Loan Onboarding"
      );
      console.log(rtis);
    } else if (error) {
      console.error(error);
    }
  }

  @wire(getLoanVersion, { dealId: "$recordId" })
  wiredLv({ error, data }) {
    if (error) {
      console.error(error);
    } else if (data) {
      this.loanVersion = data;
      let local = {};
      let numLocal = {};
      let total = 0;
      Object.entries(data).forEach(([key, value]) => {
        if (Number(value)) {
          local[key] = value ? Number(Number(value).toFixed(2)) : 0;
          if (forTotalFields.includes(key)) {
            numLocal[key] = value ? Number(Number(value).toFixed(2)) : 0;
            total +=  value ? Number(Number(value).toFixed(2)) : 0;
            console.log({ key, value })
          }
        } else {
          local[key] = value;
        }
      });
      this.loanVersionLocal = local;
      this.loanVersionNumeric = numLocal;
      if (data.hasOwnProperty("Monthly_Payment__c") && data.Monthly_Payment__c == total) {
        this.monthlyTotal = data.Monthly_Payment__c;
      } else {
        this.monthlyTotal = total;
      }
      console.log({ total });
      this.retrieveCloAssetDetails();
    }
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields
  })
  dealRecord;

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: RECOURSE
  })
  recoursePicklistValues;

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: TAXPAYMENTRECUR
  })
  tprPicklistVals;

  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: TAXESPAIDATCLOSE
  })
  taxesPaidPicklistVals;

  async retrieveCloAssetDetails() {
    

    const whereClauseArr = [];

    for (const k in fieldMapping) {
      whereClauseArr.push(k + "!= NULL");
    }

    const queryString = `SELECT Id,Deal_ID__c,${Object.keys(fieldMapping).join(
      ","
    )} 
      FROM CLO_Asset_Details__c 
      WHERE Deal_ID__c='${this.recordId}' AND (${whereClauseArr.join(" OR ")})
      `;
    

    const CADs = await query({ queryString });

    this.isCLO = CADs.length > 0;

    if (CADs.length > 0) {
    
      if(this.loanVersionNumeric.hasOwnProperty("Holdback_Reserve__c")) {
        this.loanVersionNumeric.Holdback_Reserve__c = 0;
      }
      const CAD = CADs[0];
      this.cloAssetDetails = CAD;
      const tempLvLoc = { ...this.loanVersionLocal };
      let newTotal = 0;
      for (const k in fieldMapping) {
        const lvField = fieldMapping[k];
        tempLvLoc[lvField] = CAD[k];
        if(forTotalFields.includes(lvField)) {
          this.loanVersionNumeric[lvField] = parseFloat(CAD[k]);
          newTotal += parseFloat(CAD[k]);
        }
        this.monthlyTotal = newTotal;
      }

      this.loanVersionLocal = tempLvLoc;
    } else if (CADs.length === 0 && this.loanVersionNumeric.hasOwnProperty("Monthly_Interest_Rate_Cap_Constants__c")) {
      this.monthlyTotal = this.monthlyTotal - this.loanVersionNumeric.Monthly_Interest_Rate_Cap_Constants__c;
      this.loanVersionNumeric.Monthly_Interest_Rate_Cap_Constants__c = 0;
    }
  }

  get headerText() {
    return (
      "Post Closing Onboarding for " + getFieldValue(this.dealRecord.data, NAME)
    );
  }

  get contactId() {
    return getFieldValue(this.dealRecord.data, PRIMARY_CONTACT);
  }

  get originatorEmail() {
    return getFieldValue(this.dealRecord.data, ORIGINATOR_EMAIL);
  }

  get underwriterEmail() {
    return getFieldValue(this.dealRecord.data, UNDERWRITER_EMAIL);
  }

  get closerEmail() {
    return getFieldValue(this.dealRecord.data, CLOSER_EMAIL);
  }

  setNotification() {
    if (this.disablePDF) {
      this.disablePDF = false;
    }
    const event = new ShowToastEvent({
      ...this.toastParams
    });
    this.dispatchEvent(event);
  }

  async handleDownload() {
    this.disablePDF = true;
    const res = await saveDocument({ recordId: this.recordId });
    if (res.Success) {
      this[NavigationMixin.GenerateUrl]({
        type: "standard__recordPage",
        attributes: {
          recordId: res.Success,
          actionName: "view"
        }
      }).then((url) => {
        this.toastParams = {
          title: "Upload success!",
          message: "{0} uploaded. {1}",
          variant: "success",
          messageData: [
            "Berkadia Onboarding Letter",
            {
              url,
              label: "Go to record."
            }
          ]
        };

        this.setNotification();
      });
    } else {
      this.toastParams = {
        title: "Upload Error",
        message: res.Error,
        variant: "error"
      };

      this.setNotification();
      return;
    }
  }

  handleChange(evt) {
    const section = evt.target.dataset.section;
    const name = evt.target.dataset.name;
    const record = evt.target.dataset.record;
    const value = evt.detail.value;
    if (section === "MonthlyPayments") {
      let intVal = Number(evt.detail.value);
      this.loanVersionNumeric[name] = intVal;
      this.monthlyTotal = Object.values(this.loanVersionNumeric).reduce(
        (a, b) => a + b,
        0
      );
    }
    if (record === "Loan_Version__c") {
      this.loanVersionLocal[name] = value;
    } else if (record === "EmailModal") {
      this.emailInfo[name] = value;
    }
  }

  handleClose() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  async loadEmailInfo() {
    try {
      let recipientEmails = [];
      console.log(this.tprPicklistVals);
      if (this.originatorEmail) {
        recipientEmails.push(this.originatorEmail);
      }
      if (this.underwriterEmail) {
        recipientEmails.push(this.underwriterEmail);
      }
      if (this.closerEmail) {
        recipientEmails.push(this.closerEmail);
      }
      this.emailInfo.recipients = recipientEmails.join(";");
      const res = await getEmailInfo({ dealId: this.recordId });
      const emailInfo = JSON.parse(res);
      this.emailInfo.emailBody = emailInfo.emailBody[0];
      this.emailInfo.subject = emailInfo.subject[0];
      this.emailInfo.recordId = this.recordId;
    } catch (err) {
      console.error(err);
    }
  }

  async handleSubmit(evt) {
    const name = evt.target.dataset.name;
    const isInputsCorrect = [
      ...this.template.querySelectorAll("lightning-input,lightning-combobox")
    ].reduce((validSoFar, inputField) => {
      inputField.reportValidity();
      return validSoFar && inputField.checkValidity();
    }, true);
    if (isInputsCorrect && this.loanVersionLocal.hasOwnProperty("Monthly_Payment__c")) {
      if (this.loanVersionLocal.Monthly_Payment__c !== this.monthlyTotal) {
        this.loanVersionLocal["Monthly_Payment__c"] = this.monthlyTotal;
      }

      this.loanVersionLocal["Deal__c"] = this.recordId;

      try {
        const newRecord = await saveLoanVersion({
          newRecord: this.loanVersionLocal
        });
        this.loanVersionLocal = newRecord;

        if(this.isCLO) {
          let shouldUpdate = false;
          for(const key in fieldMapping) {
            if(this.cloAssetDetails[key] != newRecord[fieldMapping[key]]) {
              shouldUpdate = true;
              break;
            }
          }
          const updCad ={ sobjectType: "CLO_Asset_Details__c", ...this.cloAssetDetails };
          await upsertRecord({ record: updCad });
          
        }
        if (name == "email") {
          await this.loadEmailInfo();
          this.isEmailStage = true;
        } else if (name == "pdf") {
          await this.handleDownload();
        }
      } catch (err) {
        console.error(err);
      }
    } else {
      this.toastParams.title = "Missing required values";
      this.toastParams.message = "Please fill in all the required fields.";
      this.toastParams.variant = "error";
      this.setNotification();
    }
  }

  async handleEmail() {
    const res = await sendEmail({ s: JSON.stringify(this.emailInfo) });
    const data = JSON.parse(res);
    if (data.Error) {
      this.toastParams.title = "Error sending email";
      this.toastParams.message = data.Error;
      this.toastParams.variant = "error";
      this.setNotification();
    } else {
      this.toastParams.title = "Email Sent";
      this.toastParams.message = "Your email was sent successfully.";
      this.toastParams.variant = "success";
      this.setNotification();
      this.handleClose();
    }
  }
}
import query from '@salesforce/apex/lightning_Util.query';
import { api, LightningElement } from 'lwc';

const NOTES_COLUMNS = [
  {
    label: "Title Order",
    fieldName: "toLink",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "toLabel"
      },
      target: "_blank"
    }
  },
  {
    label: "Note Name",
    fieldName: "link",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "Name"
      },
      target: "_blank"
    }
  },
  {
    label: "Subject",
    fieldName: "Subject__c",
    type: "text"
  },
  {
    label: "Content",
    fieldName: "Comment__c",
    type: "text"
  },
];

const APP_COLUMNS = [
  {
    label: "Title Order",
    fieldName: "toLink",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "toLabel"
      },
      target: "_blank"
    }
  },
  {
    label: "Appointment ID",
    fieldName: "link",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "RecId__c"
      },
      target: "_blank"
    }
  },
  {
    label: "Scheduled Singing Date",
    fieldName: "Scheduled_Signing_Date__c",
    type: "date",
  },
  {
    label: "Appointment Status",
    fieldName: "Appointment_Status__c",
    type: "text",
  },
  {
    label: "Signing Address",
    fieldName: "Signing_Address1__c",
    type: "text",
  },
  {
    label: "Signing City",
    fieldName: "Signing_City__c",
    type: "text",
  },
  {
    label: "Signing State",
    fieldName: "Signing_State__c",
    type: "text",
  },
  {
    label: "Signing Zip Code",
    fieldName: "Signing_Zip_Code__c",
    type: "text",
  },
];
export default class TitleOrderMisc extends LightningElement {
  @api recordId;
  @api titleOrders;

  selectedTitleOrder;
  
  notesData = [];
  notesCols = NOTES_COLUMNS;
  appsData = [];
  appsCols = APP_COLUMNS;
  hasNoNotes = false;
  hasNoAppointments = false;

  get titleOrderOptions() {
    return [{ label: "All", value: "All"}].concat(this.titleOrders.map(to => ({
      label: to.Property__r.Name + " " + to.Property__r.City__c,
      value: to.Id
    })));
  }

  async queryLoanNotes() {
    let queryString = `SELECT Id, Title_Order__c, Title_Order__r.Property__r.Name, Title_Order__r.Property__r.City__c, Subject__c, Name, Comment__c FROM Loan_Status__c`;
    if(this.selectedTitleOrder !== "All") {
      queryString += ` WHERE Title_Order__c = '${this.selectedTitleOrder}'`;
    } else {
      queryString += ` WHERE Title_Order__r.Deal__c = '${this.recordId}'`;
    }
    const res = await query({ queryString });
    if(res.length === 0) {
      this.hasNoNotes = true;
    } else {
      this.hasNoNotes = false;
      this.notesData = res.map(d => ({
        ...d,
        link: "/" + d.Id,
        toLink: "/" + d.Title_Order__c,
        toLabel: d.Title_Order__r.Property__r.Name + " " + d.Title_Order__r.Property__r.City__c
       }));
    }
  }

  async queryAppointments() {
    let queryString =  'SELECT Id, Appointment_Status__c, RecId__c, Scheduled_Signing_Date__c, Signing_Address1__c, Signing_City__c, Signing_State__c,Signing_Zip_Code__c,Title_Order__c, Title_Order__r.Property__r.Name, Title_Order__r.Property__r.City__c FROM Signing_Appointment__c';
    if(this.selectedTitleOrder !== "All") {
      queryString += ` WHERE Title_Order__c = '${this.selectedTitleOrder}'`;
    } else {
      queryString += ` WHERE Title_Order__r.Deal__c = '${this.recordId}'`;
    }

    const res = await query({ queryString });
    if(res.length === 0) {
      this.hasNoAppointments = true;
    } else {
      this.hasNoAppointments = false;
      this.appsData = res.map(d => ({
        ...d,
        link: "/" + d.Id,
        toLink: "/" + d.Title_Order__c,
        toLabel: d.Title_Order__r.Property__r.Name + " " + d.Title_Order__r.Property__r.City__c
       }));
    }

  }

  async handleChange(evt) {
    const { value } = evt.detail;
    this.appsData = [];
    this.notesData = [];
    this.selectedTitleOrder = value;
    await this.queryLoanNotes();
    await this.queryAppointments();

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
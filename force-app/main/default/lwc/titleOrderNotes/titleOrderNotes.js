import query from '@salesforce/apex/lightning_Util.query';
import { api, LightningElement } from 'lwc';

const COLS = [
  {
    label: "Deal",
    fieldName: "Deal__r.Name",
    type: "text"
  },
  {
    label: "Property",
    fieldName: "Property_Title__r.Property__r.Name",
    type: "text"
  },
  {
    label: "Subject",
    fieldName: "Subject__c",
    type: "text"
  },
  {
    label: "Comment",
    fieldName: "Comment__c",
    type: "text"
  },
  {
    label: "Date Created",
    fieldName: "CreatedDate",
    type: "date"
  }
];

export default class TitleOrderNotes extends LightningElement {
  @api recordId;
  @api vendorType;
  columns = COLS;
  data = [];
  appointments = [];

  async connectedCallback() {
    const fields = ["Id", "Deal__c", "Title_Order__c", "Property_Title__c"];

    COLS.forEach(c => {
      fields.push(c.fieldName);
    });
    let queryString = `SELECT ${fields.join(",")} FROM Loan_Status__c
      WHERE Deal__c = '${this.recordId}' AND (Property_Title__c != null OR Title_Order__c != null)
      AND Title_Order__r.Title_Vendor__c = '${this.vendorType}' ORDER BY CreatedDate DESC`;
    const res = await query({ queryString });

    this.data = res.map(r => this.flattenObj(r));

    queryString = `SELECT Id, Appointment_Status__c, Scheduled_Signing_Date__c, (SELECT Id FROM Signing_Attendees__r) FROM Signing_Appointment__c
    WHERE Title_Order__r.Deal__c = '${this.recordId}' AND Title_Order__r.Title_Vendor__c = '${this.vendorType}' ORDER BY Scheduled_Signing_Date__c DESC`;

    const res2 = await query({ queryString });

    this.appointments = res2.map(r => ({
      ...r, _title: r.Appointment_Status__c + ", " + r.Scheduled_Signing_Date__c
    }));
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
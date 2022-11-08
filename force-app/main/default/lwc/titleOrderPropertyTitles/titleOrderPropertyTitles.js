import query from '@salesforce/apex/lightning_Util.query';
import { api, LightningElement } from 'lwc';

const COLS = [
  {
    label: "Property Name",
    fieldName: "propUrl",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "Property__r.Name"
      },
      target: "_blank"
    }
  },
  {
    label: "Property City",
    fieldName: "Property__r.City__c",
    type: "text"
  },
  {
    label: "Property State",
    fieldName: "Property__r.State__c",
    type: "text"
  },
  {
    label: "Property Type",
    fieldName: "Property__r.Property_Type__c",
    type: "text"
  },
  {
    label: "Number of Units",
    fieldName: "Property__r.Number_of_Units__c",
    type: "number"
  },
  {
    label: "Status",
    fieldName: "Status__c",
    type: "text"
  },
  {
    label: "Title Vendor",
    fieldName: "Title_Order__r.Title_Vendor__c",
    type: "text"
  },
  {
    label: "Order Opened Date",
    fieldName: "Title_Order__r.Order_Opened_Date__c",
    type: "date"
  },
  {
    label: "Title Completed Date",
    fieldName: "TitleCompleteDate__c",
    type: "date"
  },
  {
    label: "Original Title Cleared Date",
    fieldName: "OriginalTitleClearedDate__c",
    type: "date"
  },
  {
    label: "All Cleared to Close Date",
    fieldName: "Title_Order__r.All_Cleared_To_Close_Date__c",
    type: "date"
  },
  {
    label: "Last Error Message",
    fieldName: "ErrorMessage__c",
    type: "text"
  }
];

export default class TitleOrderPropertyTitles extends LightningElement {
  @api recordId;
  @api vendorType;
  columns = COLS;
  data = [];

  async connectedCallback() {
    const fieldNames = ["Id", "Property__c", "Title_Order__c"];

    COLS.forEach(c => {
      if(c.fieldName == "propUrl") {
        fieldNames.push("Property__r.Name");
      } else {
        fieldNames.push(c.fieldName);
      }
    });

    let queryString = "SELECT " + fieldNames.join(",");
    queryString += " FROM Property_Title__c WHERE Title_Order__r.Title_Vendor__c='" + this.vendorType + "'";
    queryString += " AND Title_Order__r.Deal__c ='" + this.recordId  + "'";

    const res = await query({ queryString });

    if(res && res.length > 0) {
      const tempData = [];

      res.forEach(pt => {
        const flattened = this.flattenObj(pt);
        tempData.push({ ... flattened, propUrl: "/" + pt.Property__c });
      });
      console.log(tempData);
      this.data = tempData;
    }
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
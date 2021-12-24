import { LightningElement, api } from "lwc";

import query from "@salesforce/apex/lightning_Util.query";
import upsert from "@salesforce/apex/lightning_Util.upsertRecords";

export default class PropertyExtensionNew extends LightningElement {
  extensions = [];
  isLoading = false;

  get extensionList() {
    let extensions = JSON.parse(JSON.stringify(this.extensions));

    extensions.forEach((extension) => {
    //   let fee$ = 0;

    //   if (extension.Property__r && extension.Extension_Fee_Percent__c) {
    //     fee$ =
    //       extension.Property__r.Approved_Advance_Amount__c *
    //       (extension.Extension_Fee_Percent__c / 100);
    //   }
    //   extension.fee$ = fee$;

    })

    return extensions;
  }

  get saveDisabled() {
    return this.isLoading();
  }

  get reasonOptions() {
    return [
        { label: 'Construction Delay', value: 'Construction Delay' },
        { label: 'In House Refi', value: 'In House Refi' },
        { label: 'Outside Refi', value: 'Outside Refi' },
        { label: 'Sale Pending', value: 'Sale Pending' }
    ];
  }

  updateValue(event) {
    let fieldName = event.target.getAttribute("data-field");
    let index = event.target.getAttribute("data-index");
    let value = event.target.value;

    let extensions = JSON.parse(JSON.stringify(this.extensions));

    extensions[index][fieldName] = value;

    if (fieldName === "days") {
      let days = value;
      let newDate = extensions[index].Property__r.Asset_Maturity_Date__c;

      console.log(days);
      console.log(newDate);

      if (days && newDate) {
        let d = new Date(newDate);
        d.setDate(d.getDate() + parseInt(days));

        console.log(newDate);
        newDate = d.toISOString();
      }

      console.log(newDate);

      extensions[index].New_Asset_Maturity_Date__c = newDate;
    } else if (fieldName === "New_Asset_Maturity_Date__c") {
      let newDate = value;
      let originalDate = extensions[index].Property__r.Asset_Maturity_Date__c;

      let days = 0;

      console.log(newDate);
      console.log(originalDate);

      if (newDate && originalDate) {
        days = Math.round(
          (new Date(newDate) - new Date(originalDate)) / (1000 * 60 * 60 * 24)
        );
      }

      extensions[index].days = days;
    }

    this.extensions = extensions;
  }

  @api init(propertyIds) {
    console.log("propertyIds=>", propertyIds);

    let propertyFields = [
      "Id",
      "Name",
      "Current_Asset_Maturity_Date__c",
      "Asset_Maturity_Date__c",
      "Current_Interest_Rate__c",
      "Original_Interest_Rate__c",
      "Approved_Advance_Amount__c",
      "Deal__r.Original_Line_Maturity_Date__c"
    ];

    let queryString = `SELECT ${propertyFields.join(", ")}`;
    queryString += ` FROM Property__c WHERE Id IN ( ${propertyIds.join(",")}) `;
    console.log(queryString);

    query({ queryString }).then((results) => {
      console.log(results);

      const extensions = [];

      results.forEach((property) => {
        const extension = {
          sobjectType: "Property_Extension__c",
          Property__c: property.Id,
          Property__r: property,
          // Original_Asset_Maturity_Date__c: property.Current_Asset_Maturity_Date__c,
          New_Asset_Maturity_Date__c: property.Current_Asset_Maturity_Date__c,
          // Original_Interest_Rate__c: property.Current_Interest_Rate__c,
          New_Asset_Interest_Rate__c: property.Current_Interest_Rate__c,
          // Original_Line_Maturity_Date__c: property.Deal__r.Original_Line_Maturity_Date__c,
          // Extension_Fee_Percent__c: null,
          days: 0
        };

        extensions.push(extension);
      });

      this.extensions = extensions;
    });

    this.template.querySelector("c-modal").toggleModal();
  }

  closeModal() {
    this.template.querySelector("c-modal").toggleModal();
  }

  createExtensions() {
    this.isLoading = true;
    console.log("save");
    console.log(this.extensions);

    upsert({ records: this.extensions })
      .then((results) => {
        this.isLoading = false;
        console.log(results);
        eval("$A.get('e.force:refreshView').fire();");
        this.closeModal();
      })
      .catch((error) => {
        this.isLoading = false;
        console.log(error);
      });
  }
}
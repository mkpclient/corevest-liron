import { LightningElement, api, track, wire } from "lwc";
//import { getRecord} from 'lightning/uiRecordApi';

import getProperties from "@salesforce/apex/InsuranceReserveCalcExtension.getProperties";
import getDeal from "@salesforce/apex/InsuranceReserveCalcExtension.getDeal";

import upsert from "@salesforce/apex/InsuranceReserveCalcExtension.upsertData";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InsuranceReserveCalculator extends LightningElement {
  @api recordId;
  // @track deal;
  //@track properties;

  // @track paymentDueDate;
  // @track renewalDate;

  @track saving = false;

  @wire(getDeal, {recordId: '$recordId'})
  deal

  @wire(getProperties, { recordId: "$recordId" })
  properties;
  get dealName(){
    return this.deal.data ? this.deal.data.Name : ' '
  }
  get paymentDueDate(){
    return this.deal && this.deal.data ? this.deal.data.First_Payment_Due_Date__c : null;
  }

  get renewalDate(){
    return this.deal && this.deal.data ? this.deal.data.Ins_Renewal_Date__c : null;
  }

  get propertyData(){
    let properties = JSON.parse(JSON.stringify(this.properties.data));
    // let properties = this.properties.data;
    properties.forEach( property => {
      property.url = '/lightning/r/Property__c/' + property.Id + '/view/';
    });

    return properties;
  }
  // connectedCallback() {
  //     this.properties = [];
  //     this.loadProperties();
  // }

  // loadProperties() {
  //     getProperties({ recordId: this.recordId })
  //         .then(result => {
  //             this.properties = result;
  //         }).catch(error => {
  //             console.log(error);
  //         });
  // }

  dateChanged(event) {
    //console.log(event.target);
    let name = event.target.name;
    let deal = JSON.parse(JSON.stringify(this.deal));
    if (name === "paymentDueDate") {
      //this.deal.
      deal.data.First_Payment_Due_Date__c = event.target.value;
      this.deal = deal;
      if (this.deal.data != null && this.deal.data.First_Payment_Due_Date__c != null && Array.isArray(this.properties.data)) {
        console.log('--calculate property values--');
        this.calculatePropertyValues();
      }
    } 
    
    // else if (name === "renewalDate") {
    //   deal.data.Ins_Renewal_Date__c = event.target.value;
    //   this.deal = deal;
    // }

    
  }

  calculatePropertyValues() {
    let properties = JSON.parse(JSON.stringify(this.properties));
    //console.log("calculate property values");
    properties.data.forEach(property => {
      console.log(property.Renewal_Date__c);
      if (property.Renewal_Date__c != null && this.deal.data != null && this.deal.data.First_Payment_Due_Date__c != null) {
        let paymentDueDate = new Date(this.deal.data.First_Payment_Due_Date__c);
        let renewalDate = new Date(property.Renewal_Date__c);

        let diff = Math.floor(
          (Date.parse(renewalDate) - Date.parse(paymentDueDate)) / 86400000
        );

        property.Total_Monthly_Reserve_Required__c = Math.round(12 - (diff + 1) / 31);
        
        if(property.Monthly_Premium__c != null){
          property.Reserve_on_Closing_Statement__c = property.Monthly_Premium__c * property.Total_Monthly_Reserve_Required__c;
        }

      }
    });

    this.properties = properties;
  }

  get totalDeficient() {
    let totalDeficient = null;

    if (this.paymentDueDate != null && this.renewalDate != null) {
      let paymentDueDate = new Date(this.paymentDueDate);
      let renewalDate = new Date(this.renewalDate);

      let diff = Math.floor(
        (Date.parse(renewalDate) - Date.parse(paymentDueDate)) / 86400000
      );

      

      totalDeficient = this.round(12 - this.round(diff + 1,0) / 31,0);
    }

    return totalDeficient;
  }

  get totalReserve() {
    let totalReserve = null;
    if (this.totalDeficient !== null) {
      totalReserve = this.totalDeficient + 2;
    }

    return totalReserve;
  }

  propertyValueChanged(event) {
    let index = parseInt(event.target.dataset.index, 10);
    let name = event.target.name;

    //let properties = this.properties.slice();
    //console.log(properties[index]);
    //console.log(event.target.value);

    let properties = JSON.parse(JSON.stringify(this.properties));

    if (name === "premiumAmount") {
      properties.data[index].Premium_Amount__c = event.target.value;

      properties.data[index].Monthly_Premium__c = 0;
      if (event.target.value != null) {
        properties.data[index].Monthly_Premium__c = event.target.value / 12;
      }

      //this.properties[index].Total_Monthly_Reserve = event.target.value;
    } else if (name === "renewalDate") {
      properties.data[index].Renewal_Date__c = event.target.value;

      properties.data[index].Total_Monthly_Reserve_Required__c = null;

      if (event.target.value != null && this.paymentDueDate != null) {
        let paymentDueDate = new Date(this.paymentDueDate);
        let renewalDate = new Date(event.target.value);

        let diff = Math.floor(
          (Date.parse(renewalDate) - Date.parse(paymentDueDate)) / 86400000
        );

        properties.data[index].Total_Monthly_Reserve_Required__c = this.round(
          (12 - this.round(diff + 1,1) / 31) + 2,
          0
        );
      }
    }

    properties.data[index].Reserve_on_Closing_Statement__c = 0;
    if (
      properties.data[index].Total_Monthly_Reserve_Required__c != null &&
      properties.data[index].Monthly_Premium__c != null
    ) {
      properties.data[index].Reserve_on_Closing_Statement__c =
        properties.data[index].Total_Monthly_Reserve_Required__c *
        properties.data[index].Monthly_Premium__c;
    }

    this.properties = properties;
  }

  get totalPremiumAmount() {
    console.log('this changing')
    //let properties = JSON.parse(JSON.stringify(this.properties));
    let totalAmount = 0;
    if (Array.isArray(this.properties.data)) {
      this.properties.data.forEach(property => {
        totalAmount += property.Premium_Amount__c
          ? parseFloat(property.Premium_Amount__c)
          : 0;
      });
    }

    return totalAmount;
  }

  get totalReserveOnClosing() {
    let totalReserve = 0;
    if (Array.isArray(this.properties.data)) {
      this.properties.data.forEach(property => {
        totalReserve += property.Reserve_on_Closing_Statement__c
          ? parseFloat(property.Reserve_on_Closing_Statement__c)
          : 0;
      });
    }

    return totalReserve;
  }

  round(num, scale) {
    if(!("" + num).includes("e")) {
      return +(Math.round(num + "e+" + scale)  + "e-" + scale);
    } else {
      var arr = ("" + num).split("e");
      var sig = ""
      if(+arr[1] + scale > 0) {
        sig = "+";
      }
      return +(Math.round(+arr[0] + "e" + sig + (+arr[1] + scale)) + "e-" + scale);
    }
  }

  save() {
    console.log('save');

    let records = [this.deal.data].concat(this.properties.data);
    this.saving = true;
    //let properties = this.properties.data;
    // console.log(JSON.parse(JSON.stringify(this.deal)));

    upsert({records: records}).then(result => {
      this.saving = false;
      this.showNotification('Success', 'Record has been saved', 'success');
      console.log(JSON.parse(JSON.stringify(result)));
    }).catch(error => {
      this.saving = false;
      console.log(JSON.parse(JSON.stringify(error)));
    })

  }

  print() {

    let records = [this.deal.data].concat(this.properties.data);
    this.saving = true;
    //let properties = this.properties.data;
    // console.log(JSON.parse(JSON.stringify(this.deal)));

    upsert({records: records}).then(result => {
      this.saving = false;
      console.log(JSON.parse(JSON.stringify(result)));
      this.showNotification('Success', 'Record has been saved', 'success');
      let url = '/apex/InsuranceReserveCalculator?id=' + this.recordId;

      let win = window.open(url, '_blank');
      win.focus();

    }).catch(error => {
      this.saving = false;
      console.log(JSON.parse(JSON.stringify(error)));

      this.showNotification('error', 'error', 'error')

    })

    
  }

  get spinnerClass(){
    return this.saving ? '' : 'slds-hide';
  }

  showNotification(title, message, variant){
    const evt = new ShowToastEvent({
      title: title ,
      message: message,
      variant: variant,
    });
    this.dispatchEvent(evt);
  }
}
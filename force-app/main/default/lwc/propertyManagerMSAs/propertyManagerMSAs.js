import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";

const FIELDS = ["Property_Manager_Questionnaire__c.MSAs__c"];

export default class PropertyManagerMSAs extends LightningElement {
  @api recordId;
  msa = [];
  msaColumns = [
    {
      label: "State",
      fieldName: "state",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "MSA",
      fieldName: "MSA",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Are you licensed in the MSAs in which you property manage?",
      fieldName: "licensedInMSA",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "License Number",
      fieldName: "licenseNumber",
      wrapText: true,
      hideDefaultActions: true
    }
  ];

  @wire(getRecord, {
    recordId: "$recordId",
    fields: FIELDS
  })
  getRecord({ data, error }) {
    if (data) {
      this.msa = data.fields.MSAs__c.value
        ? JSON.parse(data.fields.MSAs__c.value)
        : [];
      console.log(this.msa);
      this.loaded = true;
    } else if (error) {
      console.error("ERROR => ", JSON.stringify(error)); // handle error properly
    }
  }
}
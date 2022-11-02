import queryJSON from "@salesforce/apex/lightning_Util.queryJSON";
import { api, LightningElement } from "lwc";

const columns = [
  {
    label: "File Name",
    fieldName: "docUrl",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "File_Name__c"
      },
      target: "_blank"
    }
  },
  {
    label: "File Type",
    fieldName: "Type__c",
    type: "text"
  },
  {
    label: "Download",
    fieldName: "downloadLink",
    type: "url",
    typeAttributes: {
      label: "Download",
      target: "_blank"
    }
  },
  {
    label: "Date Created",
    fieldName: "CreatedDate",
    type: "date"
  }
];
export default class TitleOrderDocuments extends LightningElement {
  @api recordId;
  data = [];
  cols = columns;

  connectedCallback() {
    this.queryDocuments();
  }

  async queryDocuments() {
    const queryString = `SELECT Id, Type__c, File_Name__c, Attachment_Id__c, CreatedDate
    FROM Deal_Document__c
    WHERE Deal__c = '${this.recordId}'
    AND Document_Type__c = 'Title Order'
    AND Is_Deleted__c = false`;

    const res = await queryJSON({ queryString });
    const resVal = JSON.parse(res);

    if (resVal.length > 0) {
      this.data = resVal.map((v) => ({
        ...v,
        downloadLink:
          "/sfc/servlet.shepherd/document/download/" +
          v.Attachment_Id__c +
          "?operationContext=S1",
        docUrl: "/" + v.Id
      }));
    }
  }
}
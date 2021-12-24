import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createSampleData from "@salesforce/apex/YardiAPI.createSampleData";

export default class YardiXMLGenerator extends LightningElement {
  @api recordId;
  @api objectApiName;

  @api invoke() {
    createSampleData({
      recordId: this.recordId
    })
      .then((results) => {
        console.log(results);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Successfully created Test XMLs",
            variant: "success"
          })
        );
      })
      .catch((error) => {
        console.log("error");
        console.log(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Failed Creating Test XMLs",
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }
}
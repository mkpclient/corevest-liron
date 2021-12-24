import { LightningElement, api } from "lwc";
import createPortalUser from "@salesforce/apex/AlchemyAPI.createUser";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { updateRecord } from "lightning/uiRecordApi";

export default class CreateAlchemyPortalUser extends LightningElement {
  @api recordId;
  @api objectApiName;

  @api invoke() {
    createPortalUser({
      recordId: this.recordId,
      sObjectName: this.objectApiName
    })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Successfully created user",
            variant: "success"
          })
        );
      })
      .catch((error) => {
        console.log("error");
        console.log(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Failed Creating Portal User",
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }
}
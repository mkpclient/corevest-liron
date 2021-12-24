import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createSampleData from "@salesforce/apex/YardiAPI.createSampleCSV";

export default class YardiXMLGenerator extends LightningElement {
  @api recordId;
  @api objectApiName;

  @api invoke() {
    createSampleData({
      recordId: this.recordId
    })
      .then((results) => {
        console.log(results);

        results.forEach((csv, index) => {
          //text/csv;charset=utf-8;
          console.log(csv);
          var blob = new Blob([csv], { type: "application/octet-stream" });
          var link = document.createElement("a");
          var url = URL.createObjectURL(blob);
          link.setAttribute("href", url);
          if (index == 0) {
            link.setAttribute("download", "ETL_SFSTAGELOANVENDOR.csv");
          } else if (index == 1) {
            link.setAttribute("download", "ETL_SFSTAGELOANPROP.csv");
          }
          link.style.visibility = "hidden";
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
        });
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Successfully created Test csv",
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
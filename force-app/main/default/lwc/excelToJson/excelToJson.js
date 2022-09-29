import { api, LightningElement } from "lwc";
import SheetJS2 from "@salesforce/resourceUrl/SheetJS2";
import { loadScript } from "lightning/platformResourceLoader";
import getFileBody from "@salesforce/apex/ExcelUploadLwcHelper.getFileBody";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import query from "@salesforce/apex/lightning_Util.query";
import upsertRecords from "@salesforce/apex/lightning_Util.upsertRecords";

/**
  ** Name: excelToJson
  ** Description: 
  **       A "headerless" LWC, that is, one with no UI components, 
  **      for converting excel files to JSON. Mount this into any LWC or Aura Component at the bottom of the HTML file, and pass in the contentVersionId of the file that needs parsed. 
  **      Call the public method "handleParseFile" from the parent component, then catch the result through the custom event "onparsefile". 
  **      Additional methods for Apex-less SOQL queries and upsert DML are available too, for further data processing while using this parser. 
  **      DocumentUploader.cmp should have example methods using this.
 */

export default class ExcelToJson extends LightningElement {
  @api contentVersionId;

  fixData(data) {
    var o = "",
      l = 0,
      w = 10240;
    for (; l < data.byteLength / w; ++l)
      o += String.fromCharCode.apply(
        null,
        new Uint8Array(data.slice(l * w, l * w + w))
      );
    o += String.fromCharCode.apply(null, new Uint8Array(data.slice(l * w)));
    return o;
  }

  @api
  async handleParseFile() {
    const fileBody = await getFileBody({
      fileId: this.contentVersionId
    });

    loadScript(this, SheetJS2 + "/dist/xlsx.core.min.js")
      .then(() => {
        let reader = new FileReader();
        reader.onload = (event) => {
          const data = event.target.result;
          let arr = this.fixData(data);

          // console.log(arr);

          let workbook = XLSX.read(arr, { type: "base64", cellDates: true });
          let workBookAsJson = {};

          workbook.SheetNames.forEach((sheetName) => {
            // console.log(XLSX.utils.sheet_to_json(workbook.Sheets[sheetName]));
            workBookAsJson[sheetName] = JSON.stringify(
              XLSX.utils.sheet_to_json(workbook.Sheets[sheetName])
            );
          });
          const fileJson = JSON.stringify(workBookAsJson);
          this.dispatchEvent(
            new CustomEvent("parsefile", { detail: { fileJson } })
          );
        };
        reader.readAsArrayBuffer(new Blob([fileBody]));
      })
      .catch((error) => {
        console.error(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error.body.message,
            variant: "error"
          })
        );
      });
  }

  @api
  async getRecords(queryString) {
    try {
      return await query({ queryString });
    } catch (err) {
      throw err;
    }
    
  }

  @api
  async saveRecords(records) {
    await upsertRecords({ records });
  }
}
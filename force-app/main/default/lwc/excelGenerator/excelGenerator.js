import { api, LightningElement } from "lwc";
import SheetJS2 from "@salesforce/resourceUrl/SheetJS2";
import { loadScript } from "lightning/platformResourceLoader";
import getFileBody from "@salesforce/apex/ExcelUploadLwcHelper.getFileBody";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import query from "@salesforce/apex/lightning_Util.query";

/**
 ** Name: excelGenerator
 ** Description:
 **       A "headerless" LWC, that is, one with no UI components,
 **      for creating simple Excel files with no formatting. Mount this into any LWC or Aura Component at the bottom of the HTML file, and pass in the contentVersionId of the file that needs parsed.
 **      Call the public method "generateExcel" from the parent component, then catch the result through the custom event "ongenerate".
 */

export default class ExcelGenerator extends LightningElement {
  @api queryString;
  @api rowConfig; // { fieldName: header }, { "Deal_Loan_Number__c": "Loan Number"}
  @api fileName;
  records;

  @api
  async generateExcel() {
    await this.queryRecords();
    loadScript(this, SheetJS2 + "/dist/xlsx.core.min.js")
      .then(() => {
        const rows = [];

        for(const r of this.records) {
          const row = {};
          for(const key in this.rowConfig) {
            const header = this.rowConfig[key];
            row[header] = r[key];
          }
          rows.push(row);
        }

        const worksheet = XLSX.utils.json_to_sheet(rows);
        const workbook = XLSX.utils.book_new();
        const fileName = this.fileName.includes(".xlsx") ? this.fileName : this.fileName + ".xlsx";
        XLSX.utils.book_append_sheet(workbook, worksheet, "Sheet1");
        XLSX.writeFile(workbook, fileName);
        const base64Data = XLSX.write(workbook, { type: "base64" });
        console.log(base64Data);
        this.dispatchEvent(
          new CustomEvent("generate", { detail: { base64Data, fileName } })
        );
      });
  }

  async queryRecords() {
    const res = await query( {queryString: this.queryString} );
    const modifiedRes = [];

    // flatten the objects to make parsing the config easier
    for (const rec of res) {
      const newRec = this.flattenObj(rec);
      modifiedRes.push(newRec);
    }
    this.records = modifiedRes;
  }

  @api
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
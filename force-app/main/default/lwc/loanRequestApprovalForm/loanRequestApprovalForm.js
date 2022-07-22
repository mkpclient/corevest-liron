import { api, LightningElement, wire } from "lwc";
import xlsxPopulate from "@salesforce/resourceUrl/xlsx_populate";
import { loadScript } from "lightning/platformResourceLoader";
import queryRecord from "@salesforce/apex/lightning_Util.query";
import getTemplate from "@salesforce/apex/lightning_Controller.getTemplate";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import insertFileAndLink from "@salesforce/apex/lightning_Util.insertFileAndLink";
import createDealDocuments from "@salesforce/apex/UploadFile_LightningController.createDealDocuments";

const TEMPLATE_NAME = "CVRevisedLoanRequestApprovalFormTemplate";
const CONTENT_TYPE = 'application/vnd.ms-excel';
export default class LoanRequestApprovalForm extends LightningElement {
  @api dealId;
  propertyOptionsLocal = [];
  templateFile;
  copyTemplateFile;
  propertyRecord = {};
  dealRecord = {};
  manualEntryRecord = {};
  activeProperties = 0;
  paidOffProperties = 0;
  propertyId;
  showPage = true;

  get propertyOptions() {
    return this.propertyOptionsLocal;
  }
  set propertyOptions(value) {
    this.propertyOptionsLocal = value;
  }

  async connectedCallback() {
    if (this.dealId) {
      let queryString = `SELECT Id, Name FROM Property__c WHERE Deal__c = '${this.dealId}'`;
      const res = await queryRecord({ queryString });
      const options = res.map((r) => ({ label: r.Name, value: r.Id }));
      this.propertyOptions = options;

      queryString = `SELECT Id FROM Property__c WHERE Deal__c = '${this.dealId}' AND Status__c = 'Active'`;
      const res2 = await queryRecord({ queryString });
      this.activeProperties = res2.length;

      queryString = `SELECT Id FROM Property__c WHERE Deal__c = '${this.dealId}' AND Status__c = 'Paid Off'`;
      const res3 = await queryRecord({ queryString });
      this.paidOffProperties = res3.length;
    }
    const tempRes = await getTemplate({ fileName: TEMPLATE_NAME });
    this.templateFile = tempRes;
    this.copyTemplateFile = tempRes;
    console.log("CONNECTED");
  }

  handleGenerate() {
    const propertyInput = this.template.querySelector(
      '[data-type="propertySearch"]'
    );
    if (propertyInput != null) {
      if (propertyInput.checkValidity()) {
        this.propertyId = propertyInput.value;
        const inputs = [
          ...this.template.querySelectorAll('[data-type="manualField"]')
        ];
        const manualEntry = {};
        inputs.forEach((i) => {
          if (i.value) {
            let meValue = i.value;
            let meName = i.name;
            if(meName == "completionPct") {
              meValue = parseFloat(meValue) / 100;
            }
            manualEntry[meName] = meValue;
          }
        });
        
        this.manualEntryRecord = manualEntry;
        this.retrieveRecordValues();
      } else {
        propertyInput.reportValidity();
        this.showToast({
          title: "Error",
          message: "Please select a property",
          variant: "error"
        });
      }
    }
  }

  showToast({ title, message, variant }) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  saveFile() {
    loadScript(this, xlsxPopulate).then(() => {
      let downloadFile;
      XlsxPopulate.fromDataAsync(
        this.base64ToArrayBuffer(JSON.parse(this.copyTemplateFile))
      )
        .then((workbook) => {
          const data = {
            Property__c: {
              ...this.propertyRecord
            },
            Opportunity: {
              ...this.dealRecord
            }
          };
          const manualEntry = { ...this.manualEntryRecord };
          for (let i = 7; i < 43; i++) {
            for (let j = 2; j < 11; j++) {
              const v = workbook.sheet("Sheet1").row(i).cell(j).value();
              let newVal;
              if (typeof v === "string" && v[0]=="{") {
                const isManual = !v.includes(".");
                let key;
                if (isManual) {
                  key = v.slice(v.lastIndexOf("{") + 1, v.indexOf("}"));
                  if (
                    v.includes("countActiveProperties") &&
                    v.includes("countPaidOffProperties")
                  ) {
                    newVal = v.replace(
                      "{{countActiveProperties}}",
                      this.activeProperties
                    );
                    newVal = newVal.replace(
                      "{{countPaidOffProperties}}",
                      this.paidOffProperties
                    );
                  } else if (manualEntry.hasOwnProperty(key) && manualEntry[key]) {
                    newVal = v.replace(`{{${key}}}`, manualEntry[key]);
                  } else {
                    newVal = v.replace(`{{${key}}}`, "");
                  }
                } else {
                  const sobjectKey = v.slice(
                    v.lastIndexOf("{") + 1,
                    v.indexOf(".")
                  );
                  let fieldKey = v.slice(v.indexOf(".") + 1, v.indexOf("}"));
                  console.log("fieldKey", fieldKey);
                  console.log("sobjectkey", sobjectKey);
                  if (data.hasOwnProperty(sobjectKey)) {
                    let parentField;
                    let parentKey;
                    let grandParentKey;
                    let grandParentField;
                    if(fieldKey.includes(".")) {
                      const splitFieldKey = fieldKey.split(".");
                      parentKey = splitFieldKey[0];
                      parentField = splitFieldKey[1];
                      if(splitFieldKey.length > 2) {
                        grandParentKey = splitFieldKey[2];
                        grandParentField = splitFieldKey[3];
                      }
                    }
                    if (data[sobjectKey].hasOwnProperty(fieldKey) && data[sobjectKey][fieldKey]) {
                      newVal = v.replace(
                        `{{${sobjectKey}.${fieldKey}}}`,
                        data[sobjectKey][fieldKey]
                      );
                    } else if (data[sobjectKey].hasOwnProperty(parentKey) && data[sobjectKey][parentKey].hasOwnProperty(parentField) && data[sobjectKey][parentKey][parentField]) {
                      newVal = v.replace(
                        `{{${sobjectKey}.${fieldKey}}}`,
                        data[sobjectKey][parentKey][parentField]
                      );
                    } else if (data[sobjectKey].hasOwnProperty(parentKey) && data[sobjectKey][parentKey].hasOwnProperty(grandParentKey) && data[sobjectKey][parentKey][grandParentKey].hasOwnProperty(grandParentField) && data[sobjectKey][parentKey][grandParentKey][grandParentField]) {
                      newVal = v.replace(
                        `{{${sobjectKey}.${fieldKey}}}`,
                        data[sobjectKey][parentKey][grandParentKey][grandParentField]
                      );
                    } 
                    else {
                      newVal = v.replace(`{{${sobjectKey}.${fieldKey}}}`, "");
                    }
                  }
                }
                if (this.isNumeric(newVal)) {
                  newVal = parseFloat(newVal);
                }
                console.log("from v", v, "to newVal", newVal);
                workbook.sheet("Sheet1").row(i).cell(j).value(newVal);
              } else if (v != undefined && v.includes("FX")) {
                newVal = v.replace("FX", "");
                workbook.sheet("Sheet1").row(i).cell(j).formula(newVal);
              } 
            }
          }
          return workbook.outputAsync("base64");
        })
        .then((res) => {
          downloadFile = res;
          insertFileAndLink({
            request: JSON.stringify({
              parentId: this.dealId,
              fileName: 'Loan Request Approval Form.xlsx',
              fileType: CONTENT_TYPE,
              data: res
            })
          }).then((fileId) => {
            createDealDocuments({
              ids: [fileId],
              dealId: this.dealId
            }).then((res) => {
              this.showToast({
                title: "Success",
                message: "File saved successfully",
                variant: "success"
              });
              let link = document.createElement("a");
              link.href = "data:" + XlsxPopulate.MIME_TYPE + ";base64," + downloadFile;
              link.download = "Loan Request Approval Form.xlsx";
              document.body.appendChild(link);
              link.click();
              this.handleCancel();
            })
          })
          
        })
        .catch((err) => {
          console.error(err);
        });
    });
  }

  isNumeric(str) {
    if(typeof str == "number") return true;
    if (typeof str != "string") return false; // we only process strings!
    return (
      !isNaN(str) && // use type coercion to parse the _entirety_ of the string (`parseFloat` alone does not do this)...
      !isNaN(parseFloat(str))
    ); // ...and ensure strings of whitespace fail
  }

  retrieveRecordValues() {
    loadScript(this, xlsxPopulate).then(() => {
      this.showPage = false;
      XlsxPopulate.fromDataAsync(
        this.base64ToArrayBuffer(JSON.parse(this.templateFile))
      )
        .then((workbook) => {
          const values = workbook.sheet("Sheet1").usedRange().value();
          const propertyFields = [];
          const dealFields = [];
          for (let i = 0; i < values.length; i++) {
            for (let j = 0; j < values[i].length; j++) {
              let value = values[i][j];
              if (
                typeof value === "string" &&
                value.substring(0, 2) === "{{" &&
                value.includes(".")
              ) {
                let sobjectName = value.slice(
                  value.lastIndexOf("{") + 1,
                  value.indexOf(".")
                );
                let fieldName = value.slice(
                  value.indexOf(".") + 1,
                  value.indexOf("}")
                );
                switch (sobjectName) {
                  case "Property__c":
                    if (!propertyFields.includes(fieldName)) {
                      propertyFields.push(fieldName);
                    }
                    break;
                  case "Opportunity":
                    if (!dealFields.includes(fieldName)) {
                      dealFields.push(fieldName);
                    }
                    break;
                  default:
                    break;
                }
              } else {
                continue;
              }
            }
          }
          const propQuery = `SELECT ${propertyFields.join(
            ","
          )} FROM Property__c WHERE Id = '${this.propertyId}'`;
          const dealQuery = `SELECT ${dealFields.join(
            ","
          )} FROM Opportunity WHERE Id = '${this.dealId}'`;
          queryRecord({ queryString: propQuery }).then((res) => {
            this.propertyRecord = res[0];
            queryRecord({ queryString: dealQuery }).then((res2) => {
              this.dealRecord = res2[0];
              this.saveFile();
            });
          });
        })
        .catch((err) => {
          console.error(err);
          this.showToast({
            title: "Error",
            message: "Error parsing file. " + err,
            variant: "error"
          });
        });
    });
  }

  base64ToArrayBuffer(base64) {
    let binary_string = window.atob(base64);
    let len = binary_string.length;
    let bytes = new Uint8Array(len);
    // console.log(binary_string);
    console.log(len);
    for (let i = 0; i < len; i++) {
      bytes[i] = binary_string.charCodeAt(i);
    }
    return bytes.buffer;
  }

  handleCancel() {
    this.dispatchEvent(new CustomEvent("cancel"));
  }
}
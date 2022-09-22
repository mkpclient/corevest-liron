import { api, LightningElement } from "lwc";
import xlsxPopulate from "@salesforce/resourceUrl/xlsx_populate";
import { loadScript } from "lightning/platformResourceLoader";
import getTemplate from "@salesforce/apex/lightning_Controller.getTemplate";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import queryRecord from "@salesforce/apex/lightning_Util.query";
import insertFileAndLink from "@salesforce/apex/lightning_Util.insertFileAndLink";
import getCurrentUserDetails from "@salesforce/apex/AdvanceDocumentGeneratorController.getCurrentUserDetails";
import upsertRecords from "@salesforce/apex/lightning_Util.upsertRecords";

// add Fee_Type__c to Loan_Fee__c query, show Fee_Amount__c in "Extension Fee" only if Fee_Type__c is "Extension Fee"
// show fee type in "Valuation Fee" only if Fee_Type__c is "Valuation Fee"
// show fee type in "Legal Fee" only if Fee_Type__c is "Legal Fee"
const RENO_TEMPLATE = "ExtensionScheduleARenovationTemplate";
const NONRENO_TEMPLATE = "ExtensionScheduleANonRenovationTemplate";
const CONTENT_TYPE = "application/vnd.ms-excel";

export default class ScheduleA extends LightningElement {
  @api prodSubtype;
  @api dealId;
  @api propertyIds;
  dealRecord;
  formRecords;
  user;
  templateFile;
  isPreparing = true;
  isLoaded = false;
  get message() {
    return this.isPreparing
      ? "Please wait while your document is being generated."
      : "Your document is ready.";
  }

  async renderedCallback() {
    if (this.isLoaded) {
      return;
    }
    if (this.propertyIds.length < 1) {
      this.showToast({
        title: "Error",
        message: "No property selected. Please select a property.",
        variant: "error"
      });
      this.handleCancel();
      return;
    } else {
      let tempName;
      console.log("PROPSUBTYPE", this.prodSubtype);
      if (this.prodSubtype && this.prodSubtype == "Renovation") {
        tempName = RENO_TEMPLATE;
      } else if (this.prodSubtype && this.prodSubtype == "No Renovation") {
        tempName = NONRENO_TEMPLATE;
      }
      if (tempName) {
        this.isLoaded = true;
        const tempRes = await getTemplate({ fileName: tempName });
        this.templateFile = tempRes;
        const tempUser = await getCurrentUserDetails();
        this.user = tempUser;
        this.retrieveRecordValues();
      }
    }
  }

  retrieveRecordValues() {
    console.log("RETRIEVING RECORD VALUES");
    loadScript(this, xlsxPopulate).then(() => {
      this.showPage = false;
      XlsxPopulate.fromDataAsync(
        this.base64ToArrayBuffer(JSON.parse(this.templateFile))
      )
        .then((workbook) => {
          const values = workbook.sheet("Schedule A").usedRange().value();
          const dealFields = ["Id"];
          const loanFeeFields = ["Fee_Type__c"];
          const propFields = [];
          const propExFields = [];
          const sobjectApiNames = [
            "Opportunity",
            "Property__c",
            "Property_Extension__c",
            "Loan_Fee__c"
          ];
          for (let i = 0; i < values.length; i++) {
            for (let j = 0; j < values[i].length; j++) {
              let value = values[i][j];
              if (
                typeof value === "string" &&
                value.includes(".") &&
                sobjectApiNames.includes(
                  value.replaceAll("{{", "").replaceAll("}}", "").split(".")[0]
                )
              ) {
                let cleanVal = value.replaceAll("{{", "").replaceAll("}}", "");
                let sobjectName = cleanVal.slice(0, cleanVal.indexOf("."));
                let fieldName = cleanVal.slice(
                  cleanVal.indexOf(".") + 1,
                  cleanVal.length
                );
                switch (sobjectName) {
                  case "Property__c":
                    if (!propFields.includes(fieldName)) {
                      propFields.push(fieldName);
                    }
                    break;
                  case "Opportunity":
                    if (!dealFields.includes(fieldName)) {
                      dealFields.push(fieldName);
                    }
                    break;
                  case "Property_Extension__c":
                    if (!propExFields.includes(fieldName)) {
                      propExFields.push(fieldName);
                    }
                    break;
                  case "Loan_Fee__c":
                    if (!loanFeeFields.includes(fieldName)) {
                      loanFeeFields.push(fieldName);
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
          const dealQuery = `SELECT ${dealFields.join(
            ","
          )} FROM Opportunity WHERE Id = '${this.dealId}'`;

          this.retrieveFormRecords(
            propFields,
            propExFields,
            loanFeeFields
          ).then(() => {
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
          this.handleCancel();
        });
    });
  }

  saveFile() {
    console.log("SAVING FILE");
    loadScript(this, xlsxPopulate).then(() => {
      let downloadFile;
      XlsxPopulate.fromDataAsync(
        this.base64ToArrayBuffer(JSON.parse(this.templateFile))
      )
        .then((workbook) => {
          const deal = this.dealRecord;
          const formRecords = this.formRecords;
          const values = [...workbook.sheet("Schedule A").usedRange().value()];
          for (let i = 0; i < 8; i++) {
            const row = values[i];
            for (let j = 0; j < row.length; j++) {
              const cellValue = row[j];
              let newValue = cellValue;
              if (
                typeof cellValue == "string" &&
                cellValue.includes("Opportunity.")
              ) {
                let oppField = cellValue
                  .replaceAll("{{", "")
                  .replaceAll("}}", "")
                  .replaceAll("Opportunity.", "");
                let childField;
                if(oppField.includes("__r.")) {
                  childField = oppField.split(".")[1];
                  oppField = oppField.split(".")[0];
                }
                if (deal.hasOwnProperty(oppField) && !childField) {
                  newValue = deal[oppField];
                } else if(deal.hasOwnProperty(oppField) && deal[oppField].hasOwnProperty(childField)) {
                  newValue = deal[oppField][childField];
                }  else {
                  newValue = "";
                }
                workbook
                  .sheet("Schedule A")
                  .row(i + 1)
                  .cell(j + 1)
                  .value(newValue);
              }
            }
          }

          const propRow = values[8];

          const loanTypeMap = {
            7: "Extension Fee",
            8: "Valuation Fee",
            9: "Legal Fee"
          };

          if (formRecords.length === 0) {
            let rowNum = 9;
            for (let i = 0; i < propRow.length; i++) {
              workbook
                .sheet("Schedule A")
                .row(rowNum)
                .cell(i + 1)
                .value("");
            }
          } else {
            for (let i = 0; i < formRecords.length; i++) {
              let currXlsRow = 9 + i;
              const record = formRecords[i];
              for (let j = 0; j < propRow.length; j++) {
                let currCell = propRow[j];
                let newCell = "";
                if (
                  currCell != undefined &&
                  currCell.includes("Loan_Fee__c.")
                ) {
                  let loanFees = record["Loan_Fee__c"];
                 
                  let loanFeeField = currCell.slice(
                    currCell.indexOf(".") + 1,
                    currCell.length
                  );
                  for(const loanFee of loanFees) {
                    console.log(loanFee, loanFeeField);
                    if (
                      loanFee.hasOwnProperty(loanFeeField) &&
                      loanFee.hasOwnProperty("Fee_Type__c") &&
                      loanTypeMap[j] === loanFee.Fee_Type__c
                    ) {
                      newCell = this.isNumeric(loanFee[loanFeeField])
                        ? parseFloat(loanFee[loanFeeField])
                        : loanFee[loanFeeField];
  
                      if (
                        loanFeeField.toLowerCase().includes("fee") ||
                        loanFeeField.toLowerCase().includes("amount")
                      ) {
                        workbook
                          .sheet("Schedule A")
                          .row(currXlsRow)
                          .cell(j + 1)
                          .value(newCell)
                          .style("numberFormat", "$#,##0.00");
                      } else {
                        workbook
                          .sheet("Schedule A")
                          .row(currXlsRow)
                          .cell(j + 1)
                          .value(newCell);
                      }
                    } else {
                      workbook
                        .sheet("Schedule A")
                        .row(currXlsRow)
                        .cell(j + 1)
                        .value(newCell);
                    }
                  }
                  
                } else if (
                  currCell != undefined &&
                  !currCell.includes("Loan_Fee__c.") &&
                  !currCell.includes("FX")
                ) {
                  let parent = currCell.slice(0, currCell.indexOf("."));
                  let parentField = currCell.slice(
                    currCell.indexOf(".") + 1,
                    currCell.length
                  );
                  if (
                    record.hasOwnProperty(parent) &&
                    record[parent].hasOwnProperty(parentField)
                  ) {
                    newCell = this.isNumeric(record[parent][parentField])
                      ? parseFloat(record[parent][parentField])
                      : record[parent][parentField];
                    if (parentField.toLowerCase().includes("interest_rate")) {
                      newCell = isNaN(parseFloat(newCell)) ? 0 : parseFloat(newCell) / 100;
                      workbook
                        .sheet("Schedule A")
                        .row(currXlsRow)
                        .cell(j + 1)
                        .value(newCell)
                        .style("numberFormat", "0.00%");
                    } else if (
                      parentField.toLowerCase().includes("fee") ||
                      parentField.toLowerCase().includes("amount")
                    ) {
                      workbook
                        .sheet("Schedule A")
                        .row(currXlsRow)
                        .cell(j + 1)
                        .value(newCell)
                        .style("numberFormat", "$#,##0.00");
                    } else {
                      workbook
                        .sheet("Schedule A")
                        .row(currXlsRow)
                        .cell(j + 1)
                        .value(newCell);
                    }
                  } else {
                    workbook
                      .sheet("Schedule A")
                      .row(currXlsRow)
                      .cell(j + 1)
                      .value(newCell);
                  }
                } else if (currCell != undefined && currCell.includes("FX")) {
                  let oper = currCell.slice(
                    currCell.indexOf("-") + 1,
                    currCell.lastIndexOf("-")
                  );
                  let cols = currCell
                    .slice(currCell.lastIndexOf("-") + 1, currCell.indexOf("}"))
                    .split(",");
                  let formula = `=${cols[0]}${currXlsRow}-${cols[1]}${currXlsRow}`;
                  workbook
                    .sheet("Schedule A")
                    .row(currXlsRow)
                    .cell(j + 1)
                    .formula(formula);
                } else {
                  workbook
                    .sheet("Schedule A")
                    .row(currXlsRow)
                    .cell(j + 1)
                    .value(newCell);
                }
                if (i == formRecords.length - 1) {
                  for (let k = currXlsRow + 1; k < currXlsRow + 13; k++) {
                    workbook
                      .sheet("Schedule A")
                      .row(k)
                      .cell(j + 1)
                      .value("");
                  }
                }
              }
            }
          }
          for (let i = 9; i < values.length; i++) {
            const row = values[i];
            for (let j = 0; j < row.length; j++) {
              const cellValue = row[j];
              let newValue = cellValue;
              if (
                typeof cellValue == "string" &&
                cellValue.includes("Opportunity.")
              ) {
                let oppField = cellValue
                  .replaceAll("{{", "")
                  .replaceAll("}}", "")
                  .replaceAll("Opportunity.", "");
                if (deal.hasOwnProperty(oppField)) {
                  newValue = deal[oppField];
                } else {
                  newValue = "";
                }
                workbook
                  .sheet("Schedule A")
                  .row(i + 1 + formRecords.length)
                  .cell(j + 1)
                  .value(newValue);
              } else if (
                typeof cellValue == "string" &&
                cellValue.includes("FX") &&
                !cellValue.includes("TOTAL")
              ) {
                let oper = cellValue
                  .slice(cellValue.indexOf("-") + 1, cellValue.lastIndexOf("-"))
                  .toUpperCase();
                let col = cellValue.slice(
                  cellValue.lastIndexOf("-") + 1,
                  cellValue.indexOf("}")
                );
                let formula = `=${oper}(${col}9:${col}${
                  9 + formRecords.length
                })`;
                workbook
                  .sheet("Schedule A")
                  .row(i + 1 + formRecords.length)
                  .cell(j + 1)
                  .formula(formula)
                  .style("numberFormat", "$#,##0.00");
              } else if (
                typeof cellValue == "string" &&
                cellValue.includes("TOTAL")
              ) {
                let formula = `=SUM(G${14 + formRecords.length}:G${
                  17 + formRecords.length
                })`;
                workbook
                  .sheet("Schedule A")
                  .row(i + 1 + formRecords.length)
                  .cell(j + 1)
                  .formula(formula)
                  .style("numberFormat", "$#,##0.00");
              } else {
                workbook
                  .sheet("Schedule A")
                  .row(i + 1 + formRecords.length)
                  .cell(j + 1)
                  .value(newValue);
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
              fileName: `Schedule A - ${this.prodSubtype}.xlsx`,
              fileType: CONTENT_TYPE,
              data: res
            })
          }).then((fileId) => {
            this.createDealDocuments(fileId).then((res) => {
              this.showToast({
                title: "Success",
                message: "File saved successfully",
                variant: "success"
              });
              let link = document.createElement("a");
              link.href =
                "data:" + XlsxPopulate.MIME_TYPE + ";base64," + downloadFile;
              link.download = `Schedule A - ${this.prodSubtype}.xlsx`;
              document.body.appendChild(link);
              link.click();
              this.isPreparing = false;
              this.handleCancel();
            });
          });
        })
        .catch((err) => {
          console.error(err);
          this.showToast({
            title: "Error",
            message: "Error generating file. Message: " + err,
            variant: "error"
          });
          this.handleCancel();
        });
    });
  }

  handleCancel() {
    this.dispatchEvent(new CustomEvent("cancel"));
  }

  async createDealDocuments(fileId) {
    const propIds = this.propertyIds
      .replaceAll("(", "")
      .replaceAll(")", "")
      .replaceAll("'", "")
      .split(",");
    const dealId = this.dealId;
    const dealDocs = [];
    const queryString = `SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id='${fileId}'`;
    const queryResult = await queryRecord({ queryString });
    const file = queryResult[0];
    for (let i = 0; i < propIds.length; i++) {
      dealDocs.push({
        sobjectType: "Deal_Document__c",
        File_Name__c: file.Title,
        Property__c: propIds[i],
        ContentVersion_Id__c: file.LatestPublishedVersionId,
        Attachment_Id__c: fileId,
        Section__c: "Property Level Documents",
        Document_Loaded__c: true,
        Document_Type__c: "Schedule A",
        Added_By__c: this.user.Id,
        Deal__c: dealId
      });
    }
    await upsertRecords({ records: dealDocs });
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

  showToast({ title, message, variant }) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
  isNumeric(str) {
    if (typeof str == "number") return true;
    if (typeof str != "string") return false; // we only process strings!
    return (
      !isNaN(str) && // use type coercion to parse the _entirety_ of the string (`parseFloat` alone does not do this)...
      !isNaN(parseFloat(str))
    ); // ...and ensure strings of whitespace fail
  }

  async retrieveFormRecords(propFields, propExFields, loanFeeFields) {
    const propFieldString = "Id, " + propFields.join(", ");
    const propExFieldString = "Id, Property__c, " + propExFields.join(", ");
    const loanFeeFieldString =
      "Id, Property__c, Property_Extension__c, " + loanFeeFields.join(", ");

    const propQS = `SELECT ${propFieldString}, (SELECT ${propExFieldString} FROM Property_Extensions__r ORDER BY CreatedDate DESC LIMIT 1) FROM Property__c WHERE Id IN ${this.propertyIds}`;
    const props = await queryRecord({ queryString: propQS });
    const records = {};
    const propExIds = [];
    for (const p of props) {
      let recLocal = {};
      if (
        !p.hasOwnProperty("Property_Extensions__r") ||
        (p.hasOwnProperty("Property_Extensions__r") &&
          p.Property_Extensions__r.length == 0)
      ) {
        this.showToast({
          title: "Error",
          message:
            "No property extension found for property " +
            p.Name +
            ". Please create a property extension first.",
          variant: "error"
        });
        this.handleCancel();
        return;
      }
      const propEx = p.Property_Extensions__r[0];
      recLocal = {
        Property__c: { ...p },
        Property_Extension__c: { ...propEx },
        Loan_Fee__c: []
      };
      records[p.Id] = recLocal;
      propExIds.push(propEx.Id);
    }
    const loanFeeQS = `SELECT ${loanFeeFieldString} FROM Loan_Fee__c WHERE Property_Extension__c IN ('${propExIds.join(
      "','"
    )}')`;
    const loanFees = await queryRecord({ queryString: loanFeeQS });
    for (const lf of loanFees) {
      records[lf.Property__c].Loan_Fee__c.push(lf);
    }
    this.formRecords = Object.values(records);
  }
}
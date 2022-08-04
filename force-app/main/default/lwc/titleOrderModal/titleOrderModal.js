import { api, LightningElement } from "lwc";
import returnDataTapeJson from "@salesforce/apex/TitleOrder_LightningHelper.returnDataTapeJson";
import SheetJS2 from "@salesforce/resourceUrl/SheetJS2";
import { loadScript } from "lightning/platformResourceLoader";
import { deleteRecord, getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import quoteRequest from "@salesforce/apex/TitleOrder_LightningHelper.quoteRequest";

export default class TitleOrderModal extends LightningElement {
  @api recordId;
  @api requestType;
  propertyIds = [];
  @api requestTypeText;
  uploadedFile;
  comments = "";
  titleOrderIds = [];

  get pill() {
    if (!this.uploadedFile) {
      return [];
    } else {
      return [
        {
          type: "icon",
          href: "",
          label: this.uploadedFile.name,
          name: "filePill",
          iconName: "doctype:excel",
          alternativeText: "Excel file"
        }
      ];
    }
  }

  get showPill() {
    return this.pill.length > 0;
  }

  get acceptedFormats() {
    return [".xls", ".xlsx"];
  }

  handleCommentInput(evt) {
    this.comments = evt.detail.value;
  }

  handleFileRemove() {
    deleteRecord(this.uploadedFile.documentId)
      .then(() => {
        this.uploadedFile = null;
        this.checkIfImportsAreDisabled();
      })
      .catch((err) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error deleting record",
            message: err.body.message,
            variant: "error"
          })
        );
      });
  }

  async downloadDataTape() {
    console.log([...this.propertyIds]);
    const jsonData = await returnDataTapeJson({
      propertyIds: [...this.propertyIds]
    });
    await this.createDataTape(jsonData);
  }

  handleUploadFinished(evt) {
    evt.preventDefault();
    this.uploadedFile = evt.detail.files[0];
    console.log("FILE UPLOADED");
    console.log(this.showPill);
  }

  @api
  openModal(propIds, titleOrderIds) {
    this.propertyIds = [...propIds];
    this.titleOrderIds = [...titleOrderIds];
    if(this.requestType != "quoteRequest" && titleOrderIds.length === 0) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Please select a Title Order first.",
          message: "This request requires at least one title order record to proceed.",
          variant: "error"
        })
      );
      return;
    }
    this.template.querySelector("c-modal").openModal();
  }

  async handleSubmit() {
    switch (this.requestType) {
      case "quoteRequest":
        await quoteRequest({
          propertyIds: this.propertyIds,
          dealId: this.recordId,
          cdId: this.uploadedFile.documentId
        });
        break;
      case "quoteAccepted":
        console.log(JSON.stringify(this.titleOrderIds));
        break;
      default:
        break;
    }
  }

  closeModal() {
    this.template.querySelector("c-modal").closeModal();
    this.dispatchEvent(new CustomEvent("close"));
  }

  async createDataTape(jsonString) {
    console.log(jsonString);
    loadScript(this, SheetJS2 + "/dist/xlsx.core.min.js").then(() => {
      const workbook = XLSX.utils.book_new();
      const fileName = "DataTape";
      const dataSheet = XLSX.utils.json_to_sheet(JSON.parse(jsonString));
      XLSX.utils.book_append_sheet(
        workbook,
        dataSheet,
        fileName.replace("/", "")
      );
      XLSX.writeFile(workbook, "DataTape.xlsx");
    });
  }
}

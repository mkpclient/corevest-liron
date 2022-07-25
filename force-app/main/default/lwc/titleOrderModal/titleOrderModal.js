import { api, LightningElement } from "lwc";
import returnDataTapeJson from "@salesforce/apex/TitleOrder_LightningHelper.returnDataTapeJson";
import SheetJS2 from "@salesforce/resourceUrl/SheetJS2";
import { loadScript } from "lightning/platformResourceLoader";
import { deleteRecord, getRecord} from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import quoteRequest from "@salesforce/apex/TitleOrder_LightningHelper.quoteRequest";

export default class TitleOrderModal extends LightningElement {
  @api recordId;
  @api requestType;
  propertyIds = [];
  @api isOpened = false;
  uploadedFile;
  comments = '';

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
  openModal(propIds) {
    this.propertyIds = [...propIds];
    this.template.querySelector("c-modal").openModal();
  }

  async handleSubmit() {
    await quoteRequest({ propertyIds : this.propertyIds, dealId : this.recordId, cdId: this.uploadedFile.documentId});
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

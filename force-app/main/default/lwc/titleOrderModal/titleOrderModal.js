import { api, LightningElement } from 'lwc';
import returnDataTapeJson from "@salesforce/apex/TitleOrder_LightningHelper.returnDataTapeJson";
import SheetJS2 from "@salesforce/resourceUrl/SheetJS2";
import { loadScript } from "lightning/platformResourceLoader";

export default class TitleOrderModal extends LightningElement {
  @api requestType;
  propertyIds = [];
  @api isOpened = false;
  
  async loadData() {
    console.log([...this.propertyIds]);
    const jsonData = await returnDataTapeJson({ propertyIds : [...this.propertyIds] });
    await this.createDataTape(jsonData);
  }

  @api
  async openModal(propIds) {
    this.propertyIds = [...propIds];
    await this.loadData();
    this.template.querySelector("c-modal").openModal();
  }

  
  handleSubmit() {

  }

  closeModal() {
    this.template.querySelector("c-modal").closeModal();
    this.dispatchEvent(new CustomEvent('close'));
  }

  async createDataTape(jsonString) {
    loadScript(this, SheetJS2 + "/dist/xlsx.core.min.js")
    .then(() => {
      const workbook = XLSX.utils.book_new();
      const fileName = 'DataTape';
      const dataSheet = XLSX.utils.json_to_sheet(JSON.parse(jsonString));
      XLSX.utils.book_append_sheet(workbook, dataSheet, fileName.replace('/', ''));
      XLSX.writeFile(workbook, 'DataTape.xlsx') 
    });
  }
}
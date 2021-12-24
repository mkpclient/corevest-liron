import { LightningElement, api } from "lwc";

export default class RenderPdf extends LightningElement {
  @api fileId;
  @api heightInRem;
  @api pageNumber;

  get pdfHeight() {
    return this.heightInRem + "rem";
  }
  get url() {
    let url = "/sfc/servlet.shepherd/document/download/" + this.fileId;
    if(this.pageNumber) {
      url += "#page=" + this.pageNumber;
    }
    return url;
  }
}
import { api, LightningElement } from "lwc";

export default class TitleOrder extends LightningElement {
  @api recordId;
  activeVendorType = "Servicelink";
  
  titleOrderVendors = [
    "Servicelink"
  ];
  
  handleActive(evt) {
    this.activeVendorType = evt.target.value;
  }
}
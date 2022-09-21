import queryRecords from "@salesforce/apex/lightning_Util.query";
import { api, LightningElement } from "lwc";

export default class CustomAlert extends LightningElement {
  @api recordId;

  @api
  get textColor() {
    return this._textColor;
  }

  set textColor(value) {
    this._textColor = value;
  }

  @api
  get bgColor() {
    return this._bgColor;
  }

  set bgColor(value) {
    this._bgColor = value;
  }

  @api
  get iconName() {
    return this._iconName;
  }

  set iconName(value) {
    this._iconName = value;
  }

  @api 
  get variant () {
    return this._variant;
  }

  set variant(value) {
    this._variant = value;
  }

  get iconVariant() {
    let iconVariant = "";
    if(this.variant && !this.bgColor) {
      iconVariant = this.variant !== "Warning" ?  "inverse" : "";
    } else if (this.bgColor && this.bgColor.includes("#")) {
      let c = this.bgColor.substring(1);
      let rgb = parseInt(c, 16);
      let r = (rgb >> 16) & 0xff;
      let g = (rgb >> 8) & 0xff;
      let b = (rgb >> 0) & 0xff;
      let luma = 0.2126 * r + 0.7152 * g + 0.0722 * b;
      if(luma >= 40) {
        iconVariant = "inverse";
      }
    }

    return iconVariant;
  }

  get divStyle() {
    return !this.bgColor ? "" : "background-color:" + this.bgColor;
  }

  get variantClass() {
    if(this.divStyle) {
      return "";
    }

    return !this.variant ? "slds-alert_warning"  : this.variant === "Informational" ? "" : "slds-alert_" + this.variant.toLowerCase();
  }

  get divClass() {
    return "slds-notify slds-notify_alert " + this.variantClass;
  }

  get textColorStyle() {
    return !this.textColor ? "" : "color:" + this.textColor;
  }

  get iconNameLocal() {
    return !this.iconName ? "utility:warning" : this.iconName;
  }

  @api
  get alertText() {
    return this._alertText;
  }

  set alertText(value) {
    this._alertText = value;
  }

  @api
  get soqlQuery() {
    return this._soqlQuery;
  }

  set soqlQuery(value) {
    let soqlLocal = value;
    if (soqlLocal && soqlLocal.includes(":recordId:")) {
      soqlLocal = soqlLocal.replace(":recordId:", this.recordId);
    }
    this._soqlQuery = soqlLocal;
  }

  loadComponent;

  async connectedCallback() {
    if(!this.soqlQuery) {
      this.loadComponent = true;
      return;
    }
    let res = await queryRecords({ queryString: this.soqlQuery });

    if (res && res.length > 0) {
      this.loadComponent = true;
    }
  }
}
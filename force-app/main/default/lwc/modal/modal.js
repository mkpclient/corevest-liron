import { LightningElement, track, api } from "lwc";

export default class Modal extends LightningElement {
  @api title;
  @api isOpen;
  @track isLoading = false;
  @api backdropHidden = false;

  @api toggleModal() {
    this.isOpen = !this.isOpen;
  }

  @api toggleLoading() {
    this.isLoading = !this.isLoading;
  }

  @api showSpinner() {
    this.isLoading = true;
  }

  @api hideSpinner() {
    this.isLoading = false;
  }

  @api openModal() {
    this.isOpen = true;
  }

  @api closeModal() {
    this.isOpen = false;
  }

  get spinnerClass() {
    return this.isLoading ? "" : "slds-hide";
  }

  //   get modalLoaded() {
  //     return !this.modalLoading;
  //   }

  get modalClass() {
    return this.isOpen ? "slds-modal slds-fade-in-open" : "slds-modal";
  }

  get backdropClass() {
    return this.isOpen && !this.backdropHidden
      ? "slds-backdrop slds-backdrop_open"
      : "slds-backdrop";
  }
}
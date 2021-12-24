import { LightningElement, api } from "lwc";
// import { loadStyle } from "lightning/platformResourceLoader";
// import EmailComposerCSS from "@salesforce/resourceUrl/EmailComposerCSS";

export default class EmailPillList extends LightningElement {
  @api emails = [];
  // @api field

  connectedCallback() {
    // try {
    //   loadStyle(this, EmailComposerCSS);
    // } catch (error) {
    //   console.log(error);
    // }
    // let stockData = ["mcastillo@mkpartners.com"];
    // this.emails = stockData;
  }

  get pillItems() {
    let items = [];

    this.emails.forEach((email) => {
      items.push({
        label: email,
        name: email
      });
    });

    return items;
  }

  removeEmail(event) {
    const name = event.detail.item.name;
    const index = event.detail.index;

    const emails = JSON.parse(JSON.stringify(this.emails));
    emails.splice(index, 1);

    this.emails = emails;

    const updateEvent = new CustomEvent("update", { detail: this.emails });
    this.dispatchEvent(updateEvent);
  }

  get showPillContainer() {
    return this.emails.length > 0;
  }

  handleInputBlur(event) {
    const isValidEmail = event.target.checkValidity();
    console.log(isValidEmail);
    console.log(event.target.value);

    if (isValidEmail) {
      const emails = JSON.parse(JSON.stringify(this.emails));
      emails.push(event.target.value);
      event.target.value = "";
      this.emails = emails;

      console.log(this.emails);

      const updateEvent = new CustomEvent("update", { detail: this.emails });
      this.dispatchEvent(updateEvent);
    }
  }
}
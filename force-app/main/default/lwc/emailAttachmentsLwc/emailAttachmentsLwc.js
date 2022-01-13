import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class EmailAttachmentsLwc extends NavigationMixin(
  LightningElement
) {
  @api possibilities;
  selectedAttachments = [];

  get localPossibilities() {
    return this.possibilities.map((p, i) => ({
      ...p,
      inputId: "add-checkbox-" + i
    }));
  }

  viewRecord = (evt) => {
    // Navigate to Account record page
    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      attributes: {
        recordId: evt.target.value,
        actionName: "view"
      }
    }).then((url) => {
      window.open(url, "_blank");
    });
  };

  selectAttachment = evt => {
    console.log("select clicked");
    let selectedAttachments = [...this.selectedAttachments];
    const state = evt.target.getAttribute("data-state");
    const recordId = evt.target.getAttribute("data-recordid");
    const recordName = evt.target.getAttribute("data-record");
    const recordType = evt.target.getAttribute("data-type") || "Attachment";
    const description = evt.target.getAttribute("data-description") || "";
    console.log(this.selectedAttachments);
    if (state === "unselected") {
      // console.log('inside not originally selected ')
      selectedAttachments.push({
        Id: recordId,
        Name: recordName,
        Type: recordType,
        Description: description
      });
      evt.target.setAttribute("data-state", "selected");
      evt.target.setAttribute("checked", true);
      this.selectedAttachments = [...selectedAttachments];
      this.dispatchEvent(new CustomEvent('select', {detail: JSON.stringify([...this.selectedAttachments])}));
    } else if (state === "selected") {
      this.selectedAttachments = selectedAttachments.filter(a => a.Id !== recordId);
      evt.target.setAttribute("data-state", "unselected");
      evt.target.setAttribute("checked", false);
      this.dispatchEvent(new CustomEvent('select', {detail: JSON.stringify([...this.selectedAttachments])}));
    }
  };
}
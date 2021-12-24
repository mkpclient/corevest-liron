import { LightningElement, api, track, wire } from 'lwc';
// import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class PropertyDetailsCard extends LightningElement {
    @api recordId;
    @track activeSections = [];
    @track activeSectionsMessage = '';

    // @wire(getlayoutType, {})
    // wireLayoutType({ error, data }) {
    //     if (layoutType === 'Payoff Details') {
    //         this.isPropertyDetails = true;
    //     }
    // }

    // handleSectionToggle(event) {
    //     const openSections = event.detail.openSections;

    //     if (openSections.length === 0) {
    //         this.activeSectionsMessage = 'All sections are closed';
    //     } else {
    //         this.activeSectionsMessage =
    //             'Open sections: ' + openSections.join(', ');
    //     }
    // }

    handleReset(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
     }

    fireToast() {
        const event = new ShowToastEvent({
          title: "Success!",
          message: "The Payoff Details have been successfully updated.",
          variant: "success",
        });
        this.dispatchEvent(event);
    }
}
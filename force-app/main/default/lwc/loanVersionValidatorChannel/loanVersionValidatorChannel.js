import { api, LightningElement, wire } from "lwc";
// import {
//   subscribe,
//   unsubscribe,
//   APPLICATION_SCOPE,
//   MessageContext,
//   publish
// } from "lightning/messageService";

import validatorMessageChannel from "@salesforce/messageChannel/LoanVersionValidator__c";
export default class LoanVersionValidatorChannel extends LightningElement {
  connectedCallback() {
    console.log("validator channel init");
  }

  // @wire(MessageContext)
  // messageContext;
  // @api
  // publish(payload) {
  //   publish(this.messageContext, validatorMessageChannel, payload);
  // }
}
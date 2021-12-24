import { LightningElement, api } from "lwc";
import queryDupes from "@salesforce/apex/DuplicateCheckJobHelper.getDupeListFromDeal";
import query from "@salesforce/apex/lightning_Util.query";

export default class DupeList extends LightningElement {
  @api recordId = "0065b00000pezH2AAI";
  dupeList = [];
  connectedCallback() {
    // if (!this.isChild) {
    this.queryDupes();
    // }
  }

  openModal() {
    console.log("open modal");
    this.template.querySelector("c-dupe-list-modal").openModal(this.dupeList);
  }

  queryProperties() {}

  async queryDupes() {
    const dupes = await queryDupes({ dealId: this.recordId });
    console.log("---dupes--");
    console.log(dupes);
    this.dupeList = dupes;
    //this.transformDupeList(dupes);
  }

  get display() {
    return this.dupeList.length > 0;
  }

  // transformDupeList(dupeList) {
  //   console.log("inside transform dupelist");
  //   const idSet = new Set();
  //   dupeList.forEach((dupe) => {
  //     idSet.add(`'${dupe.sourceId}'`);
  //     idSet.add(`'${dupe.matchId}'`);
  //   });

  //   const propertyFields = [
  //     "Id",
  //     "Name",
  //     "Deal__c",
  //     "Deal__r.Name",
  //     "Deal__r.StageName",
  //     "CreatedDate",
  //     "Deal__r.Owner.Name",
  //     "Deal__r.CloseDate",
  //     "Deal__r.CAF_Analyst__r.Name"
  //   ];

  //   let queryString = `SELECT ${propertyFields.join(
  //     ","
  //   )} FROM Property__c WHERE Id IN (${Array.from(idSet).join(", ")})`;

  //   query({ queryString: queryString }).then((results) => {
  //     results.forEach((property) => {
  //       if (!property.Deal__r.CAF_Analyst__r) {
  //         property.Deal__r.CAF_Analyst__r = { Name: "" };
  //       }

  //       dupeList.forEach((dupe) => {
  //         if (property.Id === dupe.sourceId) {
  //           dupe.source = property;
  //           dupe.href = `/lightning/r/Property__c/${dupe.source.Id}/view`;
  //           dupe.deal_href = `/lightning/r/Opportunity/${dupe.source.Deal__c}/view`;
  //           this.dealId = dupe.source.Deal__c;
  //         } else if (property.Id === dupe.matchId) {
  //           dupe.match = property;
  //           dupe.match_href = `/lightning/r/Property__c/${dupe.match.Id}/view`;
  //           dupe.match_deal_href = `/lightning/r/Opportunity/${dupe.match.Deal__c}/view`;
  //         }
  //       });
  //     });

  //     dupeList.forEach((dupe) => {
  //       dupe.key = `${dupe.source.Id}-${dupe.match.Id}`;
  //     });

  //     this.dupeList = dupeList;
  //   });
  // }
}
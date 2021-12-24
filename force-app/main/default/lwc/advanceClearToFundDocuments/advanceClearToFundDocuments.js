import { LightningElement, api } from "lwc";
import upsert from "@salesforce/apex/lightning_Controller.upsertRecords";
import query from "@salesforce/apex/lightning_Util.query";
import { NavigationMixin } from "lightning/navigation";

export default class AdvanceClearToFundDocuments extends NavigationMixin(
  LightningElement
) {
  documents = [];

  @api openModal(documents) {
    console.log(documents);
    this.documents = documents;

    this.template.querySelector("c-modal").openModal();
  }

  handleUpdate(event) {
    const index = event.target.getAttribute("data-index");
    const checked = event.target.checked;

    console.log(index);
    console.log(checked);

    const documents = JSON.parse(JSON.stringify(this.documents));
    documents[index].checked = checked;
    this.documents = documents;
  }

  reviewDocuments() {
    //const indexMap = {};

    const hasChecked = false;

    const records = [];
    this.documents.forEach((document, index) => {
      if (document.checked && !document.Reviewed_By__c) {
        records.push({
          sobjectType: "Deal_Document__c",
          Reviewed__c: true,
          Id: document.Id
        });
      }
    });

    if (records.length > 0) {
      console.log(records);

      upsert({ records: records })
        .then((results) => {
          const ids = [];
          this.documents.forEach((document) => {
            ids.push(`'${document.Id}'`);
          });

          let queryString =
            "SELECT Id, File_Name__c, Attachment_Id__c, Reviewed_By__r.Name, Reviewed_On__c FROM Deal_Document__c";
          queryString += ` WHERE ID IN (${ids.join(",")})`;
          queryString += ` ORDER BY CreatedDate DESC `;

          this.dispatchEvent(new CustomEvent("update"));

          return query({ queryString });
        })
        .then((data) => {
          //   console.log(data);
          //   data.forEach((d) => {
          //     d.Reviewed_On__c = d.Reviewed_On__c.substring(
          //       0,
          //       d.Reviewed_On__c.indexOf("+")
          //     );
          //   });
          this.documents = data;
        });
    }

    //console.log(indexMap);
  }

  openFile(event) {
    const title = event.target.getAttribute("title");

    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "filePreview"
      },
      state: {
        recordIds: title
      }
    });
  }

  closeModal() {
    this.template.querySelector("c-modal").closeModal();
  }
}
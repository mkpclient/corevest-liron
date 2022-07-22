import { api, LightningElement, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import query from "@salesforce/apex/lightning_Util.query";

export default class IcSabApprovalScreen extends LightningElement {
  @api recordId;
  @api deal;
  @api properties;
  showCreditMemoInfo = false;
  creditMemoFields = [];
  guarantors = [];
  guarantorRecords = [];
  creditSummaryFields = [];
  showCredSummary = false;
  borrowerId;
  async connectedCallback() {
    console.log("callback");
    if (this.recordId) {
      console.log(this.recordId);
      let workItemRes = await query({
        queryString: `SELECT ProcessInstanceId FROM ProcessInstanceWorkitem WHERE Id = '${this.recordId}'`
      });

      if (workItemRes.length == 0) {
        workItemRes = await query({
          queryString: `SELECT ProcessInstanceId FROM ProcessInstanceStep WHERE Id = '${this.recordId}'`
        });
      }

      console.log(workItemRes);
      const fields = [];
      if (workItemRes.length > 0) {
        const processRes = await query({
          queryString: `SELECT Id, (SELECT Id, StepStatus, ActorId, Actor.Name FROM StepsAndWorkitems WHERE StepStatus != 'Started') FROM ProcessInstance WHERE Id='${workItemRes[0].ProcessInstanceId}'`
        });

        processRes[0].StepsAndWorkitems.forEach((res) => {
          fields.push(
            {
              label: "Current Approver",
              value: res.Actor.Name
            },
            {
              label: "Credit Memo Status",
              value: res.StepStatus
            }
          );
        });
      }
      this.creditMemoFields = fields;

      const gtorQuery = `SELECT Id,Contact__r.Name, Liquidity__c, Percentage_Owned__c, Deal__r.Borrower_Entity__r.Name, Deal__r.Borrower_Entity__c FROM Deal_Contact__c WHERE Deal__c='${this.deal.Id}' AND Entity_Type__c includes ('Guarantor')`;
      const resGuarantors = await query({ queryString: gtorQuery });
      this.guarantorRecords = resGuarantors;
      const _guarantors = [];
      if (resGuarantors.length > 0) {
        resGuarantors.forEach((g) => {
          _guarantors.push({
            type: "url",
            label: g.Contact__r.Name,
            href: `/${g.Id}`,
            isLink: true
          });
        });
        this.guarantors = _guarantors;
      }

      let dealQuery = `SELECT Borrower_Entity__r.Name, Borrower_Entity__c, Borrower_Entity__r.Address_1__c, Borrower_Entity__r.Address_2__c,`;
      dealQuery += `Borrower_Entity__r.City__c,Borrower_Entity__r.Primary_Guarantor_Approval_Status__c,Borrower_Entity__r.State__c,Borrower_Entity__r.Zip__c,Distinct_Property_Types__c,Loan_Purpose__c,`;
      dealQuery += `Borrower_Entity__r.Entity_Type__c, Account.Repeat_Borrower__c, LOC_Term__c, Original_Line_Maturity_Date__c, Rate__c, Borrower_Entity__r.Borrower_Approval_Status__c `;
      dealQuery += `FROM Opportunity WHERE Id='${this.deal.Id}'`;

      const dealRes = await query({ queryString: dealQuery });
      const _credSumFields = [
        {
          fieldName: "Borrower_Entity__c",
          variant: "label-hidden",
          customLabel: "Borrower",
          isBorrowerField: false,
          isGuarantors: false
        },
        {
          label: "Entity Type",
          value: dealRes[0].Borrower_Entity__r.Entity_Type__c,
          type: "text",
          isBorrowerField: true,
          isGuarantors: false
        },
        {
          label: "Guarantor(s)",
          isBorrowerField: false,
          isGuarantors: true
        },
        {
          label: "Existing Borrower (Yes/No)",
          value: dealRes[0].Account.Repeat_Borrower__c ? "Yes" : "No",
          type: "text",
          isBorrowerField: true,
          isGuarantors: false
        },
        {
          label: "Street Address",
          value: `${
            dealRes[0].Borrower_Entity__r.Address_1__c
              ? dealRes[0].Borrower_Entity__r.Address_1__c
              : ""
          } ${
            dealRes[0].Borrower_Entity__r.Address_2__c
              ? dealRes[0].Borrower_Entity__r.Address_2__c
              : ""
          }`,
          type: "text",
          isBorrowerField: true,
          isGuarantors: false
        },
        {
          label: "Borrower Approval Status",
          value: dealRes[0].Borrower_Entity__r.Borrower_Approval_Status__c,
          type: "text",
          isBorrowerField: true,
          isGuarantors: false
        },
        {
          label: "City",
          value: dealRes[0].Borrower_Entity__r.City__c,
          type: "text",
          isBorrowerField: true,
          isGuarantors: false
        },
        {
          label: "Primary Guarantor Approval Status",
          value:
            dealRes[0].Borrower_Entity__r.Primary_Guarantor_Approval_Status__c,
          type: "text",
          isBorrowerField: true,
          isGuarantors: false
        },
        {
          label: "State",
          value: dealRes[0].Borrower_Entity__r.State__c,
          type: "text",
          isBorrowerField: true,
          isGuarantors: false
        },
        {
          fieldName: "LOC_Term__c",
          variant: "label-hidden",
          customLabel: "Loan Term (months)",
          isBorrowerField: false,
          isGuarantors: false
        },
        {
          label: "Zip",
          value: dealRes[0].Borrower_Entity__r.Zip__c,
          type: "text",
          isBorrowerField: true,
          isGuarantors: false
        },
        {
          fieldName: "Extension_Period_Days__c",
          variant: "label-hidden",
          customLabel: "Extension Term (months)",
          isBorrowerField: false,
          isGuarantors: false
        },
        {
          fieldName: "Distinct_Property_Types__c",
          variant: "label-hidden",
          customLabel: "Property Type",
          isBorrowerField: false,
          isGuarantors: false
        },
        {
          fieldName: "Original_Line_Maturity_Date__c",
          variant: "label-hidden",
          customLabel: "Loan Maturity Date",
          isBorrowerField: false,
          isGuarantors: false
        },
        {
          fieldName: "Loan_Purpose__c",
          variant: "label-hidden",
          customLabel: "Purpose",
          isBorrowerField: false,
          isGuarantors: false
        },
        {
          fieldName: "Rate__c",
          variant: "label-hidden",
          customLabel: "Interest Rate",
          isBorrowerField: false,
          isGuarantors: false
        }
      ];

      this.creditSummaryFields = _credSumFields.map((f, idx) => ({
        ...f,
        key: idx
      }));

      let borrowerQuery = `SELECT Id FROM Deal_Contact__c WHERE Deal__c='${this.deal.Id}' AND Entity_Type__c includes ('Borrower') ORDER BY CreatedDate DESC LIMIT 1`;
      let borrowerRes = await query({ queryString: borrowerQuery });
      console.log(borrowerRes);
      if (borrowerRes.length > 0) {
        this.borrowerId = borrowerRes[0].Id;
      }
    }
  }

  showSection(event) {
    const val = event.target.value;
    if (val === "creditMemo") {
      this.showCreditMemoInfo = !this.showCreditMemoInfo;
    } else if (val === "credSummary") {
      this.showCredSummary = !this.showCredSummary;
    } else if (val === "borrowerProfile") {
      this.showBorrowerProfile = !this.showBorrowerProfile;
    } else if (val === "borrowerStructure") {
      this.showBorrowerStructure = !this.showBorrowerStructure;
    }
  }

  get dealFields() {
    return [
      {
        fieldName: "Name",
        variant: "label-hidden",
        customLabel: "Loan",
        value: "/" + this.deal.Id,
        label: this.deal.Name,
        isUrl: true
      },
      {
        fieldName: "OwnerId",
        variant: "label-hidden",
        customLabel: "Contact Owner (Originator)"
      },
      {
        fieldName: "StageName",
        variant: "label-hidden",
        customLabel: "Loan Stage"
      },
      {
        fieldName: "Loan_Coordinator__c",
        variant: "label-hidden",
        customLabel: "Account Owner (Processor)"
      },
      {
        fieldName: "Deal_Loan_Number__c",
        variant: "label-hidden",
        customLabel: "Loan Number"
      },
      {
        fieldName: "Underwriter__c",
        variant: "standard"
      },
      {
        fieldName: "CloseDate",
        variant: "standard"
      },
      {
        fieldName: "Underwriting_Exception__c",
        variant: "label-hidden",
        customLabel: "Policy Exceptions"
      },
      {
        fieldName: "LOC_Commitment__c",
        variant: "label-hidden",
        customLabel: "Total Loan Amount"
      }
    ];
  }
}
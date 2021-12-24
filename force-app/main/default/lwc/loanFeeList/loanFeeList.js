import { LightningElement, api, wire } from "lwc";
// import getVendors from "@salesforce/apex/VendorEntityListController.getVendors";
import getPicklists from "@salesforce/apex/lightning_Util.getPicklistValues";
import apexSearch from "@salesforce/apex/lightning_Util.search";
import query from "@salesforce/apex/lightning_Util.query";
import upsert from "@salesforce/apex/lightning_Util.upsertRecords";
import getUser from "@salesforce/apex/lightning_Util.getUser";
import deleteRecords from "@salesforce/apex/lightning_Util.deleteRecords";

export default class LoanFeeLists extends LightningElement {
  @api recordId;

  @api loanFees;
  loading = false;
  editMode = false;
  vendorTypes;
  isLoading = false;
  berkadiaLoanFee = {};

  @api totalReserveAtClosing = 0;
  //    senderEmails = [];
  //    templates = [];

  @api displayOnly = false;

  params;
  selectedDate;
  selectedIndex;
  // user = { Id: "", Email: "test@example.com" };

  @api clickMe() {
    console.log("clicked");
  }

  connectedCallback() {
    console.log("loan fee hit");

    if (!this.displayOnly) {
      this.isLoading = true;
      this.setupBerkadiaLoanFee();
      //this.queryLoanFees();
    }

    // this.queryUser();
  }

  setupBerkadiaLoanFee = async () => {
    let queryString = `SELECT Id, Name, Payment_Instructions__c FROM Account WHERE Name = 'Berkadia Commercial Mortgage' AND RecordType.Name = 'Vendor'`;
    let results = await query({ queryString });

    let berkadiaAccount = results[0];

    let berkadiaLoanFee = {
      Vendor__c: berkadiaAccount.Id,
      Vendor__r: berkadiaAccount,
      Vendor_Type__c: "Servicer",
      Reference__c: "",
      Fee_Amount__c: 0
    };
    //console.log(berkadiaLoanFee);
    this.berkadiaLoanFee = berkadiaLoanFee;
    this.queryLoanFees();
  };

  queryLoanFees = async () => {
    let queryString = `SELECT Id,Vendor__c, Vendor__r.Name,vendor__r.Payment_Instructions__c, Vendor_Type__c, Reference__c, Fee_Amount__c `;
    queryString += ` from Loan_Fee__c`;
    queryString += ` WHERE Deal__c ='${this.recordId}'`;
    queryString += ` ORDER BY CreatedDate `;
    //FROM Deal_Contact__c
    //WHERE Deal__c =: recordId AND Deal_Contact_Type__c = 'Vendor'`
    console.log(queryString);
    query({ queryString: queryString })
      .then((results) => {
        let v = JSON.parse(JSON.stringify(results));
        let loanFees = [];
        //console.log(v);

        let feeList = [];

        v.forEach((loanFee) => {
          feeList.push(Object.assign({}, loanFee));
          loanFee.original = Object.assign({}, loanFee);

          // loanFee.original
          loanFees.push(loanFee);
        });

        feeList.push(this.berkadiaLoanFee);

        const updateEvent = new CustomEvent("update", { detail: feeList });
        this.dispatchEvent(updateEvent);

        this.loanFees = loanFees;
        this.editMode = false;
        this.isLoading = false;
      })
      .catch((error) => {
        console.log(error);
      });
  };

  queryUser() {
    getUser({})
      .then((results) => {
        console.log(results);
        let senderEmails = [{ label: results.Email, value: results.Id }];
        this.senderEmails = senderEmails;
        //this.user = results;
      })
      .catch((error) => {
        console.log(error);
        console.log("user error");
      });
  }

  queryFolder() {}

  // loadVendors() {
  //   getVendors({ recordId: this.recordId })
  //     .then(results => {
  //       let v = JSON.parse(JSON.stringify(results));
  //       let vendors = [];
  //       console.log(v);
  //       v.forEach(vendor => {
  //         vendor.original = Object.assign({}, vendor);
  //         vendors.push(vendor);
  //       });

  //       this.vendors = vendors;
  //       this.isLoading = false;
  //     })
  //     .catch(error => {
  //       console.log(error);
  //     });
  // }

  @wire(getPicklists, {
    sobjectType: "Loan_Fee__c",
    fieldName: "Vendor_Type__c"
  })
  wireVendorTypes({ error, data }) {
    let picklists = [];
    // if (data) {
    //   // picklists.push({label: data, value: da})
    //   //   picklists = picklists.concat(data);
    //   data.forEach((picklist) =>
    //     picklists.push({ label: picklist, value: picklist })
    //   );
    // } else if (error) {
    //   console.log(JSON.parse(JSON.stringify(error)));
    // }

    picklists = [
      { label: "3rd Party Title", value: "3rd Party Title" },
      { label: "Architect", value: "Architect" },
      { label: "Cash Management", value: "Cash Management" },
      { label: "Contractor", value: "Contractor" },
      { label: "Engineer", value: "Engineer" },
      { label: "Escrow Agent", value: "Escrow Agent" },
      { label: "Flood Check", value: "Flood Check" },
      { label: "Insurance", value: "Insurance" },
      { label: "Insurance Review", value: "Insurance Review" },
      { label: "Lease/Purchase Review", value: "Lease/Purchase Review" },
      { label: "Legal Counsel", value: "Legal Counsel" },
      { label: "Lender Diligence", value: "Lender Diligence" },
      {
        label: "LexisNexis Risk Solutions",
        value: "LexisNexis Risk Solutions"
      },
      { label: "MISC", value: "MISC" },
      { label: "Post Closing Holdback", value: "Post Closing Holdback" },
      { label: "Rent Deposit Bank", value: "Rent Deposit Bank" },
      { label: "Reserves", value: "Reserves" },
      { label: "Servicer", value: "Servicer" },
      { label: "Tax Verification", value: "Tax Verification" },
      { label: "Title and Escrow", value: "Title and Escrow" },
      { label: "Title and Escrow 2", value: "Title and Escrow 2" },
      { label: "Title Company", value: "Title Company" },
      { label: "Valuation", value: "Valuation" }
    ];

    console.log(picklists);

    this.vendorTypes = picklists;
  }

  //   get options(){

  //       return [];
  //   }

  get loanFeeList() {
    let loanFees = JSON.parse(JSON.stringify(this.loanFees));
    //console.log(loanFees);
    loanFees.forEach((loanFee) => {
      let styleClass = {
        Vendor__c: "slds-cell-edit",
        Reference__c: "slds-cell-edit",
        Fee_Amount__c: "slds-cell-edit",
        Vendor_Type__c: "slds-cell-edit"
      };
      let urls = {};
      for (let key in loanFee) {
        if (loanFee.original.hasOwnProperty(key)) {
          // changed[key] = loanFee.original[key] !== loanFee[key];
          styleClass[key] =
            loanFee.original[key] !== loanFee[key]
              ? "slds-is-edited slds-cell-edit"
              : "slds-cell-edit";
        } else if (loanFee[key]) {
          styleClass[key] = "slds-is-edited slds-cell-edit";
        } else {
          styleClass[key] = "slds-cell-edit";
        }
      }

      let lookupSelections = { Vendor__c: [] };
      if (loanFee.Vendor__c) {
        lookupSelections.Vendor__c = [
          {
            icon: "standard:account",
            id: loanFee.Vendor__c,
            sObjectType: "Account",
            subtitle: "Account",
            title: loanFee.Vendor__r.Name
          }
        ];

        urls["Vendor__c"] =
          "/lightning/r/Account/" + loanFee.Vendor__c + "/view";
      } else {
        loanFee.Vendor__c = "";
      }

      loanFee.lookupSelections = lookupSelections;
      loanFee.urls = urls;
      loanFee.styleClass = styleClass;

      loanFee.vendorTypeOptions = [
        {
          label: "",
          value: "",
          selected:
            !loanFee.Vendor_Type__c || loanFee.Vendor_Type__c === ""
              ? "selected"
              : ""
        }
      ];
      loanFee.vendorTypeOptions = JSON.parse(JSON.stringify(this.vendorTypes));
      loanFee.vendorTypeOptions.forEach((type) => {
        if (type.label === loanFee.Vendor_Type__c) {
          type.selected = "selected";
        }
      });
    });

    // console.log("loanFee= ", loanFee);
    return loanFees;
  }

  toggleEdit() {
    if (!this.displayOnly) {
      this.editMode = !this.editMode;
    }
  }

  get isViewMode() {
    return !this.editMode;
  }

  get isEditMode() {
    return this.editMode;
  }

  cancel() {
    this.toggleEdit();
  }

  save() {
    this.isLoading = true;

    let loanFees = [];
    this.loanFees.forEach((loanFee) => {
      loanFees.push({
        Vendor_Type__c: loanFee.Vendor_Type__c ? loanFee.Vendor_Type__c : "",
        sobjectType: "Loan_Fee__c",
        Id: loanFee.Id ? loanFee.Id : null,
        Deal__c: loanFee.Deal__c,
        Fee_Amount__c: loanFee.Fee_Amount__c ? loanFee.Fee_Amount__c : "",
        Reference__c: loanFee.Reference__c ? loanFee.Reference__c : "",
        Vendor__c: loanFee.Vendor__c ? loanFee.Vendor__c : ""
      });
    });
    //console.log(loanFees);
    upsert({ records: loanFees })
      .then((result) => {
        this.queryLoanFees();
      })
      .catch((error) => {
        console.log(error);
      });

    //console.log(loanFees);
  }

  updateValue(event) {
    //console.log(event);
    //console.log(event.target.value);
    //console.log(event.target.getAttribute("data-name"));

    // console.log(JSON.parse(JSON.stringify(event)));
    let fieldName = event.target.getAttribute("data-name");
    let index = event.target.getAttribute("data-index");

    let loanFees = JSON.parse(JSON.stringify(this.loanFees));
    loanFees[index][fieldName] = event.target.value;

    this.loanFees = loanFees;
  }

  handleQuery(event) {
    let index = event.detail.index;
    let fieldName = event.detail.name;

    let queryString = `SELECT Id, Name FROM`;
    if (fieldName === "Vendor__c") {
      //queryString += `Account (Id, Name WHERE RecordType.DeveloperName = 'Vendor' AND Account_Status__c = 'Active CoreVest Vendor')`;
      queryString += ` Account WHERE RecordType.DeveloperName = 'Vendor' AND Account_Status__c = 'Active CoreVest Vendor' `;
    }

    queryString +=
      " AND LastViewedDate != null Order By LastViewedDate Desc LIMIT 5";

    console.log(queryString);

    query({ queryString: queryString })
      .then((results) => {
        //console.log(results);
        //console.log(this.template.querySelector("c-lookup"));
        //this.template.querySelector("c-lookup").setSearchResults(results);
        console.log(results);
        let searchResults = [];
        results.forEach((result) => {
          if (fieldName === "Vendor__c") {
            searchResults.push({
              id: result.Id,
              sObjectType: "Account",
              icon: "standard:account",
              title: result.Name,
              subtitle: result.Name
            });
          }
        });

        console.log(searchResults);

        this.template
          .querySelector(
            '[data-name="' +
              event.detail.name +
              '"][data-index="' +
              event.detail.index +
              '"]'
          )
          .setSearchResults(searchResults);
      })
      .catch((error) => {
        console.log("error");
        console.log(error);
        // TODO: handle error
      });
  }

  handleSearch(event) {
    //console.log("apex search");
    //console.log(JSON.stringify(event.data));

    console.log("handle search");

    if (event.detail.searchTerm) {
      let index = event.detail.index;
      let fieldName = event.detail.name;
      let searchTerm = event.detail.searchTerm + "*";
      console.log("search term");
      console.log(searchTerm);

      let searchQuery = `FIND '*' IN Name Fields RETURNING `;
      if (event.detail.searchTerm) {
        searchQuery = `FIND '${searchTerm}' IN Name Fields RETURNING `;
      }
      if (fieldName === "Vendor__c") {
        searchQuery += `Account (Id, Name WHERE RecordType.DeveloperName = 'Vendor' AND Account_Status__c = 'Active CoreVest Vendor')`;
      }

      console.log("searchQuery=", searchQuery);

      apexSearch({ searchQuery: searchQuery })
        .then((results) => {
          //console.log(results);
          //console.log(this.template.querySelector("c-lookup"));
          //this.template.querySelector("c-lookup").setSearchResults(results);
          console.log(results);
          let searchResults = [];
          results[0].forEach((result) => {
            if (fieldName === "Vendor__c") {
              searchResults.push({
                id: result.Id,
                sObjectType: "Account",
                icon: "standard:account",
                title: result.Name,
                subtitle: result.Name
              });
            }
          });

          console.log(searchResults);

          this.template
            .querySelector(
              '[data-name="' +
                event.detail.name +
                '"][data-index="' +
                event.detail.index +
                '"]'
            )
            .setSearchResults(searchResults);
        })
        .catch((error) => {
          console.log("error");
          console.log(error);
          // TODO: handle error
        });
    } else {
      this.handleQuery(event);
    }
  }

  handleSelectionChange(event) {
    let fieldName = event.detail.name;
    let index = event.detail.index;

    const selection = this.template
      .querySelector(
        '[data-name="' + fieldName + '"][data-index="' + index + '"]'
      )
      .getSelection();

    let loanFees = JSON.parse(JSON.stringify(this.loanFees));
    if (selection.length > 0) {
      let id = selection[0].id;
      let name = selection[0].title;

      if (fieldName === "Vendor__c") {
        loanFees[index].Vendor__c = id;
        loanFees[index].Vendor__r = {
          Id: id,
          Name: name
        };
        //loanFees[index].lookupSelections.Account__c = selection;
      }
    } else {
      if (fieldName === "Vendor__c") {
        loanFees[index].Vendor__c = "";
        loanFees[index].Vendor__r = {};
        //loanFees[index].lookupSelections.Account__c = [{}];
      }
      //vendors[index].lookupSelections.Contact__c = [{}];
      // else if(fieldName === 'Contact__c'){

      // }
    }
    this.loanFees = loanFees;
    //console.log(JSON.parse(JSON.stringify(selection)));

    // const selection = this.template.querySelector('')
  }

  refresh() {
    this.isLoading = true;

    this.queryLoanFees();
    //return refreshApex(this.results);
  }

  deleteLoanFees() {
    console.log("delete");
    let loanFees = JSON.parse(JSON.stringify(this.loanFees));
    let toKeep = [];
    let toDelete = [];
    this.template.querySelectorAll(".checkbox").forEach((checkbox) => {
      let index = checkbox.getAttribute("data-index");
      if (checkbox.checked) {
        toDelete.push(loanFees[index]);
      } else {
        toKeep.push(loanFees[index]);
      }
      // console.log(checkbox.checked);
    });

    this.loanFees = toKeep;
    //console.log(toDelete);

    if (toDelete.length > 0) {
      deleteRecords({ records: toDelete })
        .then((result) => {})
        .catch((error) => {
          console.log("delete error");
          console.log(error);
        });
    }
  }

  addLoanFee() {
    let loanFees = JSON.parse(JSON.stringify(this.loanFees));
    loanFees.push({
      Deal__c: this.recordId,
      original: {
        Deal__c: this.recordId,
        Id: "key-" + loanFees.length,
        sobjectType: "Loan_Fee__c"
      }
    });

    this.loanFees = loanFees;
  }

  checkAll() {
    console.log("checkall");
  }

  // closeModal() {
  //   this.template.querySelector("[data-name='selectedTemplate']").value = "";
  //   this.template.querySelector("c-modal").toggleModal();
  // }

  // openModal(event) {
  //   console.log(event.target.getAttribute("data-index"));

  //   this.template.querySelector("c-modal").showSpinner();
  //   this.template.querySelector("c-modal").toggleModal();

  //   let index = event.target.getAttribute("data-index");
  //   //console.log(this.vendors[index]);
  //   // let toAddress = this.template.querySelector(
  //   //   "lightning-input[data-name='toAddress']"
  //   // );
  //   // toAddress.value = this.vendors[index].Contact__r.Email;
  //   // toAddress.title = this.vendors[index].Contact__c;

  //   let params = {
  //     toAddressEmail: this.vendors[index].Contact__r.Email,
  //     recipientId: this.vendors[index].Contact__c,
  //     recordType: this.vendors[index].Deal__r.RecordType.Name
  //   };

  //   this.queryTemplates(event.target.getAttribute("data-index"), params);
  // }

  // queryTemplates(index, params) {
  //   let vendorType = this.vendors[index].Vendor_Type__c;

  //   let recordTypeName = "";
  //   if (params.recordType.includes("Term")) {
  //     recordTypeName = "Term";
  //   } else if (params.recordType.includes("Bridge")) {
  //     recordTypeName = "Bridge";
  //   }

  //   let folderName = `${vendorType} - ${recordTypeName}`;
  //   let queryString = `SELECT Id FROM Folder WHERE Name = '${folderName}'`;
  //   console.log(queryString);
  //   query({ queryString: queryString })
  //     .then((results) => {
  //       let folderId = "";
  //       if (results.length > 0) {
  //         folderId = results[0].Id;
  //       }

  //       //console.log(folderId);

  //       let templateQueryString = `SELECT Id, Name FROM EmailTemplate WHERE FolderId = '${folderId}'`;
  //       templateQueryString += ` OR Name = 'Blank Template - CoreVest Letterhead - ${recordTypeName}'`;
  //       return query({ queryString: templateQueryString });
  //     })
  //     .then((results) => {
  //       //console.log(results);
  //       console.log(results);
  //       console.log();
  //       this.template.querySelector("c-modal").hideSpinner();

  //       let templates = [];
  //       results.forEach((result) => {
  //         templates.push({ label: result.Name, value: result.Id });
  //       });

  //       params.templates = results;
  //       params.selectOptions = templates;
  //       this.params = params;

  //       console.log(this.template.querySelector("[data-name='modalDate']"));

  //       console.log(this.vendors[index].Order_Date__c);

  //       this.selectedDate = this.vendors[index].Order_Date__c;
  //       this.selectedIndex = index;

  //       // this.template.querySelector(
  //       //   "[data-name='modalDate']"
  //       // ).value = this.vendors[index].Order_Date__c;

  //       // this.template
  //       //   .querySelector("[data-name='modalDate']")
  //       //   .setAttribute("data-index", index);

  //       // const emailClickedEvent = new CustomEvent("openemail", {
  //       //   detail: params
  //       // });

  //       // this.dispatchEvent(emailClickedEvent);

  //       //this.templates = templates;
  //     })
  //     .catch((error) => {
  //       console.log(error);
  //       console.log("template query error");
  //     });
  // }

  // @api queryTemplate(templateId) {
  //   let queryString = `select id,Body, HtmlValue, Subject from emailtemplate where id = '${templateId}'`;

  //   return query({ queryString: queryString });
  // }

  // templateChanged(event) {
  //   let templateId = this.template.querySelector(
  //     "lightning-combobox[data-name='template']"
  //   ).value;

  //   let toId = this.template.querySelector(
  //     "lightning-input[data-name='toAddress']"
  //   ).title;
  //   //console.log(templateId);
  //   //console.log(toId);

  //   compileEmailTemplate({
  //     templateId: templateId,
  //     whoId: toId,
  //     whatId: this.recordId
  //   })
  //     .then(results => {
  //       //console.log(results);
  //       let message = JSON.parse(results);
  //       //console.log(message);

  //       this.template.querySelector("[data-name='templateInput']").value =
  //         message.htmlBody;

  //       //console.log(this.template.querySelector("[data-name='templateInput']"));
  //       this.template.querySelector("[data-name='subject']").value =
  //         message.subject;
  //     })
  //     .catch(error => {
  //       console.log("compile email error");
  //       console.log(error);
  //     });
  // }

  // @api compileEmail(params) {
  //   return compileEmailTemplate(params);
  // }

  // sendEmail() {
  //   let templateId = this.template.querySelector(
  //     "[data-name='selectedTemplate']"
  //   ).value;

  //   this.queryTemplate(templateId)
  //     .then((results) => {
  //       if (results.length > 0) {
  //         let template = results[0];

  //         let params = this.params;
  //         params.template = template;

  //         const emailClickedEvent = new CustomEvent("openemail", {
  //           detail: params
  //         });

  //         let vendors = JSON.parse(JSON.stringify(this.vendors));
  //         // console.log(this.index);
  //         // console.log(
  //         //   this.template.querySelector("[data-name='modalDate']").value
  //         // );
  //         vendors[
  //           this.selectedIndex
  //         ].Order_Date__c = this.template.querySelector(
  //           "[data-name='modalDate']"
  //         ).value;
  //         this.vendors = vendors;

  //         this.save();

  //         this.closeModal();
  //         this.dispatchEvent(emailClickedEvent);
  //       }
  //     })
  //     .catch((error) => {
  //       console.log(error);
  //       // console.log('que')
  //     });

  //   // console.log(selectedTemplate);
  //   // console.log(this.params);
  //   //
  // }

  // get propertyData(){
  //     let properties = JSON.parse(JSON.stringify(this.properties.data));
  //     // let properties = this.properties.data;
  //     properties.forEach(property => {
  //         property.url = '/lightning/r/Property__c/' + property.Id + '/view/';
  //     });

  //     return properties;
  // }

  // @wire(getRecordUi, {recordIds: ["$recordId"], layoutTypes: ["Full"], modes: ["View"], })
}
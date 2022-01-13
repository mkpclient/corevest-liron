import { LightningElement, api, track, wire } from "lwc";
// import getVendors from "@salesforce/apex/VendorEntityListController.getVendors";
import getPicklists from "@salesforce/apex/lightning_Util.getPicklistValues";
import apexSearch from "@salesforce/apex/lightning_Util.search";
import query from "@salesforce/apex/lightning_Util.query";
import upsert from "@salesforce/apex/lightning_Util.upsertRecords";
import getUser from "@salesforce/apex/lightning_Util.getUser";
import compileEmailTemplate from "@salesforce/apex/lightning_Util.compileEmailTemplate";
import deleteRecords from "@salesforce/apex/lightning_Util.deleteRecords";
import compileFieldPermissions from "@salesforce/apex/lightning_Util.compileFieldPermissions";

export default class VendorEntityList extends LightningElement {
  @api recordId;

  @track vendors;
  @track loading = false;
  @track editMode = false;
  @track vendorTypes;
  @track isLoading = true;
  @track senderEmails = [];
  @track templates = [];

  @track params;
  @track selectedDate;
  @track selectedIndex;
  @track permissionsMap = {
    sobject: {
      isAccessible: false,
      isUpdateable: false,
      isCreateable: false,
      isDeletable: false
    },
    Vendor_Type__c: {
      isAccessible: false,
      isUpdateable: false,
      isCreateable: false
    },
    Account__c: {
      isAccessible: false,
      isUpdateable: false,
      isCreateable: false
    },
    Contact__c: {
      isAccessible: false,
      isUpdateable: false,
      isCreateable: false
    },
    Order_Date__c: {
      isAccessible: false,
      isUpdateable: false,
      isCreateable: false
    },
    Completed_Date__c: {
      isAccessible: false,
      isUpdateable: false,
      isCreateable: false
    }
  };
  //@track user = { Id: "", Email: "test@example.com" };

  @api clickMe() {
    console.log("clicked");
  }

  connectedCallback() {
    this.queryVendors();
    this.queryUser();
    this.compileFieldPermissions();
  }

  queryVendors() {
    let queryString = `SELECT Id, Name, Deal__r.RecordType.Name, Account__c, Contact__c, Vendor_Type__c, Order_Date__c, Completed_Date__c, Account__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__r.Name, Contact__r.Email`;
    queryString += ` FROM Deal_Contact__c`;
    queryString += ` WHERE Deal__c ='${this.recordId}'`;
    queryString += ` AND Deal_Contact_Type__C = 'Vendor' ORDER BY Vendor_Type__c ASC`;
    //FROM Deal_Contact__c
    //WHERE Deal__c =: recordId AND Deal_Contact_Type__c = 'Vendor'`
    console.log(queryString);
    query({ queryString: queryString })
      .then((results) => {
        let v = JSON.parse(JSON.stringify(results));
        let vendors = [];
        console.log(v);
        v.forEach((vendor) => {
          vendor.original = Object.assign({}, vendor);
          // vendor.original
          vendors.push(vendor);
        });

        this.vendors = vendors;
        this.editMode = false;
        this.isLoading = false;
      })
      .catch((error) => {
        console.log(error);
      });
  }

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
    sobjectType: "Deal_Contact__c",
    fieldName: "Vendor_Type__c"
  })
  wireVendorTypes({ error, data }) {
    let picklists = [];
    if (data) {
      // picklists.push({label: data, value: da})
      //   picklists = picklists.concat(data);
      data.forEach((picklist) =>
        picklists.push({ label: picklist, value: picklist })
      );
    } else if (error) {
      console.log(JSON.parse(JSON.stringify(error)));
    }

    console.log(picklists);

    this.vendorTypes = picklists;
  }

  //   get options(){

  //       return [];
  //   }

  get vendorList() {
    let vendors = JSON.parse(JSON.stringify(this.vendors));
    //console.log(vendors);
    vendors.forEach((vendor) => {
      let styleClass = {
        Account__c: "slds-cell-edit",
        Order_Date__c: "slds-cell-edit",
        Completed_Date__c: "slds-cell-edit",
        Contact__c: "slds-cell-edit",
        Vendor_Type__c: "slds-cell-edit"
      };
      let urls = {};
      for (let key in vendor) {
        if (vendor.original.hasOwnProperty(key)) {
          // changed[key] = vendor.original[key] !== vendor[key];
          styleClass[key] =
            vendor.original[key] !== vendor[key]
              ? "slds-is-edited slds-cell-edit"
              : "slds-cell-edit";
        } else if (vendor[key]) {
          styleClass[key] = "slds-is-edited slds-cell-edit";
        } else {
          styleClass[key] = "slds-cell-edit";
        }
      }

      let lookupSelections = { Account__c: [], Contact__c: [] };
      if (vendor.Account__c) {
        lookupSelections.Account__c = [
          {
            icon: "standard:account",
            id: vendor.Account__c,
            sObjectType: "Account",
            subtitle: "Account",
            title: vendor.Account__r.Name
          }
        ];

        urls["Account__c"] =
          "/lightning/r/Account/" + vendor.Account__c + "/view";
      } else {
        vendor.Account__c = "";
      }

      if (vendor.Contact__c) {
        lookupSelections.Contact__c = [
          {
            icon: "standard:contact",
            id: vendor.Contact__c,
            sObjectType: "Contact",
            subtitle: "Contact",
            title: vendor.Contact__r.Name
          }
        ];

        urls["Contact__c"] =
          "/lightning/r/Contact/" + vendor.Contact__c + "/view";
        // console.log(vendor.Vendor_Type__c);
        if (
          vendor.Vendor_Type__c &&
          vendor.Id &&
          vendor.Contact__r &&
          vendor.Contact__r.Email
        ) {
          // console.log('send email true');
          vendor.sendEmail = true;
        }
      } else {
        vendor.Contact__c = "";
        vendor.sendEmail = false;
      }

      vendor.lookupSelections = lookupSelections;
      vendor.urls = urls;
      vendor.styleClass = styleClass;

      vendor.vendorTypeOptions = [
        {
          label: "",
          value: "",
          selected:
            !vendor.Vendor_Type__c || vendor.Vendor_Type__c === ""
              ? "selected"
              : ""
        }
      ];
      vendor.vendorTypeOptions = JSON.parse(JSON.stringify(this.vendorTypes));
      vendor.vendorTypeOptions.forEach((type) => {
        if (type.label === vendor.Vendor_Type__c) {
          type.selected = "selected";
        }
      });
    });

    console.log("vendors= ", vendors);
    return vendors;
  }

  toggleEdit() {
    this.editMode = !this.editMode;
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

    let vendors = [];
    this.vendors.forEach((vendor) => {
      vendors.push({
        Vendor_Type__c: vendor.Vendor_Type__c ? vendor.Vendor_Type__c : "",
        Deal_Contact_Type__c: "Vendor",
        sobjectType: "Deal_Contact__c",
        Id: vendor.Id ? vendor.Id : null,
        Deal__c: vendor.Deal__c,
        Order_Date__c: vendor.Order_Date__c ? vendor.Order_Date__c : "",
        Completed_Date__c: vendor.Completed_Date__c
          ? vendor.Completed_Date__c
          : "",
        Account__c: vendor.Account__c ? vendor.Account__c : "",
        Contact__c: vendor.Contact__c ? vendor.Contact__c : ""
      });
    });
    console.log(vendors);
    upsert({ records: vendors })
      .then((result) => {
        this.queryVendors();
      })
      .catch((error) => {
        console.log(error);
      });

    console.log(vendors);
  }

  updateValue(event) {
    //console.log(event);
    //console.log(event.target.value);
    //console.log(event.target.getAttribute("data-name"));

    // console.log(JSON.parse(JSON.stringify(event)));
    let fieldName = event.target.getAttribute("data-name");
    let index = event.target.getAttribute("data-index");

    let vendors = JSON.parse(JSON.stringify(this.vendors));
    vendors[index][fieldName] = event.target.value;

    this.vendors = vendors;
  }

  handleQuery(event) {
    let index = event.detail.index;
    let fieldName = event.detail.name;

    let queryString = `SELECT Id, Name FROM`;
    if (fieldName === "Account__c") {
      //queryString += `Account (Id, Name WHERE RecordType.DeveloperName = 'Vendor' AND Account_Status__c = 'Active CoreVest Vendor')`;
      queryString += ` Account WHERE RecordType.DeveloperName = 'Vendor' AND Account_Status__c = 'Active CoreVest Vendor' `;
    } else if (fieldName === "Contact__c") {
      let accountId = this.vendors[index].Account__c
        ? this.vendors[index].Account__c
        : "";
      queryString += ` Contact WHERE AccountId = '${accountId}'`;
    }

    queryString +=
      " ORDER BY LastViewedDate DESC NULLS LAST LIMIT 5";

    console.log(queryString);

    query({ queryString: queryString })
      .then((results) => {
        //console.log(results);
        //console.log(this.template.querySelector("c-lookup"));
        //this.template.querySelector("c-lookup").setSearchResults(results);
        console.log(results);
        let searchResults = [];
        results.forEach((result) => {
          if (fieldName === "Account__c") {
            searchResults.push({
              id: result.Id,
              sObjectType: "Account",
              icon: "standard:account",
              title: result.Name,
              subtitle: result.Name
            });
          } else if (fieldName == "Contact__c") {
            searchResults.push({
              id: result.Id,
              sObjectType: "Contact",
              icon: "standard:contact",
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
      if (fieldName === "Account__c") {
        searchQuery += `Account (Id, Name WHERE RecordType.DeveloperName = 'Vendor' AND Account_Status__c = 'Active CoreVest Vendor')`;
      } else if (fieldName === "Contact__c") {
        let accountId = this.vendors[index].Account__c
          ? this.vendors[index].Account__c
          : "";
        searchQuery += `Contact (Id, Name WHERE AccountId = '${accountId}')`;
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
            if (fieldName === "Account__c") {
              searchResults.push({
                id: result.Id,
                sObjectType: "Account",
                icon: "standard:account",
                title: result.Name,
                subtitle: result.Name
              });
            } else if (fieldName == "Contact__c") {
              searchResults.push({
                id: result.Id,
                sObjectType: "Contact",
                icon: "standard:contact",
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

    let vendors = JSON.parse(JSON.stringify(this.vendors));
    if (selection.length > 0) {
      let id = selection[0].id;
      let name = selection[0].title;

      if (fieldName === "Account__c") {
        vendors[index].Account__c = id;
        vendors[index].Account__r = {
          Id: id,
          Name: name
        };
        //vendors[index].lookupSelections.Account__c = selection;
      } else if (fieldName === "Contact__c") {
        vendors[index].Contact__c = id;
        vendors[index].Contact__r = {
          Id: id,
          Name: name
        };
        //vendors[index].lookupSelections.Contact__c = selection;
      }
    } else {
      if (fieldName === "Account__c") {
        vendors[index].Account__c = "";
        vendors[index].Account__r = {};
        //vendors[index].lookupSelections.Account__c = [{}];
      }
      vendors[index].Contact__c = "";
      vendors[index].Contact__r = {};
      //vendors[index].lookupSelections.Contact__c = [{}];
      // else if(fieldName === 'Contact__c'){

      // }
    }
    this.vendors = vendors;
    //console.log(JSON.parse(JSON.stringify(selection)));

    // const selection = this.template.querySelector('')
  }

  refresh() {
    this.isLoading = true;

    this.queryVendors();
    //return refreshApex(this.results);
  }

  deleteVendors() {
    console.log("delete");
    let vendors = JSON.parse(JSON.stringify(this.vendors));
    let toKeep = [];
    let toDelete = [];
    this.template.querySelectorAll(".checkbox").forEach((checkbox) => {
      let index = checkbox.getAttribute("data-index");
      if (checkbox.checked) {
        toDelete.push(vendors[index]);
      } else {
        toKeep.push(vendors[index]);
      }
      // console.log(checkbox.checked);
    });

    this.vendors = toKeep;
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

  addVendor() {
    let vendors = JSON.parse(JSON.stringify(this.vendors));
    vendors.push({
      Deal__c: this.recordId,
      Deal_Contact_Type__c: "Vendor",
      original: {
        Deal__c: this.recordId,
        Id: "key-" + vendors.length,
        sobjectType: "Deal_Contact__c"
      }
    });

    this.vendors = vendors;
  }

  checkAll() {
    console.log("checkall");
  }

  closeModal() {
    this.template.querySelector("[data-name='selectedTemplate']").value = "";
    this.template.querySelector("c-modal").toggleModal();
  }

  openModal(event) {
    console.log(event.target.getAttribute("data-index"));

    this.template.querySelector("c-modal").showSpinner();
    this.template.querySelector("c-modal").toggleModal();

    let index = event.target.getAttribute("data-index");
    //console.log(this.vendors[index]);
    // let toAddress = this.template.querySelector(
    //   "lightning-input[data-name='toAddress']"
    // );
    // toAddress.value = this.vendors[index].Contact__r.Email;
    // toAddress.title = this.vendors[index].Contact__c;

    let params = {
      toAddressEmail: this.vendors[index].Contact__r.Email,
      recipientId: this.vendors[index].Contact__c,
      recordType: this.vendors[index].Deal__r.RecordType.Name
    };

    this.queryTemplates(event.target.getAttribute("data-index"), params);
  }

  queryTemplates(index, params) {
    let vendorType = this.vendors[index].Vendor_Type__c;

    let recordTypeName = "";
    if (params.recordType.includes("Term")) {
      recordTypeName = "Term";
    } else if (params.recordType.includes("Bridge")) {
      recordTypeName = "Bridge";
    }

    let folderName = `${vendorType} - ${recordTypeName}`;
    let queryString = `SELECT Id FROM Folder WHERE Name = '${folderName}'`;
    console.log(queryString);
    query({ queryString: queryString })
      .then((results) => {
        let folderId = "";
        if (results.length > 0) {
          folderId = results[0].Id;
        }

        //console.log(folderId);

        let templateQueryString = `SELECT Id, Name FROM EmailTemplate WHERE FolderId = '${folderId}'`;
        templateQueryString += ` OR Name = 'Blank Template - CoreVest Letterhead - ${recordTypeName}'`;
        return query({ queryString: templateQueryString });
      })
      .then((results) => {
        //console.log(results);
        console.log(results);
        console.log();
        this.template.querySelector("c-modal").hideSpinner();

        let templates = [];
        results.forEach((result) => {
          templates.push({ label: result.Name, value: result.Id });
        });

        params.templates = results;
        params.selectOptions = templates;
        this.params = params;

        console.log(this.template.querySelector("[data-name='modalDate']"));

        console.log(this.vendors[index].Order_Date__c);

        this.selectedDate = this.vendors[index].Order_Date__c;
        this.selectedIndex = index;

        // this.template.querySelector(
        //   "[data-name='modalDate']"
        // ).value = this.vendors[index].Order_Date__c;

        // this.template
        //   .querySelector("[data-name='modalDate']")
        //   .setAttribute("data-index", index);

        // const emailClickedEvent = new CustomEvent("openemail", {
        //   detail: params
        // });

        // this.dispatchEvent(emailClickedEvent);

        //this.templates = templates;
      })
      .catch((error) => {
        console.log(error);
        console.log("template query error");
      });
  }

  @api queryTemplate(templateId) {
    let queryString = `select id,Body, HtmlValue, Subject from emailtemplate where id = '${templateId}'`;

    return query({ queryString: queryString });
  }

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

  @api compileEmail(params) {
    return compileEmailTemplate(params);
  }

  sendEmail() {
    let templateId = this.template.querySelector(
      "[data-name='selectedTemplate']"
    ).value;

    this.queryTemplate(templateId)
      .then((results) => {
        if (results.length > 0) {
          let template = results[0];

          let params = this.params;
          params.template = template;

          const emailClickedEvent = new CustomEvent("openemail", {
            detail: params
          });

          let vendors = JSON.parse(JSON.stringify(this.vendors));
          // console.log(this.index);
          // console.log(
          //   this.template.querySelector("[data-name='modalDate']").value
          // );
          vendors[
            this.selectedIndex
          ].Order_Date__c = this.template.querySelector(
            "[data-name='modalDate']"
          ).value;
          this.vendors = vendors;

          this.save();

          this.closeModal();
          this.dispatchEvent(emailClickedEvent);
        }
      })
      .catch((error) => {
        console.log(error);
        // console.log('que')
      });

    // console.log(selectedTemplate);
    // console.log(this.params);
    //
  }

  compileFieldPermissions() {
    let fields = [
      "Name",
      "Vendor_Type__c",
      "Account__c",
      "Contact__c",
      "Order_Date__c",
      "Completed_Date__c"
    ];
    compileFieldPermissions({
      sObjectName: "Deal_Contact__c",
      fields: fields
    }).then((results) => {
      console.log("field permission results");
      console.log(results);

      this.permissionsMap = results;
    });
  }

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
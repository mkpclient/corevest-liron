import { LightningElement, api, track } from "lwc";
import query from "@salesforce/apex/lightning_Util.query";
import upsert from "@salesforce/apex/lightning_Util.upsertRecords";
export default class DealDocumentTypeSelector extends LightningElement {
  @api recordId;
  @api sObjectName;
  @api mode;
  @api selectedDocuments;
  @api uploadType = "single";
  @api sobjectType = "Opportunity";
  @api propertyId;
  @api recordIds;

  @track documents;
  @track properties;
  @track documentName;
  @track folder;
  @track subfolder;
  @track doctype;
  @track folderStructures;

  @track fileName;
  recordType;

  @api
  validateAndReturn() {
    // let record = {
    //   Id: this.recordId,
    //   sobjectType: "Deal_Document__c",
    //   Type__c: this.folder,
    //   Section__c: this.subfolder,
    //   Property__c: this.propertyId,
    //   Document_Type__c: this.doctype
    // };

    let documents = this.documents; //JSON.parse(JSON.stringify(this.documents));
    let mode = this.mode;
    let records = [];
    documents.forEach(document => {
      if (mode === "bulk") {
        if (
          this.sobjectType === "Opportunity" ||
          (document.Property__c && document.Property__c !== "")
        ) {
          records.push({
            Id: document.Id,
            sobjectType: "Deal_Document__c",
            Type__c: this.folder,
            Section__c: this.subfolder,
            //Property__c: this.propertyId,
            Property__c: document.Property__c,
            Document_Type__c: this.doctype
          });
        }
      } else {
        if (document.Document_Type__c && document.Document_Type__c !== "") {
          // if(this.sobjectType == )
          let propertyId =
            this.sobjectType == "Opportunity" ? "" : this.propertyId;
          records.push({
            Id: document.Id,
            sobjectType: "Deal_Document__c",
            Type__c: document.Type__c,
            Section__c: document.Section__c,
            Property__c: propertyId,
            Document_Type__c: document.Document_Type__c
          });
        }
      }
    });

    let isValidated =
      mode === "bulk"
        ? this.isValidated() && records.length > 0
        : records.length > 0;
    return JSON.stringify({ validated: isValidated, record: records });
  }

  @api
  isValidated() {
    return this.doctype && this.doctype !== "";
  }

  @api
  updateDocuments(recordIds) {
    let records = [];
    recordIds.forEach(id => {
      records.push({
        Id: id,
        sobjectType: "Deal_Document__c",
        Type__c: this.folder,
        Section__c: this.subfolder,
        Property__c: this.propertyId,
        Document_Type__c: this.doctype
      });
    });

    return upsert({ records: records });
  }

  get showSingle() {
    return this.mode === "single";
  }

  get showBulk() {
    return this.mode === "bulk";
  }

  get showBulkOpportunity() {
    return this.mode === "bulk" && this.sobjectType === "Opportunity";
  }

  get showBulkProperty() {
    return this.mode === "bulk" && this.sobjectType === "Property__c";
  }

  get showSingleOpportunity() {
    return this.mode === "single" && this.sobjectType === "Opportunity";
  }

  get showSingleProperty() {
    return this.mode === "single" && this.sobjectType === "Property__c";
  }

  connectedCallback() {
    let documents = [];
    this.queryDealDocument()
      .then(records => {
        let dealId = this.recordId;
        let recordType = "";
        // if (this.sObjectName === "Deal_Document__c") {
        //   let dealDocument = records[0];
        //   recordType = dealDocument.Deal__r.RecordType.DeveloperName;
        //   dealId = dealDocument.Deal__c;
        //   this.folder = dealDocument.Type__c;
        //   this.subfolder = dealDocument.Section__c;
        //   this.doctype = dealDocument.Document_Type__c;
        //   this.propertyId = dealDocument.Property__c;
        //   this.fileName = dealDocument.File_Name__c;
        // } else {
        //   let deal = records[0];
        //   recordType = deal.RecordType.DeveloperName;
        // }
        console.log(records);
        recordType = records[0].Deal__r.RecordType.DeveloperName;

        if (recordType.includes("LOC_Loan")) {
          recordType = "LOC_Loan";
        } else if (recordType.includes("Investor_DSCR")) {
          recordType = "Term_Loan";
        } else if (recordType.includes("Single_Rental_Loan")) {
          recordType = "Term_Loan";
        } else if (recordType.includes("Single_Asset_Loan")) {
          recordType = "Term_Loan";
        } else if (recordType.includes("Acquired_Bridge_Loan")) {
          recordType = "LOC_Loan";
        } else if (recordType.includes("Single_Asset_Bridge_Loan")) {
          recordType = "LOC_Loan";
        }

        documents = [];
        records.forEach(record => {
          if (this.sobjectType == "Property__c" && !record.Property__c) {
            record.Section__c = "";
            record.Type__c = "";
            record.Document_Type__c = "";
          }

          if (this.sobjectType == "Opportunity" && record.Property__c) {
            record.Section__c = "";
            record.Type__c = "";
            record.Document_Type__c = "";
            record.Property__c = "";
          }

          documents.push({
            Id: record.Id,
            File_Name__c: record.File_Name__c,
            Property__c: record.Property__c,
            Section__c: record.Section__c,
            Type__c: record.Type__c,
            Document_Type__c: record.Document_Type__c
          });
        });

        //this.documents = documents;

        this.queryProperties(dealId);
        return this.queryDocumentStructures(recordType, documents);
      })
      .then(docStructures => {
        console.log("--doc structures--");
        console.log(docStructures);

        let folderStructures = {};

        docStructures.forEach(structure => {
          let folders = structure.Folder_Structure_String__c.split(";");
          // let folders = folderString.split(';');
          let sObjectType = structure.sObject__c;

          if (!folderStructures.hasOwnProperty(sObjectType)) {
            folderStructures[sObjectType] = {};
          }

          if (!folderStructures[sObjectType].hasOwnProperty(folders[0])) {
            folderStructures[sObjectType][folders[0]] = { docs: [] };
          }

          if (folders.length === 1) {
            folderStructures[sObjectType][folders[0]].docs.push(
              structure.Document_Type__c
            );
          } else {
            if (
              !folderStructures[sObjectType][folders[0]].hasOwnProperty(
                folders[1]
              )
            ) {
              folderStructures[sObjectType][folders[0]][folders[1]] = {
                docs: []
              };
            }
            folderStructures[sObjectType][folders[0]][folders[1]].docs.push(
              structure.Document_Type__c
            );
          }
        });
        //console.log(folderStructures);
        this.folderStructures = folderStructures;

        this.documents = documents;
      })
      .catch(error => {
        console.log("error");
        console.log(error);
      });
  }

  handleChangeRow(event) {
    console.log(event);
    console.log(event.target.value);
    console.log(event.target.name);

    let value = event.target.value;
    let field = event.target.name;

    let index = event.target.getAttribute("data-index");

    let documents = JSON.parse(JSON.stringify(this.documents));

    documents[index][field] = value;

    this.documents = documents;
  }

  handleChange(event) {
    console.log(event);
    console.log(event.target.value);
    console.log(event.target.name);

    let value = event.target.value;
    let field = event.target.name;

    if (field === "folder") {
      this.folder = value;
      this.subfolder = "";
      this.doctype = "";
    } else if (field === "propertyId") {
      this.propertyId = value;
      this.folder = "";
      this.subfolder = "";
      this.doctype = "";
    } else if (field === "subfolder") {
      this.subfolder = value;
      this.doctype = "";
    } else if (field === "doctype") {
      this.doctype = value;
    }

    this[event.target.name] = event.target.value;
  }

  compileFolders() {
    let folders = [];
    let folderStructure = this.folderStructures.Opportunity;
    if (this.sobjectType == "Property__c") {
      folderStructure = this.folderStructures.Property__c;
    }

    for (let key in folderStructure) {
      if (folderStructure.hasOwnProperty(key)) {
        folders.push({
          label: key,
          value: key
        });
      }
    }

    return folders;
  }

  get folderDisabled() {
    return this.compileFolders().length === 0;
  }

  get folders() {
    return this.compileFolders();
  }

  compileSubFolders(folder) {
    let subfolders = [];

    folder = folder && folder !== "" ? folder : this.folder;
    if (folder && folder !== "") {
      let folderStructure = this.folderStructures.Opportunity;
      if (this.sobjectType == "Property__c") {
        folderStructure = this.folderStructures.Property__c;
      }

      let subFolders = folderStructure[folder];

      for (let key in subFolders) {
        if (subFolders.hasOwnProperty(key) && key !== "docs") {
          subfolders.push({
            label: key,
            value: key
          });
        }
      }
    }

    return subfolders;
  }

  get subfolderDisabled() {
    return this.compileSubFolders().length === 0;
  }

  get subFolders() {
    return this.compileSubFolders();
  }

  compileDocumentTypes(folder, subfolder) {
    let docTypes = [];
    folder = folder && folder !== "" ? folder : this.folder;
    if (folder && folder !== "") {
      let folderStructure = this.folderStructures.Opportunity;
      if (this.sobjectType == "Property__c") {
        folderStructure = this.folderStructures.Property__c;
      }

      let subFolders = folderStructure[folder];
      if (subFolders && subFolders.docs.length > 0) {
        subFolders.docs.forEach(docType => {
          docTypes.push({ label: docType, value: docType });
        });
      } else {
        subfolder = subfolder && subfolder !== "" ? subfolder : this.subfolder;
        if (
          subfolder &&
          subfolder !== "" &&
          subFolders &&
          subFolders[subfolder]
        ) {
          subFolders[subfolder].docs.forEach(docType => {
            docTypes.push({ label: docType, value: docType });
          });
        }
      }
    }

    return docTypes;
  }

  get documentsList() {
    let documents = JSON.parse(JSON.stringify(this.documents));

    documents.forEach(document => {
      document.folders = this.compileFolders();
      document.subfolders = this.compileSubFolders(document.Type__c);
      document.doctypes = this.compileDocumentTypes(
        document.Type__c,
        document.Section__c
      );
      document.foldersDisabled = document.folders.length === 0;
      document.subfoldersDisabled = document.subfolders.length === 0;
      document.doctypesDisabled = document.doctypes.length === 0;
    });

    //console.log(documents);

    return documents;
  }

  get documentTypesDisabled() {
    return this.compileDocumentTypes() === 0;
  }

  get documentTypes() {
    return this.compileDocumentTypes();
  }

  compilePropertyList() {
    let properties = [{ label: "No Property", value: "" }];
    this.properties.forEach(property => {
      properties.push({
        label: property.Name,
        value: property.Id
      });
    });

    return properties;
  }

  get propertyListDisabled() {
    return this.compilePropertyList.length === 1;
  }

  get propertyList() {
    return this.compilePropertyList();
  }

  queryDealDocument() {
    let queryString = ``;

    console.log(this.recordIds);

    queryString +=
      "SELECT Id, File_Name__c, Document_Type__c, Section__c, Type__c, Property__c,  Deal__r.RecordType.DeveloperName FROM Deal_Document__c";
    queryString += " WHERE ID IN (";

    this.recordIds.forEach(recordId => {
      queryString += `'${recordId}', `;
    });

    queryString = queryString.substring(0, queryString.lastIndexOf(",")) + ")";

    // if (this.sObjectName === "Opportunity") {
    //   queryString = `SELECT Id, RecordType.DeveloperName FROM Opportunity`;
    // } else {
    //   queryString = `SELECT Id, File_Name__c, Document_Type__c, Section__c, Type__c, Property__c,  Deal__r.RecordType.DeveloperName FROM Deal_Document__c`;
    // }

    // queryString += ` WHERE Id = '${this.recordId}'`;

    return query({ queryString: queryString });
  }

  queryDocumentStructures(recordType) {
    let queryString = `SELECT Id, Folder_Structure_String__c, Document_Type__c, sObject__c, Sort__c FROM`;
    queryString += ` Document_Structure__mdt WHERE RecordType__c = '${recordType}'`;
    queryString += ` Order BY Sort__c ASC`;

    return query({ queryString: queryString });
  }

  queryProperties(dealId) {
    let queryString = `SELECT Id, Name FROM Property__c WHERE Deal__c = '${dealId}'`;

    query({ queryString: queryString })
      .then(properties => {
        this.properties = properties;
      })
      .catch(error => {
        console.log("property error");
        console.log(error);
      });
  }
}
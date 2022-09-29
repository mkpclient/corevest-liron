@RestResource(urlMapping='/portal/fundings/*')
global without sharing class PortalAPIFunding {
  static Id dealId;

  @HttpPost
  global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    List<String> params = Restcontext.request.requestURI.split('/');
    system.debug(params);
    dealId = params[3];

    if (params.size() > 4) {
      if (params[4] == 'new') {
        List<Property__c> properties = new List<Property__c>();
        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>();
        List<Funding> fundings = (List<Funding>) System.JSON.deserialize(
          req.requestBody.toString(),
          List<Funding>.class
        );
        for (Funding funding : fundings) {
          if (funding.settlementStatementId != null) {
            // contentVers
            // for (String contentVersionId : funding.settlementStatementIds) {
            contentVersionMap.put(funding.settlementStatementId, null);
            // }
          }
          if (funding.purchaseContractId != null) {
            // for (String contentVersionId : funding.purchaseContractIds) {
            contentVersionMap.put(funding.purchaseContractId, null);
            // }
          }
          properties.add(funding.createRecord());
        }

        insert properties;

        for (ContentVersion cv : [
          SELECT Id, Title, ContentDocumentId
          FROM ContentVersion
          WHERE Id IN :ContentVersionMap.keySet()
        ]) {
          contentVersionMap.put(cv.Id, cv);
        }

        List<Deal_Document__c> dealDocs = new List<Deal_Document__c>();
        for (Integer i = 0; i < properties.size(); i++) {
          if (String.isNotBlank(fundings[i].settlementStatementId)) {
            // for (String contentVersionId : fundings[i].settlementStatementIds) {
            ContentVersion cv = contentVersionMap.get(
              fundings[i].settlementStatementId
            );
            Deal_Document__c dealDoc = new Deal_Document__c();
            dealDoc.Document_Structure_Id__c = 'm000a0000004PmvAAE';
            dealDoc.File_Name__c = cv.Title;
            dealDoc.ContentVersion_Id__c = cv.Id;
            dealDoc.Attachment_Id__c = cv.ContentDocumentId;
            dealDoc.Deal__c = dealId;

            dealDoc.Document_Loaded__c = true;
            dealDoc.Property__c = properties[i].Id;
            dealDoc.Added_By__c = UserInfo.getUserId();
            dealDoc.Added_On__c = system.now();

            dealDocs.add(dealDoc);
            // }
          }
          if (String.isNotBlank(fundings[i].purchaseContractId)) {
            // for (String contentVersionId : fundings[i].purchaseContractIds) {
            ContentVersion cv = contentVersionMap.get(
              fundings[i].purchaseContractId
            );
            Deal_Document__c dealDoc = new Deal_Document__c();
            dealDoc.Document_Structure_Id__c = 'm000a0000004PmvAAE';
            dealDoc.File_Name__c = cv.Title;
            dealDoc.ContentVersion_Id__c = cv.Id;
            dealDoc.Attachment_Id__c = cv.ContentDocumentId;
            dealDoc.Deal__c = dealId;

            dealDoc.Document_Loaded__c = true;
            dealDoc.Property__c = properties[i].Id;
            dealDoc.Added_By__c = UserInfo.getUserId();
            dealDoc.Added_On__c = system.now();

            dealDocs.add(dealDoc);
            // }
          }
        }

        insert dealDocs;

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (Deal_Document__c dealDoc : dealDocs) {
          ContentDocumentLink cdl = new ContentDocumentLink();
          cdl.ContentDocumentId = dealDoc.Attachment_Id__c;
          cdl.LinkedEntityId = dealDoc.Id;
          cdl.ShareType = 'V';
          cdl.Visibility = 'AllUsers';

          links.add(cdl);
        }

        insert links;

        fundings = new List<Funding>();
        for (Property__c prop : properties) {
          fundings.add(new Funding(prop));
        }

        res.statusCode = 201;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(fundings, true));
      }
    }
  }

  class Funding {
    public Id id;
    String recordTypeName;
    String streetAddress;
    String city;
    String state;
    String zipCode;
    String propertyType;
    Decimal numberOfUnits;
    Decimal numberOfBedrooms;
    Decimal numberOfBathrooms;
    String squareFootage;
    String transactionType;
    Date requestedFundingDate;
    Decimal acquisitionPrice;
    Date purchaseDate;
    Decimal rehabBudget;
    Date contractCloseDate;
    String titleCompany;
    String titleContactName;
    String titleContactPhone;
    String titleContactEmail;
    String interiorContact;
    String interiorAccessPOCPhone;
    String interiorAccessPOCEmail;
    // Decimal renovationBudget;

    // String executedHUDDocId;
    // String purchaseContractDocId;

    public String settlementStatementId;
    public String purchaseContractId;

    public Funding(Property__c property) {
      this.id = property.Id;
      if (property.RecordTypeId == '0120a0000019jiAAAQ') {
        this.recordTypeName = 'Renovation';
      } else if (property.RecordTypeId == '0120a0000015H6TAAU') {
        this.recordTypeName = 'No Renovation';
      } else if (property.RecordTypeId == '0120a0000019kcQAAQ') {
        this.recordTypeName = 'Ground Up Construction';
      }
      // this.recordTypeName = property.;
      this.streetAddress = property.Name;
      this.city = property.City__c;
      this.state = property.State__c;
      this.zipCode = property.ZipCode__c;
      this.propertyType = property.Property_Type__c;
      this.numberOfUnits = property.Number_of_Units__c;
      this.numberOfBedrooms = property.Number_of_Beds__c;
      this.numberOfBathrooms = property.Number_of_Bath__c;
      this.squareFootage = property.Square_Feet__c;
      this.transactionType = property.Refinance_Acquisition__c;
      this.requestedFundingDate = property.Requested_Funding_Date__c;
      this.acquisitionPrice = property.Acquisition_Price__c;
      this.purchaseDate = property.Acquisition_Date__c;
      this.rehabBudget = property.Rehab_Budget__c;
      this.contractCloseDate = property.Contract_Close_Date__c;
      this.titleCompany = property.Title_Company_text__c;
      this.titleContactName = property.Title_Contact_Name__c;
      this.titleContactPhone = property.Title_Contact_Phone__c;
      this.titleContactEmail = property.Title_Contact_Email_Address__c;
      this.interiorContact = property.Interior_Access_POC__c;
      this.interiorAccessPOCPhone = property.Interior_Access_POC_Phone__c;
      this.interiorAccessPOCEmail = property.Interior_Access_POC_Email__c;
      // this.renovationBudget = property.Rehab_Budget__c;
    }

    public Property__c createRecord() {
      Property__c property = new Property__c();
      property.Deal__c = dealId;
      property.Name = this.streetAddress;
      property.City__c = this.city;
      property.State__c = this.state;
      if (this.recordTypeName == 'Renovation') {
        property.RecordTypeId = '0120a0000019jiAAAQ';
      } else if (this.recordTypeName == 'No Renovation') {
        property.RecordTypeId = '0120a0000015H6TAAU';
      } else if (this.recordTypeName == 'Ground Up Construction') {
        property.RecordTypeId = '0120a0000019kcQAAQ';
      }
      property.ZipCode__c = this.zipCode;
      property.Property_Type__c = this.propertyType;
      property.Number_of_Units__c = this.numberOfUnits;
      property.Number_of_Beds__c = this.numberOfBedrooms;
      property.Number_of_Bath__c = this.numberOfBathrooms;
      property.Square_Feet__c = this.squareFootage;
      property.Refinance_Acquisition__c = this.transactionType;
      property.Requested_Funding_Date__c = this.requestedFundingDate;
      property.Acquisition_Price__c = this.acquisitionPrice;
      property.Acquisition_Date__c = this.purchaseDate;
      property.Rehab_Budget__c = this.rehabBudget;
      property.Contract_Close_Date__c = this.contractCloseDate;
      property.Title_Company_text__c = this.titleCompany;
      property.Title_Contact_Name__c = this.titleContactName;
      property.Title_Contact_Phone__c = this.titleContactPhone;
      property.Title_Contact_Email_Address__c = this.titleContactEmail;
      property.Interior_Access_POC__c = this.interiorContact;
      property.Interior_Access_POC_Phone__c = this.interiorAccessPOCPhone;
      property.Interior_Access_POC_Email__c = this.interiorAccessPOCEmail;
      return property;
    }
  }
}
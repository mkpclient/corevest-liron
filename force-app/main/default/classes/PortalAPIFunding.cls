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
        for (
          Funding funding : (List<Funding>) System.JSON.deserialize(
            req.requestBody.toString(),
            List<Funding>.class
          )
        ) {
          properties.add(funding.createRecord());
        }

        insert properties;

        List<Funding> fundings = new List<Funding>();
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

    String executedHUDDocId;
    String purchaseContractDocId;

    public Funding(Property__c property) {
      this.id = property.Id;
      if (property.RecordTypeId == '0120a0000019jiAAAQ') {
        this.recordTypeName = 'Renovation';
      } else if (property.RecordTypeId == '0120a0000015H6TAAU') {
        this.recordTypeName = 'No Renovation';
      } else if (property.RecordTypeId == '0120a0000015H6TAAU') {
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
        property.RecordTypeId = '0120a0000015H6TAAU';
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
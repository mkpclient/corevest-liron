@RestResource(urlMapping='/portal/extension/*')
global without sharing class PortalAPIPropertyExtension {
  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    if (params[3] == 'propertyId' || params[3] == 'dealId') {
      List<PropertyExtension> extensions = new List<PropertyExtension>();
      for (Property_Extension__c extension : queryExtensions(params[4])) {
        extensions.add(new PropertyExtension(extension));
      }
      res.responseBody = Blob.valueOf(JSON.serialize(extensions, true));
    } else {
      Id extensionId = params[3];
      Property_Extension__c extension = queryExtension(extensionId);
      if (extension != null) {
        PropertyExtension propertyExtension = new PropertyExtension(extension);
        res.responseBody = Blob.valueOf(
          JSON.serialize(propertyExtension, true)
        );
      }
    }

    res.addHeader('Content-Type', 'application/json');
  }

  @HttpPost
  global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    system.debug(req.requestBody.toString());

    PropertyExtension extension = (PropertyExtension) JSON.deserialize(
      req.requestBody.toString(),
      PropertyExtension.class
    );

    List<Property_Extension__c> extensionRecords = extension.getRecords();
    insert extensionRecords;

    List<PropertyExtension> extensions = new List<PropertyExtension>();
    for (Property_Extension__c extensionRecord : extensionRecords) {
      extensions.add(new PropertyExtension(extensionRecord));
    }

    res.addHeader('Content-Type', 'application/json');
    res.responseBody = Blob.valueOf(JSON.serialize(extensions, true));
    //system.debug(extensionRecords);
  }

  // @HttpPatch
  // global static void doPatch() {
  //   RestRequest req = RestContext.request;
  //   RestResponse res = RestContext.response;

  //   List<String> params = Restcontext.request.requestURI.split('/');

  //   Id extensionId = params[3];
  // }

  @HttpPatch
  global static void doPatch() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    Id extensionId = params[3];

    Property_Extension__c extension = queryExtension(extensionId);
    if (extension != null) {
      PropertyExtension propertyExtension = (PropertyExtension) System.JSON.deserialize(
        req.requestBody.toString(),
        PropertyExtension.class
      );

      propertyExtension.id = params[3];

      extension = propertyExtension.getRecord();
      Map<String, Object> fieldsToValue = extension.getPopulatedFieldsAsMap();
      extension = new Property_Extension__c();
      for (String fieldName : fieldsToValue.keySet()) {
        if (fieldsToValue.get(fieldName) != null) {
          extension.put(fieldName, fieldsToValue.get(fieldName));
        }
      }
      update extension;

      propertyExtension = (propertyExtension) JSON.deserialize(
        req.requestBody.toString(),
        PropertyExtension.class
      );

      propertyExtension.id = extension.Id;
      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(propertyExtension, true));
    } else {
      Map<String, String> respBody = new Map<String, String>();

      res.addHeader('Content-Type', 'application/json');
      respBody.put('status', 'error');
      respBody.put('message', 'Property Extension Id Not Found');
      res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
    }
  }

  @HttpDelete
  global static void doDelete() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    String extensionId = params[3];

    List<Property_Extension__c> extension = [
      SELECT Id
      FROM Property_Extension__c
      WHERE Id = :extensionId
    ];

    if (extension.size() > 0) {
      delete extension;

      Map<String, String> responseBody = new Map<String, String>();
      responseBody.put('status', 'success');
      responseBody.put('message', 'resource deleted');
      res.statusCode = 200;
      res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
      res.addHeader('Content-Type', 'application/json');
    } else {
      res.addHeader('Content-Type', 'application/json');
      Map<String, String> responseBody = new Map<String, String>();
      responseBody.put('status', 'error');
      responseBody.put('message', 'resource not found');
      res.statusCode = 404;
      res.responseBody = Blob.valueOf(JSON.serialize(responseBody, true));
    }
  }

  public static Property_Extension__c queryExtension(Id extensionId) {
    Set<String> fieldNames = util.getAllFieldNamesForObject(
      'Property_Extension__c'
    );

    String queryString = 'SELECT ';
    queryString += String.join(new List<String>(fieldNames), ',');
    queryString += ', Property__r.Full_Address__c';
    queryString += ' FROM Property_Extension__c';
    queryString += ' WHERE Id =: extensionId ';

    List<Property_Extension__c> extensions = (List<Property_Extension__c>) database.query(
      queryString
    );

    if (extensions.size() > 0) {
      return extensions[0];
    } else {
      return null;
    }
  }

  public static List<Property_Extension__c> queryExtensions(
    Id propertyOrDealId
  ) {
    Set<String> fieldNames = util.getAllFieldNamesForObject(
      'Property_Extension__c'
    );

    String queryString = 'SELECT ';
    queryString += String.join(new List<String>(fieldNames), ',');
    queryString += ', Property__r.Full_Address__c';
    queryString += ' FROM Property_Extension__c';
    queryString += ' WHERE Property__c =: propertyOrDealId OR Property__r.Deal__c =: propertyOrDealId';

    List<Property_Extension__c> extensions = (List<Property_Extension__c>) database.query(
      queryString
    );

    return extensions;
  }

  public class PropertyExtension {
    List<Id> propertyIds;
    Id id;
    Id propertyId;
    Date requestedDate;
    String loanNumber;
    String dealName;
    String borrowerName;
    String propertyAddress;
    String reason;
    String issuesPreventingPayoffResolved;
    String termPreferences;
    String currentCondition;
    Decimal midconstructionCompletionPercentage;
    String otherCondition;
    String remainingForCompletion;
    String howLongForCompletion;
    Decimal costForCompletion;
    String anticipatedMarketingTime;
    String exitStrategy;
    Decimal anticipatedListPrice;
    String isPropertyOccupied;
    String interiorContactPhone;
    String interiorContactEmail;
    String interiorContactName;

    String anticipatedListPriceFileId;
    String hazardInsurancePolicyFileId;
    String operatingStatementFileId;
    String propertyTaxesEvidenceFileId;
    String rentRollFileId;
    String rentalAgreementFileId;

    String borrowerId;

    PropertyExtension(Property_Extension__c extension) {
      this.id = extension.Id;
      this.propertyId = extension.Property__c;
      this.requestedDate = extension.Requested_Date__c;
      this.dealName = extension.Deal_Name__c;
      this.loanNumber = extension.Deal_Loan_Number__c;
      //this.borrowerName = extension.Property__r.Deal__r.Contact.Full_name__c;
      this.propertyAddress = extension.Property__r.Full_Address__c;
      this.reason = extension.Extension_Reason_2__c;
      this.issuesPreventingPayoffResolved = extension.Payoff_Issues_Resolved__c;
      this.termPreferences = extension.Extension_Term_Preference__c;
      this.currentCondition = extension.Current_Condition_of_Property__c;
      this.midconstructionCompletionPercentage = extension.Mid_Construction_Completion__c;
      this.otherCondition = extension.Other_Condition_of_Property__c;
      this.remainingForCompletion = extension.What_is_remaining_to_complete__c;
      this.howLongForCompletion = extension.How_long_will_improvements_take__c;
      this.costForCompletion = extension.Cost_for_Improvements__c;
      this.anticipatedMarketingTime = extension.Anticipated_marketing_time__c;
      this.exitStrategy = extension.Exit_Strategy__c;
      this.anticipatedListPrice = extension.Anticipated_List_price__c;
      this.isPropertyOccupied = extension.Property_Occupied__c;
      this.interiorCOntactPhone = extension.Interior_Contact_Phone__c;
      this.interiorContactEmail = extension.Interior_Contact_Email__c;
      this.interiorContactName = extension.Interior_Contact_Name__c;

      this.anticipatedListPriceFileId = extension.Anticipated_List_Price_File_Id__c;
      this.hazardInsurancePolicyFileId = extension.Hazard_Insurance_Policy_File_Id__c;
      this.operatingStatementFileId = extension.Operating_Statement_File_Id__c;
      this.propertyTaxesEvidenceFileId = extension.Property_Taxes_Evidence_File_Id__c;
      this.rentRollFileId = extension.Rent_Roll_File_Id__c;
      this.rentalAgreementFileId = extension.Rental_Agreement_File_Id__c;

      this.borrowerId = extension.Borrower_Portal_Id__c;
    }

    public Property_Extension__c getRecord() {
      Property_Extension__c extension = new Property_Extension__c();
      extension.Id = this.id;
      extension.Property__c = this.propertyId;
      extension.Requested_Date__c = this.requestedDate;
      //this.borrowerName  extension.Property__r.Deal__r.Contact.Full_name__c = ;
      extension.Extension_Reason_2__c = this.reason;
      extension.Payoff_Issues_Resolved__c = this.issuesPreventingPayoffResolved;
      extension.Extension_Term_Preference__c = this.termPreferences;
      extension.Current_Condition_of_Property__c = this.currentCondition;
      extension.Mid_Construction_Completion__c = this.midconstructionCompletionPercentage;
      extension.Other_Condition_of_Property__c = this.otherCondition;
      extension.What_is_remaining_to_complete__c = this.remainingForCompletion;
      extension.How_long_will_improvements_take__c = this.howLongForCompletion;
      extension.Cost_for_Improvements__c = this.costForCompletion;
      extension.Anticipated_marketing_time__c = this.anticipatedMarketingTime;
      extension.Exit_Strategy__c = this.exitStrategy;
      extension.Anticipated_List_price__c = this.anticipatedListPrice;
      extension.Property_Occupied__c = this.isPropertyOccupied;
      extension.Interior_Contact_Phone__c = this.interiorCOntactPhone;
      extension.Interior_Contact_Email__c = this.interiorContactEmail;
      extension.Interior_Contact_Name__c = this.interiorContactName;

      extension.Anticipated_List_Price_File_Id__c = this.anticipatedListPriceFileId;
      extension.Hazard_Insurance_Policy_File_Id__c = this.hazardInsurancePolicyFileId;
      extension.Operating_Statement_File_Id__c = this.operatingStatementFileId;
      extension.Property_Taxes_Evidence_File_Id__c = this.propertyTaxesEvidenceFileId;
      extension.Rent_Roll_File_Id__c = this.rentRollFileId;
      extension.Rental_Agreement_File_Id__c = this.rentalAgreementFileId;
      extension.Borrower_Portal_Id__c = this.borrowerId;
      return extension;
    }

    public List<Property_Extension__c> getRecords() {
      List<Property_Extension__c> extensions = new List<Property_Extension__c>();
      for (Id propertyId : this.propertyIds) {
        Property_Extension__c extension = new Property_Extension__c();
        extension.Id = this.id;
        extension.Property__c = propertyId;
        // extension.Requested_Date__c = this.requestedDate;
        if (this.requestedDate == null) {
          extension.Requested_Date__c = system.today();
        } else {
          extension.Requested_Date__c = this.requestedDate;
        }
        //this.borrowerName  extension.Property__r.Deal__r.Contact.Full_name__c = ;
        extension.Extension_Reason_2__c = this.reason;
        extension.Payoff_Issues_Resolved__c = this.issuesPreventingPayoffResolved;
        extension.Extension_Term_Preference__c = this.termPreferences;
        extension.Current_Condition_of_Property__c = this.currentCondition;
        extension.Mid_Construction_Completion__c = this.midconstructionCompletionPercentage;
        extension.Other_Condition_of_Property__c = this.otherCondition;
        extension.What_is_remaining_to_complete__c = this.remainingForCompletion;
        extension.How_long_will_improvements_take__c = this.howLongForCompletion;
        extension.Cost_for_Improvements__c = this.costForCompletion;
        extension.Anticipated_marketing_time__c = this.anticipatedMarketingTime;
        extension.Exit_Strategy__c = this.exitStrategy;
        extension.Anticipated_List_price__c = this.anticipatedListPrice;
        extension.Property_Occupied__c = this.isPropertyOccupied;
        extension.Interior_Contact_Phone__c = this.interiorCOntactPhone;
        extension.Interior_Contact_Email__c = this.interiorContactEmail;
        extension.Interior_Contact_Name__c = this.interiorContactName;

        extension.Anticipated_List_Price_File_Id__c = this.anticipatedListPriceFileId;
        extension.Hazard_Insurance_Policy_File_Id__c = this.hazardInsurancePolicyFileId;
        extension.Operating_Statement_File_Id__c = this.operatingStatementFileId;
        extension.Property_Taxes_Evidence_File_Id__c = this.propertyTaxesEvidenceFileId;
        extension.Rent_Roll_File_Id__c = this.rentRollFileId;
        extension.Rental_Agreement_File_Id__c = this.rentalAgreementFileId;
        extension.Borrower_Portal_Id__c = this.borrowerId;
        extensions.add(extension);
      }

      return extensions;
    }
  }
}
@RestResource(urlMapping='/portal/application/properties/*')
global with sharing class PortalAPIApplicationProperty {
  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');
    //system.debug(params);

    if (params[4] == 'applicationId') {
      Id applicationId = params[5];
      List<Application_Property__c> properties = [
        SELECT
          Id,
          Application__c,
          City__c,
          Name,
          State__c,
          Zipcode__c,
          Property_Type__c,
          Number_of_Units__c,
          Bedrooms__c,
          Bathrooms__c,
          Square_Footage__c,
          Year_Built__c,
          Air_Conditioning__c,
          Pool__c,
          Section_8__c,
          Acquisition_Price__c,
          Transaction_Costs__c,
          Rehab_Costs__c,
          Rehab_Completion_Date__c,
          Total_Basis__c,
          Borrower_Opinion_of_Current_Value__c,
          Currently_Leased__c,
          Lease_Ready__c,
          Lease_Start_Date__c,
          Lease_End_Date__c,
          Lease_Term__c,
          Monthly_Rent__c,
          Security_Deposit__c,
          HOA__c,
          Special_Assessments__c,
          Taxes__c,
          Insurance__c,
          Property_Management__c,
          MaintenanceRepairs__c,
          Owner_Paid_Utilities__c,
          Landscaping_Expense__c,
          Other_Expenses__c,
          Lease_UpMarketing__c,
          Vacancy_RepairsMaintenance__c,
          Credit_Loss__c,
          Total_Expenses__c,
          CapEx_Reserves__c,
          Other_Reserves__c,
          NOI__c
        FROM Application_Property__c
        WHERE Application__c = :applicationId
      ];

      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(properties, true));
      res.statusCode = 200;
    } else if (
      Schema.Application_Property__c.SobjectType ==
      Id.valueOf(params[4]).getSobjectType()
    ) {
      Id propertyId = params[4];
      Application_Property__c property = [
        SELECT
          Id,
          Application__c,
          City__c,
          Name,
          State__c,
          Zipcode__c,
          Property_Type__c,
          Number_of_Units__c,
          Bedrooms__c,
          Bathrooms__c,
          Square_Footage__c,
          Year_Built__c,
          Air_Conditioning__c,
          Pool__c,
          Section_8__c,
          Acquisition_Price__c,
          Transaction_Costs__c,
          Rehab_Costs__c,
          Rehab_Completion_Date__c,
          Total_Basis__c,
          Borrower_Opinion_of_Current_Value__c,
          Currently_Leased__c,
          Lease_Ready__c,
          Lease_Start_Date__c,
          Lease_End_Date__c,
          Lease_Term__c,
          Monthly_Rent__c,
          Security_Deposit__c,
          HOA__c,
          Special_Assessments__c,
          Taxes__c,
          Insurance__c,
          Property_Management__c,
          MaintenanceRepairs__c,
          Owner_Paid_Utilities__c,
          Landscaping_Expense__c,
          Other_Expenses__c,
          Lease_UpMarketing__c,
          Vacancy_RepairsMaintenance__c,
          Credit_Loss__c,
          Total_Expenses__c,
          CapEx_Reserves__c,
          Other_Reserves__c,
          NOI__c
        FROM Application_Property__c
        WHERE Id = :propertyId
        LIMIT 1
      ];

      res.responseBody = Blob.valueOf(JSON.serialize(property, true));
      res.statusCode = 200;
    } else {
      Map<String, String> body = new Map<String, String>();
      body.put('status', 'error');
      body.put('message', 'Malformed URI');
      res.statusCode = 400;
      res.responseBody = Blob.valueOf(JSON.serialize(body, true));
    }
  }

  @HttpPost
  global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    String jsonBody = req.requestBody.toString();
    system.debug(jsonBody);
    List<Application_Property__c> properties = (List<Application_Property__c>) System.JSON.deserialize(
      jsonBody,
      List<Application_Property__c>.class
    );

    Boolean missingId = false;
    List<String> rows = new List<String>();

    system.debug(properties);
    for (Integer i = 0; i < properties.size(); i++) {
      if (String.isBlank(properties[0].Application__c)) {
        missingId = true;
        // rows.add(String.valueOf(i));
        rows.add(String.valueOf(i + 1));
      }
    }

    if (missingId) {
      res.statusCode = 400;
      Map<String, String> body = new Map<String, String>();
      body.put('status', 'error');
      String errorMessage =
        'Missing Application Id values on rows: ' + String.join(rows, ', ');
      body.put('message', errorMessage);
      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(body, true));
    } else {
      upsert properties;
      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(properties, true));
    }

    // List<String, Object> propertyMap = new List<String.Object>();
    // for (Application_Property__c prop : properties) {
    // }
  }

  @HttpDelete
  global static void doDelete() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    if (
      Schema.Application_Property__c.SobjectType ==
      Id.valueOf(params[4]).getSobjectType()
    ) {
      Id propertyId = params[4];

      List<Application_Property__c> property = [
        SELECT Id
        FROM Application_Property__c
        WHERE Id = :propertyId
        LIMIT 1
      ];

      if (property.size() > 0) {
        delete property;
        res.addHeader('Content-Type', 'application/json');
        Map<String, String> body = new Map<String, String>();
        body.put('status', 'success');
        body.put('message', 'Property deleted.');
        res.responseBody = Blob.valueOf(JSON.serialize(body, true));
      } else {
        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 400;
        Map<String, String> body = new Map<String, String>();
        body.put('status', 'error');
        body.put('message', 'Property record was not found');
        res.responseBody = Blob.valueOf(JSON.serialize(body, true));
      }
    } else {
      res.addHeader('Content-Type', 'application/json');
      res.statusCode = 400;
      Map<String, String> body = new Map<String, String>();
      body.put('status', 'error');
      body.put('message', 'Malformed Request');
      res.responseBody = Blob.valueOf(JSON.serialize(body, true));
    }
  }
}
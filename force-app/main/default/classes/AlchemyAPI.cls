public without sharing class AlchemyAPI {
  static String BASE_URL;
  static String CREATE_USER_ENDPOINT = '/api/v1/auth/signup';
  static String TERMSHEET_NOTIF_ENDPOINT = '/api/v1/termSheetNotif';

  public static String getBaseURL() {
    if (BASE_URL == null) {
      Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1]
      .IsSandbox;
      Settings__mdt settings = Settings__mdt.getInstance('Universal_Settings');

      if (isSandbox) {
        BASE_URL = settings.Alchemy_Portal_Dev_URL__c;
      } else {
        BASE_URL = settings.Alchemy_Production_URL__c;
      }
    }
    return BASE_URL;
  }

  @AuraEnabled
  public static void createUser(Id recordId, String sObjectName) {
    Boolean validated = true;
    List<String> missingFields = new List<String>();
    if (sobjectName == 'Contact') {
      Contact c = [
        SELECT Id, FirstName, LastName, email
        FROM Contact
        WHERE Id = :recordId
        LIMIT 1
      ];

      // if(String.isBlank(l.FirstName) || String.isBlank(l.LastName) || String.isBlank(l.Email)){
      //   validated = false;
      // }
      if (String.isBlank(c.FirstName)) {
        validated = false;
        missingFields.add('First Name');
      }

      if (String.isBlank(c.LastName)) {
        validated = false;
        missingFields.add('Last Name');
      }

      if (String.isBlank(c.Email)) {
        validated = false;
        missingFields.add('Email');
      }

      if (validated) {
        createUserFromContact(recordId);
      }
    } else if (sobjectName == 'Lead') {
      Lead l = [
        SELECT Id, FirstName, LastName, email, Entry_Id__c
        FROM Lead
        WHERE Id = :recordId
        LIMIT 1
      ];

      if (String.isBlank(l.FirstName)) {
        validated = false;
        missingFields.add('First Name');
      }

      if (String.isBlank(l.LastName)) {
        validated = false;
        missingFields.add('Last Name');
      }

      if (String.isBlank(l.Email)) {
        validated = false;
        missingFields.add('Email');
      }

      if (validated) {
        createUserFromLead(recordId);
      }
    }

    if (!validated) {
      String errorMsg = 'Required fields are missing: ';
      errorMsg += String.join(missingFields, ', ');

      throw new AuraHandledException(errorMsg);
    }
  }

  @AuraEnabled
  public static void createUserFromLead(Id leadId) {
    Lead l = [
      SELECT Id, FirstName, LastName, email, Entry_Id__c
      FROM Lead
      WHERE Id = :leadId
    ];

    Map<String, String> requestBody = new Map<String, String>();

    // requestBody.put('name', l.firstname + ' ' + l.lastname);
    requestBody.put('firstName', l.firstName);
    requestBody.put('lastName', l.lastName);
    requestBody.put('email', l.Email);
    requestBody.put('lead_id', l.Id);
    requestBody.put('entry_id', l.Entry_Id__c);
    requestBody.put('role', 'user');
    //system.debug(requestBody);
    String url = getBaseURL() + create_user_endpoint;
    system.debug(url);
    HttpRequest req = new HttpRequest();
    req.setBody(JSON.serialize(requestBody, true));
    req.setEndpoint(url);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
    system.debug(req.getBody());
    system.debug(url);
    // req.setHeader('C')

    Integer statusCode = 200;
    String body = '{"userId": "test-123"}';

    if (!Test.isRunningTest()) {
      HttpResponse res = new Http().send(req);
      system.debug(res.getBody());
      system.debug(res.getStatus());
      system.debug(res.getStatusCode());
      body = res.getBody();
    }

    if (statusCode != 400 && statusCode != 422) {
      Map<String, String> bodyJSON = (Map<String, String>) JSON.deserialize(
        body,
        Map<String, String>.class
      );

      l.Alchemy_Portal_Id__c = bodyJSON.get('userId');

      update l;
      // system.debug(respParse.get('userId'));
    } else {
      Map<String, String> bodyJSON = (Map<String, String>) JSON.deserialize(
        body,
        Map<String, String>.class
      );

      throw new AuraHandledException(bodyJSON.get('msg'));
    }
  }

  @AuraEnabled
  public static void createUserFromContact(Id contactId) {
    Contact c = [
      SELECT
        Id,
        FirstName,
        LastName,
        email,
        Account.RecordType.DeveloperName,
        Non_Borrower_Account_Type__c,
        RecordType.DeveloperName
      FROM Contact
      WHERE Id = :contactId
    ];

    Map<String, String> requestBody = new Map<String, String>();

    String role = 'user';
    String nonBorrowerAccType = '';
    if (c.Account.RecordType.DeveloperName == 'Vendor') {
      role = 'vendor';
      nonBorrowerAccType = c.Non_Borrower_Account_Type__c;
    }
    if (c.RecordType.DeveloperName == 'Broker') {
      role = 'broker';
    }

    if (String.isNotBlank(nonBorrowerAccType)) {
      requestBody.put('nonBorrowerAccType', nonBorrowerAccType);
    }
    //requestBody.put('name', c.firstname + ' ' + c.lastname);
    requestBody.put('role', role);
    requestBody.put('firstName', c.firstName);
    requestBody.put('lastName', c.lastName);
    requestBody.put('email', c.Email);
    requestBody.put('lead_id', c.Id);
    system.debug(requestBody);
    String url = getBaseURL() + create_user_endpoint;

    HttpRequest req = new HttpRequest();
    req.setBody(JSON.serialize(requestBody));
    req.setEndpoint(url);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
    system.debug(req.getBody());
    system.debug(url);
    req.setTimeout(120000);
    // req.setHeader('C')

    Integer statusCode = 200;
    String body = '{"userId": "test-123"}';

    if (!Test.isRunningTest()) {
      HttpResponse res = new Http().send(req);
      system.debug(res.getBody());
      system.debug(res.getStatus());
      system.debug(res.getStatusCode());
      body = res.getBody();
    }

    if (statusCode != 400 && statusCode != 422) {
      Map<String, String> bodyJSON = (Map<String, String>) JSON.deserialize(
        body,
        Map<String, String>.class
      );

      c.Alchemy_Portal_Id__c = bodyJSON.get('userId');

      update c;
      // system.debug(respParse.get('userId'));
    } else {
      Map<String, String> bodyJSON = (Map<String, String>) JSON.deserialize(
        body,
        Map<String, String>.class
      );

      throw new AuraHandledException(bodyJSON.get('msg'));
    }
  }

  @future(callout=true)
  public static void sendTermSheet(Id dealId, Id dealDocId) {
    Opportunity deal = [
      SELECT
        Id,
        Application__c,
        Contact__r.Alchemy_Portal_Id__c,
        Application__r.Loan_Id__c,
        Application__r.Term_Sheet_Sent__c,
        Deal_Loan_Number__c,
        Name
      FROM Opportunity
      WHERE Id = :dealId
    ];
    Deal_Document__c dealDoc = [
      SELECT
        Id,
        Added_On__c,
        Added_By__r.Name,
        File_Name__c,
        ContentVersion_Id__c
      FROM Deal_Document__c
      WHERE Id = :dealDocId
      LIMIT 1
    ];

    // Application__c app

    // List<Deal_Document__c> dealDocs = [
    //   SELECT Id
    //   FROM Deal_Document__c
    //   WHERE Termsheet_Sent_To_Portal__c = TRUE AND Deal__c = :dealId
    // ];

    ContentVersion cv = [
      SELECT Id, VersionData
      FROM ContentVersion
      WHERE Id = :dealDoc.ContentVersion_Id__c
      LIMIT 1
    ];

    if (
      deal.Contact__r.Alchemy_Portal_Id__c != null &&
      deal.Application__c != null
    ) {
      Map<String, String> requestBody = new Map<String, String>();
      requestBody.put(
        'base64String',
        EncodingUtil.base64Encode(cv.VersionData)
      );
      requestBody.put('dealName', deal.Name);
      requestBody.put('fileName', dealDoc.File_Name__c);
      requestBody.put('dealLoanNum', deal.Deal_Loan_Number__c);
      system.debug(JSON.serialize(requestBody));
      HttpRequest req = new HttpRequest();

      req.setHeader('from', 'sf');
      req.setHeader(
        'x-auth',
        '8a85dd6f4ab293c9c7aaad0156487d5ae3aba26cbfbc5b9c3c1661212336565f'
      );

      String url = getBaseURL() + TERMSHEET_NOTIF_ENDPOINT;
      if (deal.Application__r.Term_Sheet_Sent__c) {
        req.setMethod('PATCH');
        url +=
          '/dealId/' +
          String.valueOf(dealId) +
          '/appId/' +
          deal.Application__c;
      } else {
        req.setMethod('POST');
        requestBody.put('dealId', String.valueOf(dealId));
        requestBody.put('sfApplicationId', deal.Application__c);
        requestBody.put('userId', deal.Contact__r.Alchemy_Portal_Id__c);
      }

      system.debug(url);

      req.setBody(JSON.serializePretty(requestBody));
      req.setEndpoint(url);

      req.setHeader('Content-Type', 'application/json');
      // req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
      // req.
      //system.debug(JSON.serializePretty((req.getBody().toString());
      // system.debug(JSON.seriali)
      Integer statusCode = 200;
      String body = '';
      if (!Test.isRunningTest()) {
        HttpResponse res = new Http().send(req);
        system.debug(res.getBody());
        system.debug(res.getStatus());
        system.debug(res.getStatusCode());
        body = res.getBody();
        statusCode = res.getStatusCode();
      }

      system.debug(statusCode);
      system.debug(body);

      if (statusCode == 200 || statusCode == 201) {
        dealDoc.Termsheet_Sent_To_Portal__c = true;
        dealDoc.Portal_Error_Message__c = '';
        update dealDoc;

        Application__c application = new APplication__c();
        application.Id = deal.Application__c;
        application.Term_Sheet_Sent__c = true;
        update application;
      } else {
        dealDoc.Portal_Error_Message__c = body;
        update dealDoc;
      }
    }

    // requestBody.put('base64String', l.firstname + ' ' + l.lastname);
    // requestBody.put('email', l.Email);
    // requestBody.put('lead_id', l.Id);
  }

  public static Set<Id> getDealIdsContactId(Id contactId) {
    Set<Id> oppIds = new Set<Id>();
    for (Deal_Contact__c c : [
      SELECT Id, Deal__c
      FROM Deal_Contact__c
      WHERE
        Contact__c = :contactId
        AND (Entity_Type__c = 'Portal Access'
        OR Entity_Type__c = 'Broker')
    ]) {
      oppIds.add(c.Deal__c);
    }

    return oppIds;
  }

  public static Set<Id> getDealIds(PortalAPIUser.PortalUser user) {
    Set<Id> oppIds = new Set<Id>();
    if (user != null && user.contactId != null && user.accountId != null) {
      for (Deal_Contact__c c : [
        SELECT Id, Deal__c
        FROM Deal_Contact__c
        WHERE
          (Contact__c = :user.contactId
          AND (Entity_Type__c = 'Portal Access'
          OR Entity_Type__c = 'Broker'))
          OR (Vendor_Type__c != NULL
          AND Account__c = :user.accountId)
          OR Deal__r.Contact__c = :user.contactId
      ]) {
        oppIds.add(c.Deal__c);
      }
    }

    return oppIds;
  }

  // public static Set<Id> getDealIdsVendorId(Id accountId) {
  //   Set<Id> oppIds = new Set<Id>();
  //   for (Deal_Contact__c c : [
  //     SELECT Id, Deal__c
  //     FROM Deal_Contact__c
  //     WHERE Account__c = :accountId
  //   ]) {
  //     oppIds.add(c.Deal__c);
  //   }

  //   return oppIds;
  // }

  public static Id getLeadIdByAlchemyId(String alchemyId) {
    Id leadId;
    List<lead> leads = [
      SELECT Id, Alchemy_Portal_Id__c
      FROM Lead
      WHERE Alchemy_Portal_Id__c = :alchemyId
    ];

    if (leads.size() > 0) {
      leadId = leads[0].Id;
    }

    return leadId;
  }

  public static Id getContactIdByAlchemyId(String alchemyId) {
    Id contactId;
    List<Contact> contacts = [
      SELECT Id, Alchemy_Portal_Id__c
      FROM Contact
      WHERE Alchemy_Portal_Id__c = :alchemyId
    ];

    if (contacts.size() > 0) {
      contactId = contacts[0].Id;
    }

    return contactId;
  }
}
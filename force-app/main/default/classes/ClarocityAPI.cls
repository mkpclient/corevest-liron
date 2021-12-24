public without sharing class ClarocityAPI {
  public static Clarocity_API_Settings__c apiSettings = Clarocity_API_Settings__c.getInstance();
  static String baseEndPoint = apiSettings.Endpoint__c;
  static String username = apiSettings.Term_Username__c;
  static String password = apiSettings.Term_Password__c;

  static String BRIDGE_USERNAME = apiSettings.Bridge_Username__c;
  static String BRIDGE_PASSWORD = apiSettings.Bridge_Password__c;

  private static String authToken;

  public static String getAuthToken() {
    return getAuthToken(null, null);
  }

  public static String getAuthToken(String uname, String pw) {
    if (String.isNotBlank(uname) && String.isNotBlank(pw)) {
      username = uname;
      password = pw;
    }

    String authToken = '';
    String authURI = '/login';
    String authEndpoint = baseEndpoint + authURI + '?';
    String respBody = '<?xml version="1.0" encoding="UTF-8"?><ValuationVision_data><User><code>200</code><key>XRL96EJ9YGQ6WA47S224</key><expire>86400</expire></User></ValuationVision_data>';

    Map<String, String> reqMap = new Map<String, String>();
    reqMap.put('email', username);
    reqMap.put('password', password);

    //String queryParameters = 'email=' + EncodingUtil.urlEncode(username, 'UTF-8') + '&password=' + EncodingUtil.urlEncode(password, 'UTF-8');
    String generatedBody = generateBody(reqMap, '----7MA4YWxkTrZu0gW');
    //system.debug(generatedBody);

    HttpRequest req = new HttpRequest();
    req.setHeader(
      'Content-Type',
      'multipart/form-data; boundary=----7MA4YWxkTrZu0gW'
    );
    req.setMethod('POST');
    req.setEndpoint(authEndpoint);

    req.setTimeout(120000);
    req.setBodyAsBlob(Blob.valueOf(generatedBody)); //(body);
    req.setHeader('Content-Length', String.ValueOf(req.getBodyAsBlob().size()));

    if (!Test.isRunningTest()) {
      HttpResponse resp = new Http().send(req);
      respBody = resp.getBody();
    }

    String statusCode = respBody.substringBetween('<code>', '</code>');

    if (statusCode != '200') {
      system.debug(respBody);
      throw new AuraHandledException('bad stuff');
    }

    authToken = respBody.substringBetween('<key>', '</key>');

    system.debug(authToken);

    return authToken;
  }

  public static Appraisal__c submitOrder(
    Property__c property,
    String productOrdered,
    String comments,
    String username,
    String password
  ) {
    String submitURI = '/neworder';
    String submitEndpoint = baseEndpoint + submitURI;

    User u = [
      SELECT Id, Clarocity_Username__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];

    if (String.isBlank(authToken)) {
      authToken = getAuthToken(username, password);
    }

    Map<String, String> reqMap = new Map<String, String>();
    reqMap.put('email', username);
    reqMap.put('key', authToken);

    // String queryParameters = '?';
    // queryParameters += 'email=' + EncodingUtil.urlEncode(u.Clarocity_Username__c, 'UTF-8');
    // queryParameters += '&key=' + EncodingUtil.urlEncode(authToken, 'UTF-8');

    String orderType = '';

    // if(productOrdered == 'Interior Appraisal'){
    //     if(property.Property_Type__c == 'SFR' || property.Property_Type__c == 'Townhome'){
    //         orderType = '111';
    //     }else if(property.Property_Type__c == 'Condo'){
    //         orderType = '111';
    //     }else if(property.Property_Type__c == '2-4 Unit'){
    //         orderType = '111';
    //     }

    // }
    // else if(productOrdered == 'Exterior Appraisal'){
    //     if(property.Property_Type__c == 'SFR' || property.Property_Type__c == 'Townhome'){
    //         orderType = '111';
    //     }else if(property.Property_Type__c == 'Condo'){
    //         orderType = '111';
    //     }else if(property.Property_Type__c == '2-4 Unit'){
    //         orderType = '111';
    //     }
    // }else
    if (productOrdered == 'Market Value Pro Interior') {
      orderType = '67';
    } else if (productOrdered == 'Market Value Pro Exterior') {
      orderType = '66';
    } else if (productOrdered == 'Appraisal Update') {
      orderType = '111';
    }

    reqMap.put('ordertype', orderType);

    // queryParameters += '&ordertype=' + orderType;

    reqMap.put(
      'propertyaddress',
      property.Name +
      ' ' +
      property.City__c +
      ', ' +
      property.State__c
    );

    // queryParameters += '&propertyaddress' + EncodingUtil.urlEncode(property.Name + ' ' + property.CIty__c + ', ' + property.State__c, 'UTF-8');

    if (property.Number_of_Units__c != null) {
      // queryParameters += '&unitnumber=' + String.valueOf(property.Number_of_Units__c);
      reqMap.put('unitnumber', String.valueOf(property.Number_of_Units__c));
    }

    reqMap.put('ignore_duplicates', '1');
    reqMap.put('propertyzipcode', property.ZipCode__c);
    reqMap.put('valuepurpose', '10');
    reqMap.put(
      'vendor_instructions',
      'Property Type: ' + property.Property_Type__c
    );
    reqMap.put('loanreference', property.Deal__r.Deal_Loan_Number__c);
    reqMap.put('borrowername', property.Deal__r.Borrower_Entity__r.Name);
    reqMap.put('borrower_phone', property.Deal__r.Contact__r.Phone);
    reqMap.put('comments', comments);
    // queryParameters += '&propertyzipcode=' + property.ZipCode__c;
    // queryParameters += '&valuepurpose=10';
    // queryParameters += '&vendor_instructions=' + EncodingUtil.urlEncode('Property Type: ' + property.Property_Type__c, 'UTF-8');
    // queryParameters += '&loanreference=' + property.Deal__r.Deal_Loan_Number__c;
    // queryParameters += '&borrowername=' + EncodingUtil.urlEncode(property.Deal__r.Borrower_Entity__r.Name, 'UTF-8');
    // queryParameters += '&borrower_phone=' + EncodingUtil.urlEncode(property.Deal__r.Contact__r.Phone, 'UTF-8');
    // queryParameters += '&comments=' + EncodingUtil.urlEncode(comments, 'UTF-8');
    // queryParameters += ''

    String generatedBody = generateBody(reqMap, '----7MA4YWxkTrZu0gW');
    system.debug(generatedBody);
    HttpRequest req;
    HttpResponse resp;

    try {
      req = new HttpRequest();
      req.setHeader(
        'Content-Type',
        'multipart/form-data; boundary=----7MA4YWxkTrZu0gW'
      );
      req.setMethod('POST');
      req.setEndpoint(submitEndpoint);

      req.setTimeout(120000);
      req.setBodyAsBlob(Blob.valueOf(generatedBody)); //(body);
      req.setHeader(
        'Content-Length',
        String.ValueOf(req.getBodyAsBlob().size())
      );

      String respBody = '<ValuationVision_data><Order><success>true</success><code>200</code><orderid>1234</orderid><message>Order Created</message></Order></ValuationVision_data>';

      if (!Test.isRunningTest()) {
        resp = new Http().send(req);
        respBody = resp.getBody();
      }

      system.debug(respBody);
      String statusCode = respBody.substringBetween('<code>', '</code>');

      system.debug(statusCode);
      if (statusCode != '200' && statusCode != '201') {
        String message = respBody.substringBetween('<message>', '</message>');

        if (message == 'This order is duplicated') {
          Appraisal__c appraisal = new Appraisal__c();

          //praisal.Appraisal_Firm_Transaction_ID__c = String.valueOf(respMap.get('appraisal_id'));
          // appraisal.Appraisal_Firm_Transaction_ID__c = ((String)respMap.get('appraisal_id')).replaceAll('ANS-', '');
          appraisal.Appraisal_Firm_Order_Id__c = respBody.substringBetween(
            '<orderid>',
            '</orderid>'
          );
          appraisal.Comments_to_Vendor__c = comments;
          appraisal.Order_Received_Date__c = system.now();
          appraisal.Status__c = 'Duplicate';

          if (!Test.isRunningTest()) {
            System.enqueueJob(
              new APILoggerQueueable(req, resp, property.Id, false)
            );
          }

          return appraisal;
        } else {
          CalloutException e = new CalloutException();
          e.setMessage(message);
          throw e;
        }
      }

      if (!Test.isRunningTest()) {
        System.enqueueJob(
          new APILoggerQueueable(req, resp, property.Id, false)
        );
      }

      Appraisal__c appraisal = new Appraisal__c();

      //praisal.Appraisal_Firm_Transaction_ID__c = String.valueOf(respMap.get('appraisal_id'));
      // appraisal.Appraisal_Firm_Transaction_ID__c = ((String)respMap.get('appraisal_id')).replaceAll('ANS-', '');
      appraisal.Appraisal_Firm_Transaction_ID__c = respBody.substringBetween(
        '<orderid>',
        '</orderid>'
      );
      appraisal.Appraisal_Firm_Order_Id__c = respBody.substringBetween(
        '<orderid>',
        '</orderid>'
      );
      appraisal.Comments_to_Vendor__c = comments;
      appraisal.Order_Received_Date__c = system.now();

      return appraisal;
    } catch (Exception e) {
      System.enqueueJob(new APILoggerQueueable(req, resp, property.Id, e));
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static Map<String, Object> checkOrder(
    String orderId,
    String recordType,
    Id appraisalId
  ) {
    String checkURI = '/orderstatus';

    String checkEndpoint = baseEndpoint + checkURI;
    User u = [
      SELECT Id, Clarocity_Username__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];

    String email = u.Clarocity_Username__c;

    if (recordType == 'LOC_Loan' || recordType == 'Single_Asset_Bridge_Loan') {
      email = BRIDGE_USERNAME;
    }

    if (String.isBlank(authToken)) {
      if (
        recordType == 'LOC_Loan' ||
        recordType == 'Single_Asset_Bridge_Loan'
      ) {
        authToken = getAuthToken(BRIDGE_USERNAME, BRIDGE_PASSWORD);
      } else {
        authToken = getAuthToken();
      }
    }

    Map<String, String> reqMap = new Map<String, String>();
    reqMap.put('email', email);
    reqMap.put('key', authToken);
    reqMap.put('orderid', orderId);

    system.debug(orderid);

    String generatedBody = generateBody(reqMap, '----7MA4YWxkTrZu0gW');
    HttpRequest req;
    HttpResponse resp;

    try {
      req = new HttpRequest();
      req.setHeader(
        'Content-Type',
        'multipart/form-data; boundary=----7MA4YWxkTrZu0gW'
      );
      req.setMethod('POST');
      req.setEndpoint(checkEndpoint);

      req.setTimeout(120000);
      req.setBodyAsBlob(Blob.valueOf(generatedBody)); //(body);
      req.setHeader(
        'Content-Length',
        String.ValueOf(req.getBodyAsBlob().size())
      );

      String respBody = '<ValuationVision_data><Order><code>200</code><status>2</status><description>Unassigned</description></Order></ValuationVision_data>';

      if (!Test.isRunningTest()) {
        resp = new Http().send(req);
        respBody = resp.getBody();
      }

      system.debug(checkEndpoint);

      system.debug(respBody);

      String statusCode = respBody.substringBetween('<code>', '</code>');

      if (statusCode != '200' && statusCode != '201') {
        CalloutException e = new CalloutException();
        e.setMessage(respBody.substringBetween('<message>', '</message>'));
        throw e;
      }

      Map<String, String> respMap = new Map<String, String>();
      respMap.put('status', respBody.substringBetween('<status>', '</status>'));
      respMap.put(
        'description',
        respBody.substringBetween('<description>', '</description>')
      );

      System.enqueueJob(new APILoggerQueueable(req, resp, appraisalId, false));

      return respMap;
    } catch (Exception e) {
      System.enqueueJob(new APILoggerQueueable(req, resp, appraisalId, e));
      throw new AuraHandledException(e.getMessage());
    }
  }

  @future(callout=true)
  public static void retrieveOrderFuture(
    String appraisalId,
    String recordType
  ) {
    Appraisal__c appraisal = [
      SELECT
        id,
        createddate,
        Deal__r.RecordType.DeveloperName,
        report_type__c,
        appraisal_firm_transaction_id__c,
        Property_Address__c,
        Property__r.Deal__c,
        appraisal_product_ordered__c,
        Property__c,
        Property__r.Deal_Record_Type__C
      FROM appraisal__c
      WHERE Id = :appraisalId
      ORDER BY createddate DESC
    ];
    String retrieveURI = '/orders';

    User u = [
      SELECT Id, Clarocity_Username__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];

    String email = u.Clarocity_Username__c;

    recordType = appraisal.Deal__r.RecordType.DeveloperName;

    if (recordType == 'LOC_Loan' || recordType == 'Single_Asset_Bridge_Loan') {
      email = BRIDGE_USERNAME;
    }

    if (String.isBlank(authToken)) {
      if (
        recordType == 'LOC_Loan' ||
        recordType == 'Single_Asset_Bridge_Loan'
      ) {
        authToken = getAuthToken(BRIDGE_USERNAME, BRIDGE_PASSWORD);
      } else {
        authToken = getAuthToken();
      }
    }

    // Map<String, String> reqMap = new Map<String, String>();
    // reqMap.put('email', email);
    // reqMap.put('key', authToken);
    // reqMap.put('orderid', appraisal.appraisal_firm_transaction_id__c);
    // String generatedBody = generateBody(reqMap, '----7MA4YWxkTrZu0gW');
    String retrieveEndpoint =
      baseEndpoint +
      retrieveURI +
      '?email=' +
      email +
      '&orderid=' +
      appraisal.appraisal_firm_transaction_id__c +
      '&key=' +
      authToken;

    HttpRequest req;
    HttpResponse resp;
    String respBody = '<ValuationVision_data><orderid>1304</orderid><ordertype>BPOLite</ordertype><order_status>Completed</order_status><XMLData><mime_type>text/xml</mime_type><data>VGhpcyB3aWxsIGJlIGFuIGVuY29kZWQgZmlsZS4=</data></XMLData><PDF><mime_type>application/pdf</mime_type><data>VGhpcyB3aWxsIGJlIGFuIGVuY29kZWQgZmlsZS4=</data></PDF> <code>200</code></ValuationVision_data>';

    try {
      req = new HttpRequest();
      req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      req.setMethod('GET');
      req.setEndpoint(retrieveEndpoint);

      req.setTimeout(120000);


      if (!Test.isRunningTest()) {
        resp = new Http().send(req);
        respBody = resp.getBody();
      }
      system.debug(JSON.serialize(respBody));

      String statusCode = respBody.substringBetween('<code>', '</code>');

      if (statusCode != '200' && statusCode != '201') {
        CalloutException e = new CalloutException();
        e.setMessage(respBody.substringBetween('<message>', '</message>'));
        throw e;
      }
      processRetrieveOrderCv(appraisalId, appraisal, respBody, new APILoggerQueueable(req, resp, appraisalId, false));
    } catch (Exception e) {
      System.enqueueJob(new APILoggerQueueable(req, resp, appraisalId, e));
      throw new AuraHandledException(e.getMessage());
    }

  }

  public static void processRetrieveOrderCv(String appraisalId, Appraisal__c appraisal, String respBody, APILoggerQueueable queueable) {

    List<ContentVersion> cvs = new List<ContentVersion>();
    String xmlFileId = '';
    String propertyAddress = appraisal.Property_Address__c;
    ContentVersion xmlCv = new ContentVersion();
    xmlCv.ContentLocation = 'S';

    if (Test.isRunningTest()) {
      StaticResource xml = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'AppraisalXMLTest'
        LIMIT 1
      ];
      xmlCv.VersionData = xml.Body;
    } else {
      xmlCv.VersionData = EncodingUtil.base64Decode(
        respBody.substringBetween(
          '<XMLData><mime_type>text/xml</mime_type><data>',
          '</data>'
        )
      );
    }

    xmlCv.Title = propertyAddress + '.xml';
    xmlCv.PathOnClient = propertyAddress + '.' + 'xml';
    cvs.add(xmlCv);

    ContentVersion pdfCv = new ContentVersion();
    pdfCv.ContentLocation = 'S';

    if (Test.isRunningTest()) {
      StaticResource xml = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'AppraisalXMLTest'
        LIMIT 1
      ];
      pdfCv.VersionData = xml.Body;
    } else {
      pdfCv.VersionData = EncodingUtil.base64Decode(
        respBody.substringBetween(
          '<PDF><mime_type>application/pdf</mime_type><data>',
          '</data>'
        )
      );
    }

    pdfCv.Title = propertyAddress + '.pdf';
    pdfCv.PathOnClient = propertyAddress + '.pdf';
    cvs.add(pdfCv);

    if (cvs.size() > 0) {
      insert cvs;

      List<String> docIds = new List<String>();
      for (ContentVersion cv : [
        SELECT Id, ContentDocumentId, FileExtension
        FROM ContentVersion
        WHERE Id IN :cvs
      ]) {
        ContentDocumentLink link = new ContentDocumentLink();
        link.ShareType = 'I';
        link.LinkedEntityId = appraisalId;
        link.ContentDocumentId = cv.ContentDocumentId;
        link.Visibility = 'AllUsers';

        insert link;

        if (cv.FileExtension == 'xml') {
          xmlFIleId = link.ContentDocumentId;
        }

        docIds.add(link.ContentDocumentId);
      }

      List<Deal_Document__c> dealDocs = BorrowerChecklistController.createDealDocs(
        appraisal.Property__r.Deal__c,
        docIds,
        'Diligence Documents;Property Level Documents|Valuations',
        appraisal.Property__c,
        appraisalId
      );
      List<Deal_Document__c> needAppraisals = new List<Deal_Document__c>();
      for (Deal_Document__c doc : dealDocs) {
        if (doc.Attachment_Id__c == xmlFileId) {
          needAppraisals.add(doc);
        }
      }

      system.enqueueJob(new AppraisalParser(needAppraisals, queueable));
    }
  }

  public static string generateBody(
    Map<String, String> reqMap,
    String boundary
  ) {
    String body = '';
    body += '--' + boundary + '\r\n';
    for (String key : reqMap.keySet()) {
      body += 'Content-Disposition: form-data; name="' + key + '"\r\n\r\n';
      body += reqMap.get(key) + '\r\n';
      body += '--' + boundary + '\r\n';
    }
    body = body.substringBeforeLast('\r\n');
    body += '--';
    return body;
  }
}
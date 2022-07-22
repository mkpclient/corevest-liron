public without sharing class AppraisalNationAPI {
  /*private static String baseEndPoint = 'https://appraisalnation.stage.appraisalscope.com/index.php/api/resapi';
    private static String username = 'appraisaldesk';
    private static String password = '1Analyst!';*/
  public static Appraisal_Nation_API__c apiSettings = Appraisal_Nation_API__c.getInstance();
  static String baseEndPoint = apiSettings.Endpoint__c;
  static String username = apiSettings.Username__c;
  static String password = apiSettings.password__c;

  private static String authToken;

  public static String getAuthToken() {
    return getAuthToken(null, null);
  }

  public static String getAuthToken(String uname, String pw) {
    if (String.isNotBlank(uname) && String.isNotBlank(pw)) {
      username = uname;
      password = pw;
    }

    system.debug(username);
    system.debug(password);

    String authToken = '';
    String authURI = '/dologin';
    String authEndpoint = baseEndpoint + authURI;
    String time_zone = '-08.00';

    HttpRequest req = new HttpRequest();
    req.setEndpoint(authEndpoint);
    req.setMethod('POST');

    Map<String, String> reqBody = new Map<String, String>();
    reqBody.put('time_zone', time_zone);
    reqBody.put('password', password);
    reqBody.put('username', username);

    req.setHeader(
      'Content-Type',
      'multipart/form-data; boundary=----7MA4YWxkTrZu0gW'
    );
    req.setHeader('Accept', 'application/json');
    // req.setHeader();

    String generatedBody = generateBody(reqBody, '----7MA4YWxkTrZu0gW');
    system.debug(generatedBody);

    req.setTimeout(120000);
    req.setBodyAsBlob(Blob.valueOf(generatedBody)); //(body);
    req.setHeader('Content-Length', String.ValueOf(req.getBodyAsBlob().size()));
    //req.setBody(JSON.serialize(reqBody));

    String body = '{"success":true,"api_key":"f6e8ba7aa3ed2b702fc213c80a657df422184cd1"}';

    if (!Test.isRunningTest()) {
      HttpResponse resp = new Http().send(req);

      // for(String key : resp.getHeaderKeys()){
      //     system.debug('key=>' + key);
      //     system.debug(resp.getHeader(key));
      //     system.debug('------');
      // }

      // if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201){
      body = resp.getBody();
      system.debug(body);
      // }else{
      //     system.debug(resp.getBody());
      //     system.debug(resp.getStatus());
      //     throw new AuraHandledException('HTTP Code: ' + resp.getStatusCode());

      // }
    }

    if (body.contains('<td')) {
      authToken = body.substringBetween('api_key=\'', '\'');
    } else {
      Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(
        body
      );
      if (!(Boolean) respMap.get('success')) {
        throw new AuraHandledException('Failed to authenticate');
      }
      authToken = (String) respMap.get('api_key');
    }

    system.debug(authToken);

    return authToken;
  }

  public static Appraisal__c submitOrder(
    Property__c property,
    String productOrdered,
    String comments,
    Boolean rushOrder,
    String dueDate,
    String uname,
    String pw
  ) {
    String submitURI = '/createappraisal';
    String submitEndpoint = baseEndpoint + submitURI;

    if (String.isBlank(authToken)) {
      // this.username = username;
      // this.password = password;
      authToken = getAuthToken(uname, pw);
    }

    HttpRequest req = new HttpRequest();
    req.setEndpoint(submitEndpoint);
    req.setMethod('POST');
    system.debug('--authToken--');
    system.debug(authToken);
    Map<String, String> reqBody = new Map<String, String>();
    reqBody.put('api_key', authToken);
    // reqBody.put(
    //   'due_date',
    //   dueDate == null ? String.valueOf(system.today().addDays(10)) : dueDate
    // );
    reqBody.put('due_date', dueDate == null ? null : dueDate);
    reqBody.put('address1', property.Name);
    reqBody.put('city', property.City__c);
    reqBody.put('state', property.State__c);
    reqBody.put('zip', property.ZipCode__c);
    reqBody.put('county', property.County__c);

    String property_type = '';
    if (
      property.Property_Type__c == 'SFR' ||
      property.Property_Type__c == 'Townhome'
    ) {
      property_type = 'Single Family';
    } else if (property.Property_Type__c == 'Condo') {
      property_type = 'Condominium';
    } else if (property.Property_Type__c == '2-4 Unit') {
      property_type = 'Duplex';
    } else if (property.Property_Type__c == 'Multifamily') {
      property_type = 'Multi Family';
    } else {
      property_type = 'Other';
    }

    //String loan_type = '7';

    String job_type = '';
    if (productOrdered == 'Interior Appraisal') {
      switch on property.Property_Type__c {
        when 'SFR' {
          job_type = '18986'; // Production job type code
          //job_type = '7934'; // Staging job type code
        }
        when 'Townhome' {
          job_type = '18986';
        }
        when 'Condo' {
          job_type = '18988'; // Production job type code
          //job_type = '18988'; // Staging job type code
        }
        when '2-4 Unit' {
          if (property.Number_of_Units__c == 2) {
            job_type = '18991';
          } else if (
            property.Number_of_Units__c == 3 ||
            property.Number_of_Units__c == 4
          ) {
            job_type = '18991';
          } else {
            job_type = '18991';
          }
        }
      }
    } else if (productOrdered == 'Exterior Appraisal') {
      switch on property.Property_Type__c {
        when 'SFR' {
          job_type = '18990';
        }
        when 'Townhome' {
          job_type = '18990';
        }
        when 'Condo' {
          job_type = '24724';
        }
        when '2-4 Unit' {
          if (property.Number_of_Units__c == 2) {
            job_type = '18991';
          } else if (
            property.Number_of_Units__c == 3 ||
            property.Number_of_Units__c == 4
          ) {
            job_type = '18991';
          } else {
            job_type = '18991';
          }
        }
      }
    } else if (productOrdered == 'Final Inspection') {
      switch on property.Property_Type__c {
        when 'SFR' {
          job_type = '18995';
        }
        when 'Townhome' {
          job_type = '18995';
        }
        when 'Condo' {
          job_type = '18995';
        }
        when '2-4 Unit' {
          if (property.Number_of_Units__c == 2) {
            job_type = '18995';
          } else if (
            property.Number_of_Units__c == 3 ||
            property.Number_of_Units__c == 4
          ) {
            job_type = '18995';
          } else {
            job_type = '18995';
          }
        }
      }
    } else if (productOrdered == 'Recert. of Value') {
      switch on property.Property_Type__c {
        when 'SFR' {
          job_type = '18996';
        }
        when 'Townhome' {
          job_type = '18996';
        }
        when 'Condo' {
          job_type = '18996';
        }
        when '2-4 Unit' {
          if (property.Number_of_Units__c == 2) {
            job_type = '18996';
          } else if (
            property.Number_of_Units__c == 3 ||
            property.Number_of_Units__c == 4
          ) {
            job_type = '18996';
          } else {
            job_type = '18996';
          }
        }
      }
    } else if (
      productOrdered == 'CDAIR Exterior Disaster Area Inspection Report'
    ) {
      switch on property.Property_Type__c {
        when 'SFR' {
          job_type = '18998';
        }
        when 'Townhome' {
          job_type = '18998';
        }
        when 'Condo' {
          job_type = '18998';
        }
        when '2-4 Unit' {
          if (property.Number_of_Units__c == 2) {
            job_type = '18998';
          } else if (
            property.Number_of_Units__c == 3 ||
            property.Number_of_Units__c == 4
          ) {
            job_type = '18998';
          } else {
            job_type = '18998';
          }
        }
      }
    } else if (
      productOrdered == 'CDAIR Interior Disaster Area Inspection Report'
    ) {
      switch on property.Property_Type__c {
        when 'SFR' {
          job_type = '18999';
        }
        when 'Townhome' {
          job_type = '18999';
        }
        when 'Condo' {
          job_type = '18999';
        }
        when '2-4 Unit' {
          if (property.Number_of_Units__c == 2) {
            job_type = '18999';
          } else if (
            property.Number_of_Units__c == 3 ||
            property.Number_of_Units__c == 4
          ) {
            job_type = '18999';
          } else {
            job_type = '18999';
          }
        }
      }
    } else if (productOrdered == 'CoreVal+') {
      switch on property.Property_Type__c {
        when 'SFR' {
          job_type = '22407';
        }
        when 'Townhome' {
          job_type = '22407';
        }
        when 'Condo' {
          job_type = '22407';
        }
        when '2-4 Unit' {
          if (property.Number_of_Units__c == 2) {
            job_type = '22407';
          } else if (
            property.Number_of_Units__c == 3 ||
            property.Number_of_Units__c == 4
          ) {
            job_type = '22407';
          } else {
            job_type = '22407';
          }
        }
      }
    }

    String loan_type = '7';
    String intended_use = '3';

    // if (
    //   property.Refinance_Acquisition__c == 'Acquisition' ||
    //   property.Refinance_Acquisition__c == 'Purchase'
    // ) {
    //   intended_use = '2';
    // } else if (property.Refinance_Acquisition__c == 'Refinance') {
    //   intended_use = '1';
    // }

    String client_displayed_id = '70040'; // For Production
    //String client_displayed_id = '69'; // For Staging

    if (
      property.Deal__r.RecordType.DeveloperName == 'LOC_Loan' ||
      property.Deal__r.RecordType.DeveloperName == 'Single_Asset_Bridge_Loan'
    ) {
      client_displayed_Id = '78054'; // For Production
      //client_displayed_Id = '69'; // For Staging
    }

    reqBody.put('client_displayed_id', client_displayed_id);
    reqBody.put('job_type', job_type);
    reqBody.put('property_type', property_type);
    reqBody.put('job_fee', '');
    reqBody.put('loan_type', loan_type);
    reqBody.put('intended_use', intended_use);
    reqBody.put('loan_officer', '1');
    reqBody.put('loan_number', property.Deal__r.Deal_Loan_Number__c);
    reqBody.put(
      'purchase_amount',
      String.valueOf(property.Acquisition_Price__c)
    );

    String occupancy = '';
    if (
      property.Currently_Leased__c == 'Y' ||
      property.Currently_Leased__c == 'y' ||
      property.Currently_Leased__c == 'Yes'
    ) {
      occupancy = 'Tenant';
    } else if (
      property.Currently_Leased__c == 'N' ||
      property.Currently_Leased__c == 'n' ||
      property.Currently_Leased__c == 'No'
    ) {
      occupancy = 'Vacant';
    }

    reqBody.put('occupancy', occupancy);
    reqBody.put('entity_name', property.Deal__r.Name);
    reqBody.put('borrower_fname', property.Deal__r.Contact__r.FirstName);
    // reqBody.put('borrower_fname', 'NA');
    reqBody.put('borrower_lname', property.Deal__r.Contact__r.LastName);
    // reqBody.put('borrower_lname', 'NA');
    // reqBody.put('borrower_home_number', property.Deal__r.Contact__r.Phone);
    // reqBody.put('borrower_work_number', property.Deal__r.Contact__r.HomePhone);
    // reqBody.put(
    //   'borrower_cell_number',
    //   property.Deal__r.Contact__r.MobilePhone
    // );
    // reqBody.put('borrower_email', property.Deal__r.Contact__r.Email);
    // reqBody.put(
    //   'borrower_intent_to_proceed_date',
    //   String.valueOf(system.today())
    // );
    // reqBody.put('borrower_address1', property.Deal__r.Contact__r.MailingStreet);
    // reqBody.put('borrower_city', property.Deal__r.Contact__r.MailingCity);
    // reqBody.put('borrower_state', property.Deal__r.Contact__r.MailingState);
    // reqBody.put('borrower_zip', property.Deal__r.Contact__r.MailingPostalCode);
    reqBody.put('other', property.Interior_Access_POC__c);
    if (property.Interior_Access_POC__c != null) {
      reqBody.put(
        'other_fname',
        property.Interior_Access_POC__c.substringBefore(' ')
      );
      reqBody.put(
        'other_lname',
        property.Interior_Access_POC__c.substringAfter(' ')
      );
    }
    reqBody.put('other_cell_number', property.Interior_Access_POC_Phone__c);
    reqBody.put('other_email', property.Interior_Access_POC_Email__c);
    reqBody.put('primary_contact', 'Other');
    reqBody.put('comments', comments);
    reqBody.put('appraisal_is_rush', rushOrder ? '1' : '0');
    reqBody.put('info_asset', property.Asset_ID__c);

    // String estimatedClosingDate = '';
    // if (property.Deal__r.RecordType.DeveloperName.contains('Term_Loan')) {
    //   estimatedClosingDate = String.valueOf(
    //     property.Deal__r.Anticipated_Closing_Date__c
    //   );
    // } else {
    //   estimatedClosingDate = '';
    // }
    // reqBody.put('estimated_closing_date', estimatedClosingDate);
    // reqBody.put('estimated_closing_date', String.ValueOf(property.Deal__r.Anticipated_Closing_Date__c));
    //reqBody.put('originator', 'CoreVest Finance')
    reqBody.put('submitting_party_name', 'CoreVest Finance');

    req.setHeader(
      'Content-Type',
      'multipart/form-data; boundary=----7MA4YWxkTrZu0gW'
    );
    String generatedBody = generateBody(reqBody, '----7MA4YWxkTrZu0gW');
    system.debug(generatedBody);

    req.setTimeout(120000);
    req.setBodyAsBlob(Blob.valueOf(generatedBody)); //(body);
    req.setHeader('Content-Length', String.ValueOf(req.getBodyAsBlob().size()));
    req.setHeader('Accept', 'application/json');

    String body = '{"success":true,"appraisal_id":7967,"sequence_number":"1", "file_number":"xyz293", "loan_number":"LN12345678"}';
    if (!Test.isRunningTest()) {
      HttpResponse resp = new Http().send(req);
      // if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201){
      body = resp.getBody();
      // }else{
      //     system.debug(resp.getBody());
      //     system.debug(resp.getStatus());
      //     throw new AuraHandledException('HTTP Code: ' + resp.getStatusCode());

      // }
    }

    Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(
      body
    );
    if (!(Boolean) respMap.get('success')) {
      system.debug((String) respMap.get('error_code'));
      system.debug((String) respMap.get('error_msg'));
      throw new AuraHandledException(
        'Error: ' +
        (String) respMap.get('error_code') +
        ' ' +
        (String) respMap.get('error_msg')
      );
    }
    Appraisal__c appraisal = new Appraisal__c();
    appraisal.Appraisal_Firm_Transaction_ID__c = String.valueOf(
      respMap.get('appraisal_id')
    );
    // appraisal.Appraisal_Firm_Transaction_ID__c = ((String)respMap.get('appraisal_id')).replaceAll('ANS-', '');
    appraisal.Appraisal_Firm_Order_Id__c = (String) respMap.get('file_number');
    appraisal.Comments_to_Vendor__c = comments;
    appraisal.Rush_Order__c = rushOrder;
    appraisal.Due_Date__c = String.isBlank(dueDate)
      ? system.today().addDays(10)
      : Date.valueOf(dueDate);
    appraisal.Order_Received_Date__c = system.now();
    system.debug(appraisal);

    return appraisal;
  }

  public static Map<String, Object> checkOrder(
    String orderId,
    String recordTypeName
  ) {
    String checkURI = '/getappraisalstatus';
    String checkEndpoint = baseEndpoint + checkURI;

    if (String.isBlank(authToken)) {
      if (recordTypeName.contains('LOC') || recordTypeName.contains('Bridge')) {
        authToken = getAuthToken(
          apiSettings.Bridge_Username__c,
          apiSettings.Bridge_Password__c
        );
      } else {
        authToken = getAuthToken();
      }
    }

    HttpRequest req = new HttpRequest();
    req.setEndpoint(checkEndpoint);
    req.setMethod('POST');

    Map<String, String> reqBody = new Map<String, String>();
    reqBody.put('api_key', authToken);
    reqBody.put('appraisal_id', orderId);

    req.setHeader(
      'Content-Type',
      'multipart/form-data; boundary=----7MA4YWxkTrZu0gW'
    );
    String generatedBody = generateBody(reqBody, '----7MA4YWxkTrZu0gW');
    system.debug(generatedBody);

    req.setTimeout(120000);
    req.setBodyAsBlob(Blob.valueOf(generatedBody)); //(body);
    req.setHeader('Content-Length', String.ValueOf(req.getBodyAsBlob().size()));
    req.setHeader('Accept', 'application/json');

    String body = '{"success":true,"appraisal_status":"On Hold"}';

    if (!Test.isRunningTest()) {
      HttpResponse resp = new Http().send(req);
      body = resp.getBody();
      //system.debug('--body--');

      if (resp.getStatus() == 'Unauthorized') {
        throw new AuraHandledException('Unauthorized');
      }
    }

    Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(
      body
    );
    if (!(Boolean) respMap.get('success')) {
      //system.debug((String) respMap.get('error_code'));
      //system.debug((String) respMap.get('error_msg'));
      throw new AuraHandledException(
        'Error: ' +
        (String) respMap.get('error_code') +
        ' ' +
        (String) respMap.get('error_msg')
      );
    }

    respMap.put('comments', getComments(orderId));

    return respMap;
  }

  public static Map<String, Object> getAppraisalDetail(
    String orderId,
    String recordTypeName
  ) {
    String checkURI = '/getappraisaldetail';
    String checkEndpoint = baseEndpoint + checkURI;

    if (String.isBlank(authToken)) {
      if (recordTypeName.contains('LOC') || recordTypeName.contains('Bridge')) {
        authToken = getAuthToken(
          apiSettings.Bridge_Username__c,
          apiSettings.Bridge_Password__c
        );
      } else {
        authToken = getAuthToken();
      }
    }

    HttpRequest req = new HttpRequest();
    req.setEndpoint(checkEndpoint);
    req.setMethod('POST');

    Map<String, String> reqBody = new Map<String, String>();
    reqBody.put('api_key', authToken);
    reqBody.put('appraisal_id', orderId);

    req.setHeader(
      'Content-Type',
      'multipart/form-data; boundary=----7MA4YWxkTrZu0gW'
    );
    String generatedBody = generateBody(reqBody, '----7MA4YWxkTrZu0gW');
    system.debug(generatedBody);

    req.setTimeout(120000);
    req.setBodyAsBlob(Blob.valueOf(generatedBody)); //(body);
    req.setHeader('Content-Length', String.ValueOf(req.getBodyAsBlob().size()));
    req.setHeader('Accept', 'application/json');

    String body = '{"success":true,"appraisal_status":"On Hold"}';

    if (!Test.isRunningTest()) {
      HttpResponse resp = new Http().send(req);
      body = resp.getBody();
      //system.debug('--body--');

      if (resp.getStatus() == 'Unauthorized') {
        throw new AuraHandledException('Unauthorized');
      }
    }

    Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(
      body
    );
    if (!(Boolean) respMap.get('success')) {
      //system.debug((String) respMap.get('error_code'));
      //system.debug((String) respMap.get('error_msg'));
      throw new AuraHandledException(
        'Error: ' +
        (String) respMap.get('error_code') +
        ' ' +
        (String) respMap.get('error_msg')
      );
    }

    return (Map<String, Object>) respMap.get('result');
  }



  public static List<Object> getComments(String appraisalId) {
    String checkURI = '/getcomments';
    String checkEndpoint = baseEndpoint + checkURI;

    if (String.isBlank(authToken)) {
      authToken = getAuthToken();
    }

    HttpRequest req = new HttpRequest();
    req.setEndpoint(checkEndpoint);
    req.setMethod('POST');

    Map<String, String> reqBody = new Map<String, String>();
    reqBody.put('api_key', authToken);
    reqBody.put('appraisal_id', appraisalId);

    req.setHeader(
      'Content-Type',
      'multipart/form-data; boundary=----7MA4YWxkTrZu0gW'
    );
    String generatedBody = generateBody(reqBody, '----7MA4YWxkTrZu0gW');
    system.debug(generatedBody);

    req.setTimeout(120000);
    req.setBodyAsBlob(Blob.valueOf(generatedBody)); //(body);
    req.setHeader('Content-Length', String.ValueOf(req.getBodyAsBlob().size()));
    req.setHeader('Accept', 'application/json');

    String body = '{"success":true,"result":[{"comment_id":"503","comment":"New order submitted (CoreVest Finance Integration)","comment_by":"Appraisal Desk(Manager)","comment_date":"2020-01-17 09:49:58"}]}';

    if (!Test.isRunningTest()) {
      HttpResponse resp = new Http().send(req);
      body = resp.getBody();
      system.debug('--body--');

      if (resp.getStatus() == 'Unauthorized') {
        throw new AuraHandledException('Unauthorized');
      }
    }

    Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(
      body
    );
    if (!(Boolean) respMap.get('success')) {
      system.debug((String) respMap.get('error_code'));
      system.debug((String) respMap.get('error_msg'));
      throw new AuraHandledException(
        'Error: ' +
        (String) respMap.get('error_code') +
        ' ' +
        (String) respMap.get('error_msg')
      );
    }

    return (List<Object>) respMap.get('result');
  }

  public static Map<String, String> retrieveOrder(
    String orderId,
    String appraisalId
  ) {
    //Map<String, String> retrieveResponse = new Map<String, String>();
    Appraisal__c appraisal = [
      SELECT
        id,
        createddate,
        report_type__c,
        appraisal_firm_transaction_id__c,
        Property_Address__c,
        Property__r.Deal__c,
        appraisal_product_ordered__c,
        Property__c,
        Property__r.Deal_Record_Type__C,
        Property__r.Deal__r.RecordType.DeveloperName
      FROM appraisal__c
      WHERE Id = :appraisalId
      ORDER BY createddate DESC
    ];

    String retrieveURI = '/retriveappraisaldocuments';
    String retrieveEndpoint = baseEndpoint + retrieveURI;
    String recordTypeName = appraisal.Property__r.Deal__r.RecordType.DeveloperName;
    if (String.isBlank(authToken)) {
      if (recordTypeName.contains('Bridge') || recordTypeName.contains('LOC')) {
        authToken = getAuthToken(
          apiSettings.Bridge_Username__c,
          apiSettings.Bridge_Password__c
        );
      } else {
        authToken = getAuthToken();
      }
    }

    HttpRequest req = new HttpRequest();
    req.setEndpoint(retrieveEndpoint);
    req.setMethod('POST');

    Map<String, String> reqBody = new Map<String, String>();
    reqBody.put('api_key', authToken);
    reqBody.put('appraisal_id', orderId);
    system.debug(retrieveEndpoint);
    req.setHeader(
      'Content-Type',
      'multipart/form-data; boundary=----7MA4YWxkTrZu0gW'
    );
    String generatedBody = generateBody(reqBody, '----7MA4YWxkTrZu0gW');
    system.debug(generatedBody);

    req.setTimeout(120000);
    req.setBodyAsBlob(Blob.valueOf(generatedBody)); //(body);
    req.setHeader('Content-Length', String.ValueOf(req.getBodyAsBlob().size()));
    req.setHeader('Accept', 'application/json');

    String body = '{"success":true,"result":[{"document_id":"56_XML","appraisal_id":"226","loan_no":"31569","file_no":"226","sequence_number":"2","document_url":"https:/ascope-docs.s3.amazonaws.com/appraisalnation_Test(226)-V1.xml","document_filename":"appraisalnation_Test(226)-V1.xml","document_description":null,"document_size":"2021459","has_xml":"1","xml_filename":"appraisalnation_Test(226)-V1.xml","create_date":"2020-01-23 10:25:42","is_addition_doc":"0","ucdp_order_id":null,"ucdp_orderstatus":null,"ucdp_document_id":null,"ucdp_fnm_filename":"","ucdp_frd_filename":"","document_type":"Appraisal Document"},{"document_id":"56","appraisal_id":"226","loan_no":"31569","file_no":"226","sequence_number":"2","document_url":"https://ascope-docs.s3.amazonaws.com//appraisalnation_Test(226)-V1.pdf","document_filename":"appraisalnation_Test(226)-V1.pdf","document_description":null,"document_size":"2021459","has_xml":"1","xml_filename":"appraisalnation_Test(226)-V1.xml","create_date":"2020-01-23 10:25:42","is_addition_doc":"0","ucdp_order_id":null,"ucdp_orderstatus":null,"ucdp_document_id":null,"ucdp_fnm_filename":"","ucdp_frd_filename":"","document_type":"Appraisal Document"}]}';

    if (!Test.isRunningTest()) {
      HttpResponse resp = new Http().send(req);
      body = resp.getBody();
      system.debug('--body--');

      if (resp.getStatus() == 'Unauthorized') {
        throw new AuraHandledException('Unauthorized');
      }
    }

    Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(
      body
    );
    if (!(Boolean) respMap.get('success')) {
      system.debug((String) respMap.get('error_code'));
      system.debug((String) respMap.get('error_msg'));

      Map<String, String> retrieveResp = new Map<String, String>();
      retrieveResp.put('status', 'error');
      retrieveResp.put('error_code', (String) respMap.get('error_code'));
      retrieveResp.put('error_msg', (String) respMap.get('error_msg'));

      return retrieveResp;
      // Map<String, String> retrieveResponse = new Map<String, String>();
      // retrieveResponse.put()
      // throw new AuraHandledException(
      //   'Error: ' +
      //   (String) respMap.get('error_code') +
      //   ' ' +
      //   (String) respMap.get('error_msg')
      // );
    }

    Map<String, String> file_urls = new Map<String, String>();
    List<ContentVersion> cvs = new List<ContentVersion>();
    String xmlFileId = '';
    List<String> documentURLs = new List<String>();

    for (Object f : (List<Object>) respMap.get('result')) {
      Map<String, Object> file = (Map<String, Object>) f;
      documentURLs.add((String) file.get('document_url'));
    }

    for (Object f : (List<Object>) respMap.get('result')) {
      Map<String, Object> file = (Map<String, Object>) f;

      String fileName = (String) file.get('document_filename');
      String documentURL = (String) file.get('document_url');
      system.debug(fileName);
      HttpRequest fileRequest = new HttpRequest();
      fileRequest.setMethod('GET');
      fileRequest.setEndpoint(documentURL);

      Blob blobbody = Blob.valueOf('adffa.txt');

      if (!Test.isRunningTest()) {
        HttpResponse resp;
        try {
          resp = new Http().send(fileRequest);
        } catch (Exception e) {
          AppraisalMergeController.sendRetrievalErrorEmail(
            appraisalId,
            documentURLs
          );

          Map<String, String> retrieveResp = new Map<String, String>();

          return retrieveResp;
        }

        blobbody = resp.getBodyAsBlob();
      } else {
        StaticResource xml = [
          SELECT Id, Body
          FROM StaticResource
          WHERE Name = 'AppraisalXMLTest'
          LIMIT 1
        ];
        blobbody = xml.body;
      }

      ContentVersion cv = new ContentVersion();
      cv.ContentLocation = 'S';
      cv.VersionData = blobbody; //resp.getBodyAsBlob();//EncodingUtil.base64Decode(results.get('file'));
      cv.Title = fileName;
      cv.PathOnClient = fileName;

      cvs.add(cv);

      //system.debug(resp.getBody());
      // if(fileName.contains('.pdf')){
      //     file_urls.put('pdf', (String)file.get('document_url'));
      // }else{
      //     file_urls.put('xml', (String)file.get('document_filename'));
      // }
    }

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

      system.enqueueJob(new AppraisalParser(needAppraisals));
    }

    return null;
  }

  // public static void getDocuments(String orderId){
  //     String documentEndpoint = '/retriveappraisaldocuments'
  // }

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
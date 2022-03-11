@RestResource(urlMapping='/portal/termsheet/*')
global with sharing class PortalAPITermsheet {
  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    if (params[3] != 'executed') {
      Id dealId = params[3];
      system.debug(dealId);
      Deal_Document__c dealDoc = [
        SELECT
          Id,
          Added_On__c,
          Added_By__r.Name,
          File_Name__c,
          ContentVersion_Id__c,
          Document_Type__c
        FROM Deal_Document__c
        WHERE Deal__c = :dealId AND Document_Type__c = 'Term Sheet'
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];

      ContentVersion cv = [
        SELECT Id, VersionData
        FROM ContentVersion
        WHERE Id = :dealDoc.ContentVersion_Id__c
        LIMIT 1
      ];

      Map<String, Object> body = new Map<String, Object>();
      body.put('fileName', dealDoc.File_Name__c);
      body.put('uploadedDate', dealDoc.Added_On__c);
      body.put('dealDocumentId', dealDoc.Id);
      body.put('uploadBy', dealDoc.Added_By__r.Name);
      body.put('base64', EncodingUtil.base64Encode(cv.VersionData));
      res.responseBody = Blob.valueOf(JSON.serialize(body));
      res.addHeader('Content-Type', 'application/json');
    } else {
      Id dealId = params[4];

      system.debug(dealId);
      Deal_Document__c dealDoc = [
        SELECT
          Id,
          Added_On__c,
          Added_By__r.Name,
          File_Name__c,
          ContentVersion_Id__c,
          Document_Type__c
        FROM Deal_Document__c
        WHERE Deal__c = :dealId AND Document_Type__c = 'Executed Term Sheet'
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];

      ContentVersion cv = [
        SELECT Id, VersionData
        FROM ContentVersion
        WHERE Id = :dealDoc.ContentVersion_Id__c
        LIMIT 1
      ];

      Map<String, Object> body = new Map<String, Object>();
      body.put('fileName', dealDoc.File_Name__c);
      body.put('uploadedDate', dealDoc.Added_On__c);
      body.put('dealDocumentId', dealDoc.Id);
      body.put('uploadBy', dealDoc.Added_By__r.Name);
      body.put('base64', EncodingUtil.base64Encode(cv.VersionData));
      res.responseBody = Blob.valueOf(JSON.serialize(body));
      res.addHeader('Content-Type', 'application/json');
    }
  }
  @HttpPost
  global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    String jsonBody = req.requestBody.toString();
    //system.debug(jsonBody);
    Map<String, Object> body = (Map<String, Object>) System.JSON.deserializeUntyped(
      jsonBody
    );

    Id dealId = (Id) body.get('dealId');
    String fileName = (String) body.get('fileName');

    List<Opportunity> opp = [
      SELECT Id, RecordType.DeveloperName
      FROM Opportunity
      WHERE Id = :dealId
    ];

    if (opp.size() > 0) {
      ContentVersion cv = new ContentVersion();
      cv.VersionData = EncodingUtil.base64Decode(
        (String) body.get('base64String')
      );
      cv.Title = fileName;
      cv.pathOnClient = fileName;
      insert cv;

      Id contentDocumentId = [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE Id = :cv.Id
      ]
      .ContentDocumentId;

      Deal_Document__c dealDoc = new Deal_Document__c();
      dealDoc.Attachment_Id__c = contentDocumentId;
      dealDoc.ContentVersion_Id__c = cv.Id;
      dealDoc.File_Name__c = fileName;
      dealDoc.Deal__c = opp[0].Id;
      dealDoc.Added_On__c = system.now();
      dealDoc.Added_By__c = UserInfo.getUserId();

      dealDoc.Document_Loaded__c = true;

      if (opp[0].RecordType.DeveloperName == 'LOC_Loan') {
        //dealDoc.Document_Type__c = 'Executed Term Sheet';
        //dealDoc.
        dealDoc.Document_Structure_Id__c = 'm000a000000c2N4';
      } else if (opp[0].RecordType.DeveloperName == 'Term_Loan') {
        dealDoc.Document_Structure_Id__c = 'm000a000000c2OY';
      } else if (opp[0].RecordType.DeveloperName == 'm000a000000c2b9') {
        dealDoc.Document_Structure_Id__c = 'm000a000000c2b9';
      }
      dealDoc.Document_Type__c = 'Executed Termsheet';
      dealDoc.Type__c = 'Executed Termsheet';
      dealDoc.Section__c = 'Executed Termsheet';
      system.debug(body.get('executiveSignedDate'));
      if (body.containsKey('executiveSignedDate')) {
        String s = (String) body.get('executiveSignedDate');

        s = s.replace(' ', 'T');
        s = s.substringBefore('.');
        s = '"' + s + 'Z"';
        dealDoc.Executive_Approval_Date__c = (Datetime) JSON.deserialize(
          s,
          Datetime.class
        );
      }
      system.debug(body.get('borrowerSignedDate'));

      if (body.containsKey('borrowerSignedDate')) {
        // Opportunity deal = new Opportunity(Id = dealId);
        String s = (String) body.get('borrowerSignedDate');
        // deal.Term_Sheet_Signed__c = Date.valueOf(s);
        // update deal;
        s = s.replace(' ', 'T');
        s = s.substringBefore('.');
        s = '"' + s + 'Z"';
        dealDOc.Borrower_Term_Sheet_Signature_Date__c = (Datetime) JSON.deserialize(
          s,
          Datetime.class
        );
      }

      insert dealDoc;

      insert new ContentDocumentLink(
        LinkedEntityId = dealDoc.Id,
        ContentDocumentId = contentDocumentId,
        ShareType = 'I',
        Visibility = 'AllUsers'
      );

      Map<String, String> respBody = new Map<String, String>();
      res.addHeader('Content-Type', 'application/json');
      respBody.put('status', 'success');
      respBody.put('message', 'Executed Term Sheet created');
      res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
    } else {
      Map<String, String> respBody = new Map<String, String>();
      res.addHeader('Content-Type', 'application/json');
      respBody.put('status', 'error');
      respBody.put('message', 'Deal Id Not Found');
      res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
    }
  }
  @HttpPatch
  global static void doPatch() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    String jsonBody = req.requestBody.toString();
    //system.debug(jsonBody);
    Map<String, Object> body = (Map<String, Object>) System.JSON.deserializeUntyped(
      jsonBody
    );

    Id dealId = (Id) body.get('dealId');
    String fileName = (String) body.get('fileName');

    List<Opportunity> opp = [
      SELECT Id, RecordType.DeveloperName
      FROM Opportunity
      WHERE Id = :dealId
    ];

    if (opp.size() > 0) {
      ContentVersion cv = new ContentVersion();
      cv.VersionData = EncodingUtil.base64Decode(
        (String) body.get('base64String')
      );
      cv.Title = fileName;
      cv.pathOnClient = fileName;
      insert cv;

      Id contentDocumentId = [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE Id = :cv.Id
      ]
      .ContentDocumentId;

      Deal_Document__c dealDoc = new Deal_Document__c();
      dealDoc.Attachment_Id__c = contentDocumentId;
      dealDoc.ContentVersion_Id__c = cv.Id;
      dealDoc.Deal__c = opp[0].Id;
      if (opp[0].RecordType.DeveloperName == 'LOC_Loan') {
        //dealDoc.Document_Type__c = 'Executed Term Sheet';
        //dealDoc.
        dealDoc.Document_Structure_Id__c = 'm000a000000c2N4';
      } else if (opp[0].RecordType.DeveloperName == 'Term_Loan') {
        dealDoc.Document_Structure_Id__c = 'm000a000000c2OY';
      } else if (opp[0].RecordType.DeveloperName == 'm000a000000c2b9') {
        dealDoc.Document_Structure_Id__c = 'm000a000000c2b9';
      }

      insert dealDoc;

      insert new ContentDocumentLink(
        LinkedEntityId = dealDoc.Id,
        ContentDocumentId = contentDocumentId,
        ShareType = 'I',
        Visibility = 'AllUsers'
      );

      Map<String, String> respBody = new Map<String, String>();
      res.addHeader('Content-Type', 'application/json');
      respBody.put('status', 'success');
      respBody.put('message', 'Executed Term Sheet created');
      res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
    } else {
      Map<String, String> respBody = new Map<String, String>();
      res.addHeader('Content-Type', 'application/json');
      respBody.put('status', 'error');
      respBody.put('message', 'Deal Id Not Found');
      res.responseBody = Blob.valueOf(JSON.serialize(respBody, true));
    }
  }
}
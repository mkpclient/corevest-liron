@RestResource(urlMapping='/servicelink/*')
global without sharing class ServiceLinkEndpoint {
  public class ServiceLinkException extends Exception {
  }

  @HttpPost
  global static void postMethod() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    Blob body = req.requestBody;
    String requestString = body.toString();
    res.addHeader('Content-Type', 'application/json');
    Map<String, String> resMap = new Map<String, String>();
    try {
      Map<String, ServiceLinkResponse> respMap = (Map<String, ServiceLinkResponse>) JSON.deserialize(
        requestString,
        Map<String, ServiceLinkResponse>.class
      );
      String reqType = new List<String>(respMap.keySet())[0];
      resMap.put('RequestType', reqType);
      switch on reqType {
        when 'QuoteReceivedConfirm' {
          resMap.put(
            'LoanNumber',
            processQuoteReceivedConfirm(respMap.values()[0])
          );
        }
        when 'QuoteResponse' {
          resMap.put('LoanNumber', processQuoteResponse(respMap.values()[0]));
        }
        when 'OrderInquiryResponse' {
          resMap.put('LoanNumber', processOrderInquiry(respMap.values()[0]));
        }
        when 'OrderConfirmation' {
          resMap.put(
            'LoanNumber',
            processOrderConfirmation(respMap.values()[0])
          );
        }
        when 'AllTitlesOrdered' {
          resMap.put(
            'LoanNumber',
            processAllQuotesOrdered(respMap.values()[0])
          );
        }
        when 'TitleComplete' {
          resMap.put('LoanNumber', processTitleComplete(respMap.values()[0]));
        }
        when 'AllTitlesCompleted' {
          resMap.put(
            'LoanNumber',
            processAllTitlesComplete(respMap.values()[0])
          );
        }
        when 'Document' {
          resMap.put(
            'LoanNumber',
            processDocumentReceived(respMap.values()[0])
          );
        }
        when 'TaxesOrdered' {
          resMap.put('LoanNumber', processTaxesOrdered(respMap.values()[0]));
        }
        when 'AllTaxesOrdered' {
          resMap.put('LoanNumber', processAllTaxesOrdered(respMap.values()[0]));
        }
        when 'TaxesCompleted' {
          resMap.put('LoanNumber', processTaxesCompleted(respMap.values()[0]));
        }
        when else {
          ServiceLinkException err = new ServiceLinkException();
          err.setMessage('Unable to identify request type.');
          throw err;
        }
      }

      res.statusCode = 201;
      resMap.put('status', 'success');
      res.responseBody = Blob.valueOf(JSON.serialize(resMap));
    } catch (Exception err) {
      res.statusCode = 400;
      res.responseBody = Blob.valueOf(
        JSON.serialize(
          new Map<String, String>{
            'status' => 'error',
            'message' => err.getMessage()
          }
        )
      );
    }
    // List<String> params = Restcontext.request.requestURI.split('/');
  }

  public static String processTaxesCompleted(ServiceLinkResponse resp) {
    List<Title_Order__c> titleOrders = queryTitleOrders(resp);

    if (titleOrders.size() == 0) {
      throwNullError();
    }

    return resp.LoanNumber;
  }

  public static String processAllTaxesOrdered(ServiceLinkResponse resp) {
    List<Title_Order__c> titleOrders = queryTitleOrders(resp);

    if (titleOrders.size() == 0) {
      throwNullError();
    }

    Date atoDate = parseDateString(resp.AllTaxesOrderedDate);

    for (Title_Order__c to : titleOrders) {
      to.All_Taxes_Ordered_Date__c = atoDate;
    }

    update titleOrders;

    return resp.LoanNumber;
  }

  public static String processTaxesOrdered(ServiceLinkResponse resp) {
    List<Title_Order__c> titleOrders = queryTitleOrders(resp);

    if (titleOrders.size() == 0) {
      throwNullError();
    }

    Date taxOrdDate = parseDateString(resp.TaxesOrderedDate);
    for (Title_Order__c to : titleOrders) {
      to.Taxes_Ordered_Date__c = taxOrdDate;
    }
    update titleOrders;
    return resp.LoanNumber;
  }

  public static String processDocumentReceived(ServiceLinkResponse resp) {
    Boolean hasAssetId = String.isNotEmpty(resp.AssetID);

    List<Title_Order__c> titleOrders = queryTitleOrders(resp);

    if (titleOrders.size() == 0) {
      throwNullError();
    }

    ServiceLinkAPI.TitleDocument doc = new ServiceLinkAPI.TitleDocument();
    doc.Base64FileData = resp.Base64FileData;
    doc.DocumentName = resp.DocumentName;
    doc.DocumentType = resp.DocumentType;
    doc.Format = resp.Format;
    doc.Size = resp.Size;

    ContentVersion cv = createContentVersion(
      new List<ServiceLinkAPI.TitleDocument>{ doc },
      (hasAssetId ? titleOrders[0].Id : titleOrders[0].Deal__c)
    )[0];
    List<Deal_Document__c> dealDocs = new List<Deal_Document__c>();
    for (Title_Order__c to : titleOrders) {
      Deal_Document__c dealDoc = createDealDocument(doc, cv, to);
      dealDoc.Service_Link_Id__c = resp.DocumentID + '-' + to.Id;
      dealDocs.add(dealDoc);
    }

    upsert dealDocs Service_Link_Id__c;

    return resp.LoanNumber;
  }

  public static String processAllTitlesComplete(ServiceLinkResponse resp) {
    List<Title_Order__c> titleOrders = queryTitleOrders(resp);

    if (titleOrders.size() == 0) {
      throwNullError();
    }

    Date atcDate = parseDateString(resp.AllTitlesCompleteDate);

    for (Title_Order__c to : titleOrders) {
      to.All_Titles_Complete_Date__c = atcDate;
    }

    update titleOrders;
    return resp.LoanNumber;
  }

  public static String processTitleComplete(ServiceLinkResponse resp) {
    List<Title_Order__c> titleOrders = queryTitleOrders(resp);

    if (titleOrders.size() == 0) {
      throwNullError();
    }

    Date tcDate = parseDateString(resp.TitleCompleteDate);
    for (Title_Order__c to : titleOrders) {
      to.Title_Complete_Date__c = tcDate;
    }

    update titleOrders;
    return resp.LoanNumber;
  }

  public static String processAllQuotesOrdered(ServiceLinkResponse resp) {
    List<Title_Order__c> titleOrders = queryTitleOrders(resp);

    if (titleOrders.size() == 0) {
      throwNullError();
    }

    List<Title_Order__c> updatedTitleOrders = new List<Title_Order__c>();
    for (Title_Order__c to : titleOrders) {
      if (String.isNotEmpty(resp.AllTitlesOrderedDate)) {
        Date updATODate = parseDateString(resp.AllTitlesOrderedDate);
        if (updATODate != to.All_Titles_Ordered_Date__c) {
          to.All_Titles_Ordered_Date__c = updATODate;
          updatedTitleOrders.add(to);
        }
      } else if (
        String.isEmpty(resp.AllTitlesOrderedDate) &&
        to.All_Titles_Ordered_Date__c != null
      ) {
        to.All_Titles_Ordered_Date__c = null;
        updatedTitleOrders.add(to);
      }
    }

    if (updatedTitleOrders.size() > 0) {
      update updatedTitleOrders;
    }

    return resp.LoanNumber;
  }

  public static String processOrderInquiry(ServiceLinkResponse ordInq) {
    
    List<Title_Order__c> titleOrders = queryTitleOrders(ordInq);

    if (titleOrders.size() > 0) {
      Id cvParentId = titleOrders[0].Deal__c;
      Loan_Status__c note = new Loan_Status__c();
      note.OrderInquiryId__c = ordInq.OrderInquiryId;
      note.OrderInquiryNoteId__c = ordInq.OrderInquiryNoteId;
      if (titleOrders.size() == 1) {
        note.Title_Order__c = titleOrders[0].Id;
      }
      note.Deal__c = titleOrders[0].Deal__c;
      note.Subject__c =
        'Title Order Inquiry ' + System.now().format('yyyy-MM-dd h:mm a');
      note.Comment__c = ordInq.NoteText;

      insert note;

      if (String.isNotEmpty(ordInq.AssetID)) {
        cvParentId = titleOrders[0].Id;
      }

      List<ContentVersion> contentVersions = ordInq.Documents != null &&
        ordInq.Documents.size() > 0
        ? createContentVersion(ordInq.Documents, cvParentId)
        : new List<ContentVersion>();

      List<Deal_Document__c> dealDocs = new List<Deal_Document__c>();

      if (contentVersions.size() > 0) {
        Map<String, ServiceLinkAPI.TitleDocument> docMap = new Map<String, ServiceLinkAPI.TitleDocument>();
        for (ServiceLinkAPI.TitleDocument doc : ordInq.Documents) {
          docMap.put(doc.DocumentName, doc);
        }

        for (ContentVersion cv : contentVersions) {
          for (Title_Order__c to : titleOrders) {
            Deal_Document__c dd = createDealDocument(
              docMap.get(cv.PathOnClient),
              cv,
              to
            );
            dealDocs.add(dd);
          }
        }
        insert dealDocs;
      }

      List<Title_Order__c> updatedTitleOrders = new List<Title_Order__c>();

      for (Title_Order__c to : titleOrders) {
        Boolean isUpdated = false;
        if (
          String.isEmpty(to.Asset_ID__c) && String.isNotEmpty(ordInq.AssetID)
        ) {
          to.Asset_ID__c = ordInq.AssetID;
          isUpdated = true;
        }
        if (
          String.isEmpty(to.Order_Number__c) &&
          String.isNotEmpty(ordInq.OrderNumber)
        ) {
          to.Order_Number__c = ordInq.OrderNumber;
          isUpdated = true;
        }
        if (isUpdated) {
          updatedTitleOrders.add(to);
        }
      }

      if (updatedTitleOrders.size() > 0) {
        update updatedTitleOrders;
      }
    } else {
      throwNullError();
    }

    return ordInq.LoanNumber;
  }

  public static String processOrderConfirmation(ServiceLinkResponse ordConf) {
    List<Title_Order__c> titleOrders = queryTitleOrders(ordConf);

    if (titleOrders.size() == 0) {
      throwNullError();
    }

    for (Title_Order__c to : titleOrders) {
      to.Order_Opened_Date__c = DateTime.valueOf(
        ordConf.OrderOpenedDate.replace('T', ' ')
      );
      if (ordConf.Status == 'SUCCESS') {
        to.Order_Number__c = ordConf.OrderNumber;
        to.Status__c = 'Order Confirmed';
      } else {
        to.Status__c = 'Order Failed';
        to.Error_Message__c = ordConf.ErrorMessage;
      }
    }

    update titleOrders;

    return ordConf.LoanNumber;
  }

  public static String processQuoteResponse(ServiceLinkResponse qteRes) {
    List<Title_Order__c> titleOrders = queryTitleOrders(qteRes);

    if (titleOrders.size() > 0) {
      ContentVersion cv = createContentVersion(
        new List<ServiceLinkAPI.TitleDocument>{ qteRes.Document },
        titleOrders[0].Deal__c
      )[0];
      List<Deal_Document__c> dealDocs = new List<Deal_Document__c>();
      for (Title_Order__c to : titleOrders) {
        ServiceLinkAPI.TitleDocument doc = qteRes.Document;
        Deal_Document__c dd = createDealDocument(doc, cv, to);
        dealDocs.add(dd);
      }
      insert dealDocs;
    } else {
      ServiceLinkException err = new ServiceLinkException();
      err.setMessage('No existing order found for QuoteID ' + qteRes.QuoteID);
      throw err;
    }
    return qteRes.LoanNumber;
  }

  public static Deal_Document__c createDealDocument(
    ServiceLinkAPI.TitleDocument doc,
    ContentVersion cv,
    Title_Order__c to
  ) {
    return new Deal_Document__c(
      File_Name__c = cv.Title,
      ContentVersion_Id__c = cv.Id,
      Attachment_Id__c = cv.ContentDocumentId,
      Type__c = doc.DocumentType,
      Section__c = 'Title Orders',
      Document_Type__c = doc.DocumentType,
      Document_Loaded__c = true,
      Added_By__c = userInfo.getUserId(),
      Other_Document_Type__c = 'Title Order Documents',
      Deal__c = to.Deal__c,
      Property__c = to.Property__c,
      Title_Order__c = to.Id
    );
  }

  public static List<ContentVersion> createContentVersion(
    List<ServiceLinkAPI.TitleDocument> docs,
    Id parentId
  ) {
    List<ContentVersion> contentVersions = new List<ContentVersion>();

    for (ServiceLinkAPI.TitleDocument doc : docs) {
      ContentVersion cv = new ContentVersion();
      cv.VersionData = EncodingUtil.base64Decode(doc.Base64FileData);
      cv.Title = System.now().format('yyyy-MM-dd_h:mm_a_') + doc.DocumentName;
      cv.PathOnClient = doc.DocumentName;
      cv.Type__c = doc.DocumentType;
      contentVersions.add(cv);
    }

    insert contentVersions;

    List<ContentVersion> cvsQueried = [
      SELECT Id, VersionData, Title, PathOnClient, Type__c, ContentDocumentId
      FROM ContentVersion
      WHERE Id IN :contentVersions
    ];
    List<ContentDocumentLink> cdLinks = new List<ContentDocumentLink>();

    for (ContentVersion cv : cvsQueried) {
      ContentDocumentLink cdl = new ContentDocumentLink(
        ShareType = 'I',
        Visibility = 'AllUsers',
        LinkedEntityId = parentId,
        ContentDocumentId = cv.ContentDocumentId
      );
      cdLinks.add(cdl);
    }

    insert cdLinks;
    return cvsQueried;
  }

  public static String processQuoteReceivedConfirm(ServiceLinkResponse reqObj) {
    List<Title_Order__c> titleOrders = queryTitleOrders(reqObj);
    if (titleOrders.size() > 0) {
      for (Title_Order__c tO : titleOrders) {
        tO.Order_Opened_Date__c = DateTime.valueOf(
          reqObj.OrderOpenedDate.replace('T', ' ')
        );
        tO.Bulk_Project_Order_Num__c = reqObj.BulkProjectOrderNum;
      }
      update titleOrders;
    } else {
      ServiceLinkException err = new ServiceLinkException();
      err.setMessage('No existing order found for QuoteID ' + reqObj.QuoteID);
      throw err;
    }

    return reqObj.LoanNumber;
  }

  public static Date parseDateString(String dateString) {
    if (String.isEmpty(dateString)) {
      return null;
    }
    List<String> dateList = dateString.split('-');
    return Date.newInstance(
      Integer.valueOf(dateList[0]),
      Integer.valueOf(dateList[1]),
      Integer.valueOf(dateList[2])
    );
  }

  public static void throwNullError() {
    ServiceLinkException err = new ServiceLinkException();
    err.setMessage('Unable to locate orders.');
    throw err;
  }

  public static List<Title_Order__c> queryTitleOrders(
    ServiceLinkResponse resp
  ) {
    Map<String, String> fieldValueMap = new Map<String, String>();

    if (resp.QuoteID != null && String.isNotEmpty(resp.QuoteID)) {
      fieldValueMap.put('Quote_ID__c', resp.QuoteID);
    }
    if (
      resp.BulkProjectOrderNum != null &&
      String.isNotEmpty(resp.BulkProjectOrderNum)
    ) {
      fieldValueMap.put('Bulk_Project_Order_Num__c', resp.BulkProjectOrderNum);
    }
    if (resp.LoanNumber != null && String.isNotEmpty(resp.LoanNumber)) {
      fieldValueMap.put('Loan_Number__c', resp.LoanNumber);
    }
    if (resp.AssetID != null && String.isNotEmpty(resp.AssetID)) {
      fieldValueMap.put('Asset_ID__c', resp.AssetID);
    }
    if (resp.OrderNumber != null && String.isNotEmpty(resp.OrderNumber)) {
      fieldValueMap.put('Order_Number__c', resp.OrderNumber);
    }

    if (fieldValueMap.size() > 0) {
      Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
      List<String> fieldList = new List<String>(
        schemaMap.get('Title_Order__c').getDescribe().fields.getMap().keySet()
      );

      String queryString =
        'SELECT ' +
        String.join(fieldList, ', ') +
        ' FROM Title_Order__c WHERE ';
      List<String> whereClauseList = new List<String>();
      for (String key : fieldValueMap.keySet()) {
        String val = String.escapeSingleQuotes(fieldValueMap.get(key));
        whereClauseList.add(key + ' = \'' + val + '\'');
      }
      queryString += String.join(whereClauseList, ' AND ');

      return Database.query(queryString);
    } else {
      return new List<Title_Order__c>();
    }
  }

  public virtual class ServiceLinkResponse {
    public String LoanNumber { get; set; }
    public String QuoteID { get; set; }
    public String BulkProjectOrderNum { get; set; }
    public String OrderOpenedDate { get; set; }
    public String Comments { get; set; }
    public ServiceLinkAPI.TitleDocument Document { get; set; }
    public String AssetID { get; set; }
    public String OrderNumber { get; set; }
    public String Status { get; set; }
    public String ErrorMessage { get; set; }
    public String IncomingTransactionId { get; set; }
    public String OrderInquiryId { get; set; }
    public String OrderInquiryNoteId { get; set; }
    public String NoteText { get; set; }
    public List<ServiceLinkAPI.TitleDocument> Documents { get; set; }
    public String AllTitlesOrderedDate { get; set; }
    public String TitleCompleteDate { get; set; }
    public String AllTitlesCompleteDate { get; set; }
    public String DocumentType { get; set; }
    public String DocumentName { get; set; }
    public String Format { get; set; }
    public Long Size { get; set; }
    public String Base64FileData { get; set; }
    public String DocumentID { get; set; }
    public String TaxesOrderedDate { get; set; }
    public String AllTaxesOrderedDate { get; set; }
    public String TaxesCompletedDate { get; set; }
  }
}

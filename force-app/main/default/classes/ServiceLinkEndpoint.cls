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

      List<Title_Order__c> titleOrders = queryTitleOrders(respMap.values()[0]);
      if (titleOrders.size() == 0) {
        throwNullError();
      }

      switch on reqType {
        when 'QuoteReceivedConfirm' {
          resMap.put(
            'LoanNumber',
            processQuoteReceivedConfirm(respMap.values()[0], titleOrders)
          );
        }
        when 'QuoteResponse' {
          resMap.put(
            'LoanNumber',
            processQuoteResponse(respMap.values()[0], titleOrders)
          );
        }
        when 'OrderInquiryResponse' {
          resMap.put(
            'LoanNumber',
            processOrderInquiry(respMap.values()[0], titleOrders)
          );
        }
        when 'OrderConfirmation' {
          resMap.put(
            'LoanNumber',
            processOrderConfirmation(respMap.values()[0], titleOrders)
          );
        }
        when 'AllTitlesOrdered' {
          resMap.put(
            'LoanNumber',
            processAllQuotesOrdered(respMap.values()[0], titleOrders)
          );
        }
        when 'TitleComplete', 'AllTitlesCompleted', 'OriginalTitleCleared', 'OriginalAllTitlesCleared' {
          resMap.put(
            'LoanNumber',
            processTitles(respMap.values()[0], titleOrders)
          );
        }
        when 'Document' {
          resMap.put(
            'LoanNumber',
            processDocumentReceived(respMap.values()[0], titleOrders)
          );
        }
        when 'TaxesOrdered',
          'AllTaxesOrdered',
          'TaxesCompleted',
          'AllTaxesCompleted' {
          resMap.put(
            'LoanNumber',
            processTaxes(respMap.values()[0], titleOrders)
          );
        }
        when 'HOAExists',
          'HOAOrdered',
          'AllHOAOrdered',
          'HOACompleted',
          'AllHOACompleted' {
          resMap.put(
            'LoanNumber',
            processHoa(respMap.values()[0], titleOrders)
          );
        }
        when 'PayOffExists',
          'PayoffOrdered',
          'AllPayoffsOrdered',
          'PayoffCompleted',
          'AllPayoffsCompleted' {
          resMap.put(
            'LoanNumber',
            processPayoff(respMap.values()[0], titleOrders)
          );
        }
        when 'ProblemCurativeItem' {
          resMap.put(
            'LoanNumber',
            processProblemCurativeItem(respMap.values()[0], titleOrders)
          );
        }
        when else {
          ServiceLinkException err = new ServiceLinkException();
          err.setMessage('Unable to identify request ' + reqType + '.');
          throw err;
        }
      }

      res.statusCode = 201;
      resMap.put('status', 'success');
      res.responseBody = Blob.valueOf(JSON.serialize(resMap));
    } catch (Exception err) {
      res.statusCode = 400;
      Map<String, String> errMap = new Map<String, String>{
        'status' => 'error',
        'message' => err.getMessage(),
        'lineNumber' => String.valueOf(err.getLineNumber()),
        'stackTrace' => err.getStackTraceString(),
        'exceptionType' => err.getTypeName()
      };
      if (err.getTypeName().containsIgnoreCase('dml')) {
        Integer numErrors = err.getNumDml();
        String fieldNames = '';
        for (Integer i = 0; i < numErrors; i++) {
          fieldNames += err.getDmlFieldNames(i) + ', ';
        }
        errMap.put('fieldNames', fieldNames);
      }

      res.responseBody = Blob.valueOf(JSON.serialize(errMap));
    }
    // List<String> params = Restcontext.request.requestURI.split('/');
  }

  public static String processProblemCurativeItem(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders
  ) {

    Title_Order__c to = titleOrders[0];
    Loan_Status__c loanNote = new Loan_Status__c();
    loanNote.Deal__c = to.Deal__c;
    loanNote.Title_Order__c = to.Id;
    loanNote.Servicelink_Item_Id__c = resp.ItemId;
    loanNote.Servicelink_Item_Type__c = resp.ItemType;
    loanNote.Subject__c = resp.ItemType + ' - ' + resp.ItemTypeDesc;
    loanNote.Comment__c = resp.ItemNoteText + '\nCannot Cure Reasons: ' + resp.CannotCureReasons;
    
    upsert loanNote Servicelink_Item_Id__c;

    return resp.LoanNumber;
  }

  public static String processPayoff(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders
  ) {
    Date poOrderedDate = parseDateString(resp.PayoffOrderedDate);
    Date allPoOrderedDate = parseDateString(resp.AllPayoffsOrderedDate);
    Date poCompletedDate = parseDateString(resp.PayoffCompletedDate);
    Date allPoCompletedDate = parseDateString(resp.AllPayoffsCompletedDate);

    if (resp.RecId != null && String.isNotEmpty(resp.RecId)) {
      Loan_Status__c loanNote = new Loan_Status__c();

      loanNote.Payoff_Rec_Id__c = resp.RecId;
      loanNote.Subject__c = 'Payoff for Property with Asset ID ' + resp.AssetID;
      loanNote.Title_Order__c = titleOrders[0].Id;
      loanNote.Deal__c = titleOrders[0].Deal__c;

      String comment =
        'Payoff Details:\n\nDeal Loan Number: ' + resp.LoanNumber;
      if (poCompletedDate != null) {
        comment += '\nPayoff Completed Date: ' + poCompletedDate;
      }
      if (poOrderedDate != null) {
        comment += '\nPayoff Ordered Date: ' + poOrderedDate;
      }

      loanNote.Comment__c = comment;

      upsert loanNote Payoff_Rec_Id__c;
    }

    for (Title_Order__c to : titleOrders) {
      to.Payoff_Exists__c =
        resp.PayOffExists != null &&
        resp.PayOffExists.toLowerCase() == 'yes';
      to.All_Payoffs_Completed_Date__c = resp.AllPayoffsCompletedDate != null ? allPoCompletedDate : to.All_Payoffs_Completed_Date__c;
      to.All_Payoffs_Ordered_Date__c = resp.AllPayoffsOrderedDate != null ? allPoOrderedDate : to.All_Payoffs_Ordered_Date__c;
      to.Payoff_Completed_Date__c = resp.PayoffCompletedDate != null ? poCompletedDate : to.Payoff_Completed_Date__c;
      to.Payoff_Ordered_Date__c = resp.PayoffOrderedDate != null ? poOrderedDate : to.Payoff_Ordered_Date__c;
    }

    update titleOrders;

    return resp.LoanNumber;
  }

  public static String processHoa(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders
  ) {
    Date hoaOrderedDate = parseDateString(resp.HOAOrderedDate);
    Date allHoaOrderedDate = parseDateString(resp.AllHOAOrderedDate);
    Date hoaCompletedDate = parseDateString(resp.HOACompletedDate);
    Date allHoaCompDate = parseDateString(resp.AllHOACompletedDate);

    if (resp.RecId != null && String.isNotEmpty(resp.RecId)) {
      Loan_Status__c loanNote = new Loan_Status__c();

      loanNote.HOA_Rec_Id__c = resp.RecId;
      loanNote.Subject__c = 'HOA for Property with Asset ID ' + resp.AssetID;
      loanNote.Title_Order__c = titleOrders[0].Id;
      loanNote.Deal__c = titleOrders[0].Deal__c;

      String comment = 'HOA Details:\n\nDeal Loan Number: ' + resp.LoanNumber;
      if (hoaCompletedDate != null) {
        comment += '\nHOA Completed Date: ' + hoaCompletedDate;
      }
      if (hoaOrderedDate != null) {
        comment += '\nHOA Ordered Date: ' + hoaOrderedDate;
      }

      loanNote.Comment__c = comment;

      upsert loanNote HOA_Rec_Id__c;
    }

    for (Title_Order__c to : titleOrders) {
      to.HOA_Exists__c =
        resp.HOAExists != null &&
        resp.HOAExists.toLowerCase() == 'yes';
      to.HOA_Ordered_Date__c = resp.HOAOrderedDate != null ? hoaOrderedDate : to.HOA_Ordered_Date__c;
      to.All_HOA_Ordered_Date__c = resp.AllHOAOrderedDate != null ? allHoaOrderedDate : to.All_HOA_Ordered_Date__c;
      to.HOA_Completed_Date__c = resp.HOACompletedDate != null ? hoaCompletedDate : to.HOA_Completed_Date__c;
      to.All_HOA_Completed_Date__c = resp.AllHOACompletedDate != null ? allHoaCompDate : to.All_HOA_Completed_Date__c;
    }

    update titleOrders;

    return resp.LoanNumber;
  }

  public static String processTaxes(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders
  ) {
    Date atcDate = parseDateString(resp.AllTaxesCompletedDate);
    Date atoDate = parseDateString(resp.AllTaxesOrderedDate);
    Date taxOrdDate = parseDateString(resp.TaxesOrderedDate);
    Date tcDate = parseDateString(resp.TaxesCompletedDate);

    for (Title_Order__c to : titleOrders) {
      to.Taxes_Ordered_Date__c = taxOrdDate;
      to.All_Taxes_Ordered_Date__c = atoDate;
      to.Taxes_Completed_Date__c = tcDate;
      to.All_Taxes_Completed_Date__c = atcDate;
    }
    update titleOrders;
    return resp.LoanNumber;
  }

  public static String processDocumentReceived(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders
  ) {
    Boolean hasAssetId = String.isNotEmpty(resp.AssetID);
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
      to.Document_Received__c = true;
    }

    upsert dealDocs Service_Link_Id__c;

    update titleOrders;

    return resp.LoanNumber;
  }

  public static String processTitles(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders
  ) {
    Date atcDate = parseDateString(resp.AllTitlesCompleteDate);
    Date tcDate = parseDateString(resp.TitleCompleteDate);
    Date otcDate = parseDateString(resp.OriginalTitleClearedDate);
    Date oatcDate = parseDateString(resp.OriginalAllTitlesClearedDate);
    for (Title_Order__c to : titleOrders) {
      to.All_Titles_Complete_Date__c = atcDate;
      to.Title_Complete_Date__c = tcDate;
      to.Original_Title_Cleared_Date__c = otcDate;
      to.Original_All_Titles_Cleared_Date__c = oatcDate;
    }

    update titleOrders;
    return resp.LoanNumber;
  }

  public static String processAllQuotesOrdered(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders
  ) {
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

  public static String processOrderInquiry(
    ServiceLinkResponse ordInq,
    List<Title_Order__c> titleOrders
  ) {
    if (titleOrders.size() > 0) {
      Id cvParentId = titleOrders[0].Deal__c;
      Loan_Status__c note = new Loan_Status__c();
      note.OrderInquiryId__c = ordInq.CustInqId;
      note.OrderInquiryNoteId__c = ordInq.NoteId;
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
    }

    return ordInq.LoanNumber;
  }

  public static String processOrderConfirmation(
    ServiceLinkResponse ordConf,
    List<Title_Order__c> titleOrders
  ) {
    for (Title_Order__c to : titleOrders) {
      to.Order_Opened_Date__c = DateTime.valueOf(
        ordConf.OrderOpenedDate.replace('T', ' ')
      );
      if (ordConf.Status == 'SUCCESS') {
        to.Order_Number__c = ordConf.OrderNumber;
      } else {
        to.Error_Message__c = ordConf.ErrorMessage;
      }
    }

    update titleOrders;

    return ordConf.LoanNumber;
  }

  public static String processQuoteResponse(
    ServiceLinkResponse qteRes,
    List<Title_Order__c> titleOrders
  ) {
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

  public static String processQuoteReceivedConfirm(
    ServiceLinkResponse reqObj,
    List<Title_Order__c> titleOrders
  ) {
    if (titleOrders.size() > 0) {
      for (Title_Order__c tO : titleOrders) {
        tO.Order_Opened_Date__c = DateTime.valueOf(
          reqObj.OrderOpenedDate.replace('T', ' ')
        );
        tO.Bulk_Project_Order_Num__c = reqObj.BulkProjectOrderNum;
      }
      update titleOrders;
    }

    return reqObj.LoanNumber;
  }

  public static Date parseDateString(String dateString) {
    if (dateString == null || String.isEmpty(dateString)) {
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

  public virtual class ServiceLinkIdFields {
    public String LoanNumber;
    public String QuoteID;
    public String BulkProjectOrderNum;
    public String AssetID;
    public String OrderNumber;
    public String CustInqId;
    public String NoteId;
    public String IncomingTransactionId;
    public String DocumentID;
    public String RecId;
  }

  public virtual class ServiceLinkDateFields extends ServiceLinkIdFields {
    public String OrderOpenedDate;
    public String AllTitlesOrderedDate;
    public String TitleCompleteDate;
    public String AllTitlesCompleteDate;
    public String TaxesOrderedDate;
    public String AllTaxesOrderedDate;
    public String TaxesCompletedDate;
    public String AllTaxesCompletedDate;
    public String HOAOrderedDate;
    public String AllHOAOrderedDate;
    public String HOACompletedDate;
    public String AllHOACompletedDate;
    public String PayoffOrderedDate;
    public String AllPayoffsOrderedDate;
    public String PayoffCompletedDate;
    public String AllPayoffsCompletedDate;
    public String OriginalTitleClearedDate;
    public String OriginalAllTitlesClearedDate;
  }

  public class ServiceLinkResponse extends ServiceLinkDateFields {
    public String Comments;
    public ServiceLinkAPI.TitleDocument Document;
    public String Status;
    public String ErrorMessage;
    public String NoteText;
    public List<ServiceLinkAPI.TitleDocument> Documents;
    public String DocumentType;
    public String DocumentName;
    public String Format;
    public Long Size;
    public String Base64FileData;
    public String HOAExists;
    public String PayOffExists;
    public String ItemId;
    public String ItemType;
    public String ItemTypeDesc;
    public String ItemNoteText;
    public String CannotCureReasons;
  }
}

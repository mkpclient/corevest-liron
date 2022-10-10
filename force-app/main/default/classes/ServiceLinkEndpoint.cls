@RestResource(urlMapping='/servicelink/*')
global without sharing class ServiceLinkEndpoint {
  public class ServiceLinkException extends Exception {
  }

  public static final Map<String, String> REQ_TO_DATEFIELD_MAP = new Map<String, String>{
    'CancelRequestConfirmation' => 'Cancelled_Date__c',
    'OrderChangeConfirmation' => 'Order_Change_Confirmation_Date__c',
    'OrderInquiryConfirmation' => 'Order_Inquiry_Confirmation_Date__c',
    'DocumentSubmissionConfirm' => 'Document_Submission_Confirmation_Date__c',
    'QuoteAcceptedConfirmation' => 'Quote_Accepted_Confirmation_Date__c',
    'LoanPortfolioChangeConfirm' => 'Loan_Portfolio_Confirmation_Date__c'
  };

  public static final Map<String, String> REQ_TO_STATUS_MAP = new Map<String,STring>{
    'CancelRequestConfirmation' => 'Cancelled',
    'OrderChangeConfirmation' => 'Order Change Confirmed',
    'QuoteAcceptedConfirmation' => 'Quote Accepted',
    'LoanPortfolioChangeConfirm' => 'Loan Portfolio Change Confirmed'
  };

  //these requests send a new order number so it won't be possible to query them just yet
  public static final List<String> NEW_ORDER_NUM_REQS = new List<String>{
    'OrderConfirmation',
    'OrderInquiryConfirmation'
  };

  public static final List<String> NEW_BULK_NUM = new List<String>{
    'QuoteReceivedConfirm'
  };

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

      List<Title_Order__c> titleOrders = queryTitleOrders(
        respMap.values()[0],
        NEW_ORDER_NUM_REQS.contains(reqType),
        NEW_BULK_NUM.contains(reqType)
      );
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
        when 'TitleComplete',
          'AllTitlesCompleted',
          'OriginalTitleCleared',
          'OriginalAllTitlesCleared' {
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
        when 'TitleUnCleared', 'LatestAllTitlesCleared', 'TitleReCleared' {
          resMap.put(
            'LoanNumber',
            processTitleClearing(
              respMap.values()[0],
              titleOrders,
              reqType.containsIgnoreCase('alltitles')
            )
          );
        }
        when 'DeedsOrdered', 'UnExecutedDeedsSent', 'AllClearedToClose' {
          resMap.put(
            'LoanNumber',
            processDeeds(respMap.values()[0], titleOrders)
          );
        }
        when 'LoanDocsReceived',
          'SignedDocsScannedDate',
          'ScannedDocsForwarded',
          'DocsEstArrivalToLender',
          'SignedDocsReceivedAtEscrow',
          'FileFundedDate' {
          resMap.put(
            'LoanNumber',
            processDocsDates(respMap.values()[0], titleOrders)
          );
        }
        when 'RecordingTracking' {
          resMap.put(
            'LoanNumber',
            processRecordingTracking(respMap.values()[0], titleOrders)
          );
        }
        when 'SigningAppointment' {
          resMap.put(
            'LoanNumber',
            processSigningAppointment(respMap.values()[0], titleOrders)
          );
        }
        when else {
          if(REQ_TO_DATEFIELD_MAP.keySet().contains(reqType)) {
            resMap.put('LoanNumber', processRequestConfirmations(respMap.values()[0], titleOrders, reqType));
          } else {
            ServiceLinkException err = new ServiceLinkException();
            err.setMessage('Unable to identify request ' + reqType + '.');
            throw err;
          }
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

  public static String processRecordingTracking(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders
  ) {
    Record_Tracking__c rt = new Record_Tracking__c();
    rt.Title_Order__c = titleOrders[0].Id;
    rt.RecId__c = resp.RecId;
    rt.Recording_Date__c = parseDateString(resp.RecordingDate);
    rt.Recording_Order_Number__c = resp.RecordingOrderNumber;
    rt.Recording_State__c = resp.RecordingState;
    rt.Recording_County__c = resp.RecordingCounty;
    rt.Recording_Type__c = resp.RecordingType;
    rt.Recording_Desc__c = resp.RecordingDesc;
    rt.Instrument_Number__c = resp.InstrumentNumber;
    rt.Book_Number__c = resp.BookNumber;
    rt.Page_Number__c = resp.PageNumber;
    rt.Grantor__c = resp.Grantor;
    rt.Grantee__c = resp.Grantee;
    rt.Mortgagee__c = resp.Mortgagee;
    rt.Mortgagor__c = resp.Mortgagor;

    upsert rt RecId__c;

    return resp.LoanNumber;
  }

  public static String processSigningAppointment(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders
  ) {
    Signing_Appointment__c sAppt = new Signing_Appointment__c();
    List<Signing_Attendee__c> sAtts = new List<Signing_Attendee__c>();
    List<String> attendeeNames = new List<String>();

    for (SigningAttendee sa : resp.Attendees) {
      if (sa.Name != null && String.isNotEmpty(sa.Name)) {
        attendeeNames.add(sa.Name);
      }
    }

    List<Deal_Contact__c> dealContacts = [
      SELECT Id, Contact__r.Name
      FROM Deal_Contact__c
      WHERE
        Contact__r.Name IN :attendeeNames
        AND Deal__c IN (
          SELECT Deal__c
          FROM Title_Order__c
          WHERE Id IN :titleOrders
        )
    ];

    sAppt.RecId__c = resp.RecId;
    sAppt.Appointment_Status__c = resp.AppointmentStatus;
    sAppt.Scheduled_Signing_Date__c = resp.ScheduledSigningDate != null &&
      String.isNotEmpty(resp.ScheduledSigningDate)
      ? DateTime.valueOf(resp.ScheduledSigningDate.replace('T', ' '))
      : null;
    sAppt.Cancelled_Date__c = parseDateString(resp.CancelledDate);
    sAppt.Closed_Date__c = parseDateString(resp.ClosedDate);
    SigningLocation sl = resp.SigningLocation;
    sAppt.Signing_Address1__c = sl.Address1;
    sAppt.Signing_Address2__c = sl.Address2;
    sAppt.Signing_City__c = sl.City;
    sAppt.Signing_State__c = sl.State;
    sAppt.Signing_Zip_Code__c = sl.Zipcode;
    sAppt.Title_Order__c = titleOrders[0].Id;

    upsert sAppt RecId__c;

    if (dealContacts.size() > 0) {
      for (Deal_Contact__c dc : dealContacts) {
        Signing_Attendee__c sAtt = new Signing_Attendee__c();
        sAtt.Signing_Appointment__c = sAppt.Id;
        sAtt.Deal_Contact__c = dc.Id;
        sAtt.Unique_Id__c = dc.Id + '-' + sAppt.Id;
        sAtt.Name = dc.Contact__r.Name;
        sAtts.add(sAtt);
      }

      upsert sAtts Unique_Id__c;
    }
    return resp.LoanNumber;
  }

  public static String processDocsDates(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders
  ) {
    Date ldrDate = parseDateString(resp.LoanDocsReceivedDate);
    Date sdsDate = parseDateString(resp.SignedDocsScannedDate);
    Date sdfDate = parseDateString(resp.ScannedDocsForwardedDate);
    Date deaDate = parseDateString(resp.DocsEstArrivalDate);
    Date sdrDate = parseDateString(resp.SignedDocsReceivedDate);
    Date ffDate = parseDateString(resp.FileFundedDate);

    for (Title_Order__c to : titleOrders) {
      to.Loan_Docs_Received_Date__c = ldrDate != null
        ? ldrDate
        : to.Loan_Docs_Received_Date__c;
      to.Signed_Docs_Scanned_Date__c = sdsDate != null
        ? sdsDate
        : to.Signed_Docs_Scanned_Date__c;
      to.Scanned_Docs_Forwarded_Date__c = sdfDate != null
        ? sdfDate
        : to.Scanned_Docs_Forwarded_Date__c;
      to.Docs_Est_Arrival_Date__c = deaDate != null
        ? deaDate
        : to.Docs_Est_Arrival_Date__c;
      to.Signed_Docs_Received_Date__c = sdrDate != null
        ? sdrDate
        : to.Signed_Docs_Received_Date__c;
      to.File_Funded_Date__c = ffDate != null ? ffDate : to.File_Funded_Date__c;
    }

    update titleOrders;

    return resp.LoanNumber;
  }

  public static String processDeeds(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders
  ) {
    Date doDate = parseDateString(resp.DeedsOrdered);
    Date uedsDate = parseDateString(resp.UnExecDeedSentDate);
    Date actcDate = parseDateString(resp.AllClearedToCloseDate);

    for (Title_Order__c to : titleOrders) {
      to.Deeds_Ordered_Date__c = doDate != null
        ? doDate
        : to.Deeds_Ordered_Date__c;
      to.Un_Exec_Deed_Sent_Date__c = uedsDate != null
        ? uedsDate
        : to.Un_Exec_Deed_Sent_Date__c;
      to.All_Cleared_To_Close_Date__c = actcDate != null
        ? actcDate
        : to.All_Cleared_To_Close_Date__c;
    }

    update titleOrders;

    return resp.LoanNumber;
  }

  public static String processTitleClearing(
    ServiceLinkResponse resp,
    List<Title_Order__c> titleOrders,
    Boolean isAllCleared
  ) {
    Date ltcDate = parseDateString(resp.LatestTitleClearedDate);
    Date latcDate = parseDateString(resp.LatestAllTitlesCleared);

    for (Title_Order__c to : titleOrders) {
      to.Latest_Title_Cleared_Date__c = isAllCleared
        ? to.Latest_Title_Cleared_Date__c
        : ltcDate;
      to.Latest_All_Titles_Cleared_Date__c = isAllCleared
        ? latcDate
        : to.Latest_All_Titles_Cleared_Date__c;
    }

    update titleOrders;

    return resp.LoanNumber;
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
    loanNote.Comment__c =
      resp.ItemNoteText +
      '\nCannot Cure Reasons: ' +
      resp.CannotCureReasons;

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
      to.All_Payoffs_Completed_Date__c = resp.AllPayoffsCompletedDate != null
        ? allPoCompletedDate
        : to.All_Payoffs_Completed_Date__c;
      to.All_Payoffs_Ordered_Date__c = resp.AllPayoffsOrderedDate != null
        ? allPoOrderedDate
        : to.All_Payoffs_Ordered_Date__c;
      to.Payoff_Completed_Date__c = resp.PayoffCompletedDate != null
        ? poCompletedDate
        : to.Payoff_Completed_Date__c;
      to.Payoff_Ordered_Date__c = resp.PayoffOrderedDate != null
        ? poOrderedDate
        : to.Payoff_Ordered_Date__c;
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
      to.HOA_Ordered_Date__c = resp.HOAOrderedDate != null
        ? hoaOrderedDate
        : to.HOA_Ordered_Date__c;
      to.All_HOA_Ordered_Date__c = resp.AllHOAOrderedDate != null
        ? allHoaOrderedDate
        : to.All_HOA_Ordered_Date__c;
      to.HOA_Completed_Date__c = resp.HOACompletedDate != null
        ? hoaCompletedDate
        : to.HOA_Completed_Date__c;
      to.All_HOA_Completed_Date__c = resp.AllHOACompletedDate != null
        ? allHoaCompDate
        : to.All_HOA_Completed_Date__c;
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
      to.Taxes_Ordered_Date__c = taxOrdDate != null
        ? taxOrdDate
        : to.Taxes_Ordered_Date__c;
      to.All_Taxes_Ordered_Date__c = atoDate != null
        ? atoDate
        : to.All_Taxes_Ordered_Date__c;
      to.Taxes_Completed_Date__c = tcDate != null
        ? tcDate
        : to.Taxes_Completed_Date__c;
      to.All_Taxes_Completed_Date__c = atcDate != null
        ? atcDate
        : to.All_Taxes_Completed_Date__c;
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
    Date atcDate = parseDateString(resp.AllTitlesCompletedDate);
    Date tcDate = parseDateString(resp.TitleCompleteDate);
    Date otcDate = parseDateString(resp.OriginalTitleClearedDate);
    Date oatcDate = parseDateString(resp.OriginalAllTitlesClearedDate);
    for (Title_Order__c to : titleOrders) {
      to.All_Titles_Complete_Date__c = atcDate != null
        ? atcDate
        : to.All_Titles_Complete_Date__c;
      to.Title_Complete_Date__c = tcDate != null
        ? tcDate
        : to.Title_Complete_Date__c;
      to.Original_Title_Cleared_Date__c = otcDate != null
        ? otcDate
        : to.Original_Title_Cleared_Date__c;
      to.Original_All_Titles_Cleared_Date__c = oatcDate != null
        ? oatcDate
        : to.Original_All_Titles_Cleared_Date__c;
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
        to.Has_Order_Inquiry_Response__c = true;
        if (
          String.isEmpty(to.Asset_ID__c) && String.isNotEmpty(ordInq.AssetID)
        ) {
          to.Asset_ID__c = ordInq.AssetID;
        }
        if (
          String.isEmpty(to.Order_Number__c) &&
          String.isNotEmpty(ordInq.OrderNumber)
        ) {
          to.Order_Number__c = ordInq.OrderNumber;
          to.Recording_Order_Number__c = ordInq.OrderNumber;
        }
        
      }

      if (updatedTitleOrders.size() > 0) {
        update updatedTitleOrders;
      }
    }

    return ordInq.LoanNumber;
  }

  public static String processRequestConfirmations(
    ServiceLinkResponse sl,
    List<Title_Order__c> titleOrders,
    String reqType
  ) {
    for (Title_Order__c to : titleOrders) {
      if (sl.Status == 'SUCCESS') {
        to.put(REQ_TO_DATEFIELD_MAP.get(reqType), (DateTime) System.now());
        if(REQ_TO_STATUS_MAP.containsKey(reqType)) {
          to.Status__c = REQ_TO_STATUS_MAP.get(reqType);
        }

        if (String.isNotEmpty(sl.AssetID)) {
          to.Asset_ID__c = sl.AssetID;
        }
        if (String.isNotEmpty(sl.OrderNumber)) {
          to.Order_Number__c = sl.OrderNumber;
        }
        to.Error_Message__c = null;
      } else {
        to.Error_Message__c = sl.ErrorMessage;
      }
    }

    update titleOrders;

    return sl.LoanNumber;
  }

  public static String processOrderConfirmation(
    ServiceLinkResponse ordConf,
    List<Title_Order__c> titleOrders
  ) {
    List<String> dateString = ordConf.OrderOpenedDate.split('-');
    for (Title_Order__c to : titleOrders) {
      to.Order_Opened_Date__c = ordConf.OrderOpenedDate != null &&
        String.isNotEmpty(ordConf.OrderOpenedDate)
        ? DateTime.newInstance(
            Integer.valueOf(dateString[0]),
            Integer.valueOf(dateString[1]),
            Integer.valueOf(dateString[2])
          )
        : to.Order_Opened_Date__c;
      if (ordConf.Status == 'SUCCESS') {
        to.Order_Number__c = ordConf.OrderNumber;
        to.Recording_Order_Number__c = ordConf.OrderNumber;
        to.Error_Message__c = null;
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
        if (reqObj.Status == 'SUCCESS') {
          tO.Order_Opened_Date__c = reqObj.OrderOpenedDate != null &&
            String.isNotEmpty(reqObj.OrderOpenedDate)
            ? DateTime.valueOf(reqObj.OrderOpenedDate.replace('T', ' '))
            : tO.Order_Opened_Date__c;
          tO.Bulk_Project_Order_Num__c = reqObj.BulkProjectOrderNum;
          to.Error_Message__c = null;
          to.Status__c = 'Quote Request Received';
        } else {
          tO.Error_Message__c = reqObj.ErrorMessage;
        }
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
    err.setMessage(
      'Unable to locate orders. Please make sure that the relevant ID parameters are correct.'
    );
    throw err;
  }

  public static List<Title_Order__c> queryTitleOrders(
    ServiceLinkResponse resp,
    Boolean isNewOrderNumber,
    Boolean isNewBulkNum
  ) {
    Map<String, String> fieldValueMap = new Map<String, String>();

    if (resp.QuoteID != null && String.isNotEmpty(resp.QuoteID)) {
      fieldValueMap.put('Quote_ID__c', resp.QuoteID);
    }
    if (
      resp.BulkProjectOrderNum != null &&
      String.isNotEmpty(resp.BulkProjectOrderNum) && !isNewBulkNum
    ) {
      fieldValueMap.put('Bulk_Project_Order_Num__c', resp.BulkProjectOrderNum);
    }
    if (resp.LoanNumber != null && String.isNotEmpty(resp.LoanNumber)) {
      fieldValueMap.put('Loan_Number__c', resp.LoanNumber);
    }
    if (resp.AssetID != null && String.isNotEmpty(resp.AssetID)) {
      fieldValueMap.put('Asset_ID__c', resp.AssetID);
    }
    if (
      resp.OrderNumber != null &&
      String.isNotEmpty(resp.OrderNumber) &&
      !isNewOrderNumber
    ) {
      fieldValueMap.put('Order_Number__c', resp.OrderNumber);
    }
    if (
      resp.RecordingOrderNumber != null &&
      String.isNotEmpty(resp.RecordingOrderNumber)
    ) {
      fieldValueMap.put('Recording_Order_Number__c', resp.RecordingOrderNumber);
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

  public virtual class ServiceLinkBaseFields {
    public String LoanNumber;
    public String QuoteID;
    public String BulkProjectOrderNum;
    public String AssetID;
    public String OrderNumber;
    public String IncomingTransactionId;
  }

  public virtual class ServiceLinkAttachmentFields extends ServiceLinkBaseFields {
    public String CustInqId;
    public String NoteId;
    public String DocumentID;
    public String RecId;
    public String HOAOrderedDate;
    public String AllHOAOrderedDate;
    public String HOACompletedDate;
    public String AllHOACompletedDate;
    public String PayoffOrderedDate;
    public String AllPayoffsOrderedDate;
    public String PayoffCompletedDate;
    public String AllPayoffsCompletedDate;
    public String HOAExists;
    public String PayOffExists;
  }

  public virtual class ServiceLinkTitles extends ServiceLinkAttachmentFields {
    public String AllTitlesOrderedDate;
    public String TitleCompleteDate;
    public String AllTitlesCompletedDate;
    public String OriginalTitleClearedDate;
    public String OriginalAllTitlesClearedDate;
    public String LatestTitleClearedDate;
    public String LatestAllTitlesCleared;
  }

  public virtual class ServiceLinkTaxes extends ServiceLinkTitles {
    public String TaxesOrderedDate;
    public String AllTaxesOrderedDate;
    public String TaxesCompletedDate;
    public String AllTaxesCompletedDate;
  }

  public virtual class ServiceLinkMisc extends ServiceLinkTaxes {
    public String OrderOpenedDate;
    public String DeedsOrdered;
    public String UnExecDeedSentDate;
    public String ItemId;
    public String ItemType;
    public String ItemTypeDesc;
    public String ItemNoteText;
    public String CannotCureReasons;
    public String AllClearedToCloseDate;
    public String LoanDocsReceivedDate;
    public String SignedDocsScannedDate;
    public String ScannedDocsForwardedDate;
    public String DocsEstArrivalDate;
    public String SignedDocsReceivedDate;
    public String FileFundedDate;
  }

  public virtual class ServiceLinkRecordingTracking extends ServiceLinkMisc {
    public String RecordingDate;
    public String RecordingOrderNumber;
    public String RecordingState;
    public String RecordingCounty;
    public String RecordingType;
    public String RecordingDesc;
    public String InstrumentNumber;
    public String BookNumber;
    public String PageNumber;
    public String Grantor;
    public String Grantee;
    public String Mortgagor;
    public String Mortgagee;
  }

  public class SigningAttendee {
    public String Name;
  }

  public class SigningLocation {
    public String Address1;
    public String Address2;
    public String City;
    public String State;
    public String Zipcode;
  }

  public virtual class ServiceLinkSigningAppointment extends ServiceLinkRecordingTracking {
    public String AppointmentStatus;
    public String ScheduledSigningDate;
    public String CancelledDate;
    public String ClosedDate;
    public SigningLocation SigningLocation;
    public List<SigningAttendee> Attendees;
  }

  public class ServiceLinkResponse extends ServiceLinkSigningAppointment {
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
  }
}